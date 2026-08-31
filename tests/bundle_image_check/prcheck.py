#!/usr/bin/env python3
"""
Bundle Image Check - PR Validation Script

Validates that all images in a service's Helm chart are tracked in bundle-manifest.yaml.
If a new image is introduced in a chart but not in the manifest, the SMP bundle build
will fail. This check catches that early at PR time.

Flow:
  1. Fetch PR changed files via Harness API
  2. Identify affected chart folders (those with Chart.yaml)
  3. Map service charts to SMP modules (only check SMP-relevant services)
  4. helm dep up + helm template to get rendered output
  5. Extract image short-names from rendered YAML
  6. Compare against bundle-manifest.yaml (new chart images, and images the chart dropped)
  7. Fail if the chart and manifest are out of sync
"""

import argparse
import importlib.util
import os
import subprocess
import sys
import tempfile
from contextlib import contextmanager
from functools import partial

import requests
import yaml


# ---------------------------------------------------------------------------
# Harness API
# ---------------------------------------------------------------------------

API_BASE = "https://harness0.harness.io/gateway/code/api/v1"
API_SCOPE = {
    'accountIdentifier': 'l7B_kbSEQD2wjrM7PShm5w',
    'orgIdentifier': 'PROD',
    'projectIdentifier': 'Harness_Commons',
    'routingId': 'l7B_kbSEQD2wjrM7PShm5w',
}


def pr_diff_request(repo_name, pr_number, harness_token, accept=None):
    """GET the PR diff endpoint. Returns the response, or None if it is unusable."""
    headers = {'x-api-key': harness_token}
    if accept:
        headers['Accept'] = accept

    url = f"{API_BASE}/repos/{repo_name}/pullreq/{pr_number}/diff"
    try:
        response = requests.get(url, headers=headers, params=API_SCOPE)
    except requests.RequestException as e:
        print(f"❌ PR diff request failed: {e}")
        return None

    if response.status_code != 200:
        print(f"❌ PR diff request returned HTTP {response.status_code}: {response.text[:200]}")
        return None

    return response


def get_changed_files(repo_name, pr_number, harness_token):
    """Paths changed in the PR."""
    print("🔍 Fetching changed files from API...")
    response = pr_diff_request(repo_name, pr_number, harness_token)
    files = [item['path'] for item in response.json() if 'path' in item] if response else []
    print(f"📁 Found {len(files)} changed files")
    return files


def get_pr_diff_text(repo_name, pr_number, harness_token):
    """
    Raw unified diff for the PR, used to spot images the PR deleted.
    Returns '' if the API will not serve a patch, so the caller can fall back to git.
    """
    response = pr_diff_request(repo_name, pr_number, harness_token, accept='text/plain')
    text = response.text if response else ''
    return text if text.lstrip().startswith(('diff --git', '--- ', 'Index:')) else ''


# ---------------------------------------------------------------------------
# SMP Service Discovery
# ---------------------------------------------------------------------------

def get_smp_services(helm_charts_path):
    """
    Build a mapping of {service_name: module_name} from the helm-charts module Chart.yaml files.

    Source of truth: src/modules/<module>/Chart.yaml dependencies list.
    """
    modules_dir = os.path.join(helm_charts_path, "src", "modules")
    umbrella_chart = os.path.join(helm_charts_path, "src", "harness", "Chart.yaml")

    if not os.path.exists(umbrella_chart):
        print(f"❌ Umbrella Chart.yaml not found: {umbrella_chart}")
        return {}

    with open(umbrella_chart, 'r') as f:
        umbrella = yaml.safe_load(f)

    module_names = [
        dep['name'] for dep in umbrella.get('dependencies', [])
        if dep['name'] != 'harness-common'
    ]

    service_to_module = {}

    for module in module_names:
        module_chart = os.path.join(modules_dir, module, "Chart.yaml")
        if not os.path.exists(module_chart):
            continue

        with open(module_chart, 'r') as f:
            chart = yaml.safe_load(f)

        for dep in chart.get('dependencies', []):
            service_name = dep['name']
            service_to_module[service_name] = module

    print(f"📋 Discovered {len(service_to_module)} SMP services across {len(module_names)} modules")
    return service_to_module


# ---------------------------------------------------------------------------
# Shared extraction logic (src/smp-tools.py)
# ---------------------------------------------------------------------------

def load_smp_tools(helm_charts_path):
    """Load smp-tools.py from the helm-charts clone (filename has a hyphen)."""
    script = os.path.join(helm_charts_path, "src", "smp-tools.py")
    spec = importlib.util.spec_from_file_location("smp_tools", script)
    if spec is None or spec.loader is None:
        raise ImportError(f"Cannot load smp-tools from {script}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def load_helm_charts_yaml(smp_tools, helm_charts_path, *parts, required=True):
    """Load a YAML file from the helm-charts clone, exiting if a required one is absent."""
    path = os.path.join(helm_charts_path, *parts)
    if os.path.exists(path):
        return smp_tools.load_manifest(path) or {}
    if required:
        print(f"❌ Not found in helm-charts: {os.path.join(*parts)}")
        sys.exit(1)
    return {}


# ---------------------------------------------------------------------------
# Chart Processing
# ---------------------------------------------------------------------------

def find_chart_folders(changed_files):
    """
    Identify chart folders from changed files.
    A chart folder is one containing Chart.yaml — we look for paths like:
      <service>/chart/templates/foo.yaml
      <service>/chart/values.yaml
    """
    chart_folders = set()

    for file_path in changed_files:
        parts = file_path.split('/')
        for i, part in enumerate(parts):
            if part == 'chart' and i > 0:
                chart_folder = '/'.join(parts[:i + 1])
                chart_folders.add(chart_folder)
                break

    return chart_folders


def get_service_name_from_chart(chart_path):
    """Get the service name from Chart.yaml in the chart folder."""
    chart_yaml = os.path.join(chart_path, 'Chart.yaml')
    if not os.path.exists(chart_yaml):
        return None

    with open(chart_yaml, 'r') as f:
        chart = yaml.safe_load(f)

    return chart.get('name')


def helm_template(chart_path, values_files=()):
    """Run helm dep up + helm template and return rendered output (None if it fails)."""
    print(f"  🔧 Running helm dep up for {chart_path}...")
    dep = subprocess.run(['helm', 'dep', 'up'], cwd=chart_path, capture_output=True, text=True)
    if dep.returncode != 0:
        print(f"  ⚠️ helm dep up warning: {dep.stderr.strip()}")

    cmd = ['helm', 'template', 'pr-check', '.']
    cmd += [arg for path in values_files for arg in ('-f', path)]

    print(f"  🔧 Running helm template for {chart_path}...")
    result = subprocess.run(cmd, cwd=chart_path, capture_output=True, text=True)

    if result.returncode != 0:
        print(f"  ❌ helm template failed: {result.stderr.strip()}")
        return None

    return result.stdout


@contextmanager
def values_files(layers, prefix):
    """
    Write override layers to temp values files for `helm template -f`, which merges them
    over the chart's own values.yaml without editing the PR checkout.
    """
    paths = []
    try:
        for index, layer in enumerate(layers):
            fd, path = tempfile.mkstemp(prefix=f"{prefix}-{index}-", suffix=".yaml")
            with os.fdopen(fd, 'w') as f:
                yaml.safe_dump(layer, f)
            paths.append(path)
        yield paths
    finally:
        for path in paths:
            os.unlink(path)


def git_diff_text(repo_path):
    """Unified diff from the local clone, when the API will not serve a patch."""
    base = os.environ.get('PR_BASE_SHA')
    for spec in ([f'{base}...HEAD'] if base else []) + ['HEAD^']:
        result = subprocess.run(
            ['git', '-C', repo_path, 'diff', spec],
            capture_output=True, text=True,
        )
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout
    return ''


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

def report(problems):
    """
    Print findings grouped by heading, so a new check only has to append a dict of
    {'heading': ..., '<label>': '<value>', ...} rather than add its own report block.
    """
    for heading in dict.fromkeys(problem['heading'] for problem in problems):
        matching = [problem for problem in problems if problem['heading'] == heading]
        print(f"❌ Found {len(matching)} {heading}:")
        print()
        for problem in matching:
            for label, value in problem.items():
                if label != 'heading':
                    print(f"     {label}: {value}")
            print()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description='Bundle Image Check - Validate chart images are in bundle-manifest.yaml'
    )
    parser.add_argument('--repo_name', required=True, help='Repository name')
    parser.add_argument('--pr_number', required=True, help='Pull request number')
    parser.add_argument('--harness_token', required=True, help='Harness API token')
    parser.add_argument('--helm_charts_path', default='/harness-temp/helm-charts',
                        help='Path to cloned helm-charts repo')
    parser.add_argument('--repo_path', default=None,
                        help='Path to the PR repo (default: /harness-temp/<repo_name>)')

    args = parser.parse_args()

    if not args.repo_path:
        args.repo_path = f"/harness-temp/{args.repo_name}"

    print(f"🚀 Bundle Image Check")
    print(f"={'=' * 50}")
    print(f"  Repository: {args.repo_name}")
    print(f"  PR Number: {args.pr_number}")
    print(f"  Helm Charts: {args.helm_charts_path}")
    print(f"  Repo Path: {args.repo_path}")
    print()

    # Step 1: Get SMP services mapping
    smp_services = get_smp_services(args.helm_charts_path)
    if not smp_services:
        print("⚠️ Could not discover SMP services. Skipping check.")
        sys.exit(0)

    # Shared image extraction / manifest lookup lives in src/smp-tools.py
    try:
        smp_tools = load_smp_tools(args.helm_charts_path)
    except (ImportError, FileNotFoundError, OSError) as e:
        print(f"❌ Failed to load smp-tools.py from helm-charts: {e}")
        sys.exit(1)

    # Step 2: Load the helm-charts sources this check compares against
    load = partial(load_helm_charts_yaml, smp_tools, args.helm_charts_path)
    manifest = load("src", "bundle-manifest.yaml")
    repo_map = load("src", "docker-repo-map.yaml")
    harness_values = load("src", "harness", "values.yaml", required=False)

    all_manifest_names = smp_tools.manifest_short_names(manifest)
    repo_map_short_names = smp_tools.collect_repo_map_short_names(repo_map)
    print(f"📋 Loaded {len(all_manifest_names)} image short-names from bundle-manifest.yaml")
    print(f"🗺️ Loaded docker-repo-map with {len(repo_map)} chart entries")
    print()

    # Step 3: Get changed files from PR
    changed_files = get_changed_files(args.repo_name, args.pr_number, args.harness_token)
    if not changed_files:
        print("📝 No changed files found. Skipping check.")
        sys.exit(0)

    # Step 4: Find chart folders in changed files
    chart_folders = find_chart_folders(changed_files)
    if not chart_folders:
        print("⏭️ No chart folder changes detected. Skipping check.")
        sys.exit(0)

    # Removed image refs drive the reverse check (manifest entry the chart dropped)
    pr_diff = get_pr_diff_text(args.repo_name, args.pr_number, args.harness_token)
    diff_source = "PR API"
    if not pr_diff:
        pr_diff = git_diff_text(args.repo_path)
        diff_source = "git"

    removed_short_names = smp_tools.extract_removed_image_names(pr_diff)
    if pr_diff:
        print(f"🗑️ PR diff ({diff_source}) removes {len(removed_short_names)} image name(s): "
              f"{', '.join(sorted(removed_short_names)) or 'none'}")
    else:
        print("⚠️ Could not read the PR diff (API and git both unavailable) — "
              "cannot detect images removed from the chart")

    print(f"\n📂 Found {len(chart_folders)} chart folder(s) with changes:")
    for folder in sorted(chart_folders):
        print(f"  - {folder}")
    print()

    # Step 5: Filter to SMP services only and validate
    problems = []
    checked_services = 0

    for chart_folder in sorted(chart_folders):
        absolute_chart_path = os.path.join(args.repo_path, chart_folder)

        if not os.path.isdir(absolute_chart_path):
            print(f"  ⚠️ Chart path not found: {absolute_chart_path}")
            continue

        service_name = get_service_name_from_chart(absolute_chart_path)
        if not service_name:
            print(f"  ⚠️ Could not determine service name from: {absolute_chart_path}")
            continue

        # Check if this service is part of SMP
        if service_name not in smp_services:
            print(f"  ⏭️ Service '{service_name}' is not an SMP service. Skipping.")
            continue

        module = smp_services[service_name]
        print(f"  🔍 Checking service '{service_name}' (SMP module: {module})")
        checked_services += 1

        # Render the way SMP does: umbrella values first, docker-repo-map on top
        layers = smp_tools.service_override_values(harness_values, repo_map, module, service_name)
        with values_files(layers, service_name) as override_paths:
            rendered = helm_template(absolute_chart_path, override_paths)

        # A failed render yields no images, which would otherwise look like a clean pass
        if not rendered:
            problems.append({
                'heading': 'chart(s) that failed to render, leaving their images unchecked',
                'Service': service_name,
                'Chart': chart_folder,
            })
            continue

        # Extract images (same helpers as smp-tools extract-images / validate-bundle)
        images = smp_tools.extract_image_refs(rendered)
        print(f"  📦 Found {len(images)} image reference(s) in rendered output")

        # Forward: the chart renders an image the manifest does not track.
        found_short_names = set()
        for image_ref in sorted(images):
            short_name = smp_tools.extract_short_name(image_ref)
            found_short_names.add(short_name)
            if short_name not in all_manifest_names:
                problems.append({
                    'heading': 'image(s) in the chart but NOT in bundle-manifest.yaml',
                    'Image': image_ref,
                    'Short name': short_name,
                    'Service': service_name,
                })

        # Reverse: this service's published image, or an image this PR deleted, is
        # still listed in the manifest (including exclude / exclude_full).
        tracked = smp_tools.manifest_short_names(manifest, module)
        expected = set(repo_map_short_names.get(service_name, set()))
        expected |= smp_tools.resolve_to_manifest_names(removed_short_names, tracked)

        stale = sorted(expected - found_short_names)
        print(f"  🔁 Reverse check: {len(expected)} manifest name(s) expected from this chart, "
              f"{len(stale)} missing")
        for short_name in stale:
            problems.append({
                'heading': 'image(s) in bundle-manifest.yaml but no longer in the chart',
                'Short name': short_name,
                'Listed for module': module,
                'Service': service_name,
            })

    # Step 6: Report results
    print()
    print('=' * 50)

    if checked_services == 0:
        print("⏭️ No SMP service charts were affected. Skipping validation.")
        sys.exit(0)

    if not problems:
        print(f"✅ All images in {checked_services} checked service(s) match bundle-manifest.yaml!")
        sys.exit(0)

    report(problems)
    print("💡 Add new short-names to helm-charts/src/bundle-manifest.yaml; "
          "remove short-names the chart no longer uses.")
    print("❌ Bundle image check FAILED!")
    sys.exit(1)


if __name__ == "__main__":
    main()
