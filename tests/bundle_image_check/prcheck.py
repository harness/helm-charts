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
  6. Compare against bundle-manifest.yaml
  7. Fail if any image is missing from the manifest
"""

import argparse
import os
import re
import subprocess
import sys

import requests
import yaml


# ---------------------------------------------------------------------------
# Harness API
# ---------------------------------------------------------------------------

def get_changed_files_from_api(repo_name, pr_number, harness_token):
    """Get files changed in PR using Harness API."""
    api_url = (
        f"https://harness0.harness.io/gateway/code/api/v1/repos/{repo_name}"
        f"/pullreq/{pr_number}/diff"
        f"?accountIdentifier=l7B_kbSEQD2wjrM7PShm5w"
        f"&orgIdentifier=PROD&projectIdentifier=Harness_Commons"
        f"&routingId=l7B_kbSEQD2wjrM7PShm5w"
    )

    headers = {'x-api-key': harness_token}

    print(f"🔍 Fetching changed files from API...")
    response = requests.get(api_url, headers=headers)

    if response.status_code != 200:
        print(f"❌ Error fetching changed files: HTTP {response.status_code}")
        print(f"Response: {response.text}")
        return []

    diff_data = response.json()
    changed_files = [item['path'] for item in diff_data if 'path' in item]

    print(f"📁 Found {len(changed_files)} changed files")
    return changed_files


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
# Bundle Manifest
# ---------------------------------------------------------------------------

def get_manifest_short_names(manifest_path):
    """
    Load bundle-manifest.yaml and collect all known image short-names.
    Returns a dict of {short_name: module_name} for lookup.
    """
    with open(manifest_path, 'r') as f:
        manifest = yaml.safe_load(f)

    short_name_to_module = {}
    modules = manifest.get('modules', {})

    for module_name, config in modules.items():
        for entry in config.get('images', []):
            name = entry['name'] if isinstance(entry, dict) else entry
            short_name_to_module[name] = module_name

        for name in config.get('exclude', []):
            short_name_to_module[name] = module_name

        for name in config.get('exclude_full', []):
            short_name_to_module[name] = module_name

    return short_name_to_module


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


def helm_template(chart_path):
    """Run helm dep up + helm template and return rendered output."""
    print(f"  🔧 Running helm dep up for {chart_path}...")
    dep_result = subprocess.run(
        ['helm', 'dep', 'up'],
        cwd=chart_path,
        capture_output=True, text=True
    )
    if dep_result.returncode != 0:
        print(f"  ⚠️ helm dep up warning: {dep_result.stderr.strip()}")

    print(f"  🔧 Running helm template for {chart_path}...")
    result = subprocess.run(
        ['helm', 'template', 'pr-check', '.'],
        cwd=chart_path,
        capture_output=True, text=True
    )

    if result.returncode != 0:
        print(f"  ⚠️ helm template failed: {result.stderr.strip()}")
        return None

    return result.stdout


def extract_images_from_rendered(rendered_yaml):
    """
    Extract image references from rendered Helm output.
    Same regex approach as smp-tools.py _scan_chart_templates.
    """
    if not rendered_yaml:
        return set()

    image_pattern = re.compile(r'image:\s*["\']?([a-zA-Z0-9_./-]+:[a-zA-Z0-9_.\-]+)')
    images = set()

    for line in rendered_yaml.splitlines():
        match = image_pattern.search(line)
        if match and '{{' not in match.group(1):
            images.add(match.group(1))

    return images


def extract_short_name(image_ref):
    """
    Extract the short name from a full image reference.
    Examples:
      docker.io/harnesssecure/ng-manager-signed:1.150.5 -> ng-manager-signed
      harnesssecure/vault-secret-loader:1.0.9 -> vault-secret-loader
      registry.k8s.io/defaultbackend-amd64:1.5 -> defaultbackend-amd64
      docker.io/busybox:1.37.0 -> busybox
    """
    # Remove tag
    without_tag = image_ref.rsplit(':', 1)[0] if ':' in image_ref else image_ref
    # Get the last path component (the image name)
    short_name = without_tag.rsplit('/', 1)[-1] if '/' in without_tag else without_tag
    return short_name


# ---------------------------------------------------------------------------
# Ignore list - images that are common infrastructure and not service-specific
# ---------------------------------------------------------------------------

INFRA_IMAGES_IGNORE = {
    'kubectl',
    'kube-rbac-proxy',
    'curlimages/curl',
}


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

    # Step 2: Get bundle manifest short names
    manifest_path = os.path.join(args.helm_charts_path, "src", "bundle-manifest.yaml")
    if not os.path.exists(manifest_path):
        print(f"❌ bundle-manifest.yaml not found at: {manifest_path}")
        sys.exit(1)

    manifest_short_names = get_manifest_short_names(manifest_path)
    print(f"📋 Loaded {len(manifest_short_names)} image short-names from bundle-manifest.yaml")
    print()

    # Step 3: Get changed files from PR
    changed_files = get_changed_files_from_api(args.repo_name, args.pr_number, args.harness_token)
    if not changed_files:
        print("📝 No changed files found. Skipping check.")
        sys.exit(0)

    # Step 4: Find chart folders in changed files
    chart_folders = find_chart_folders(changed_files)
    if not chart_folders:
        print("⏭️ No chart folder changes detected. Skipping check.")
        sys.exit(0)

    print(f"\n📂 Found {len(chart_folders)} chart folder(s) with changes:")
    for folder in sorted(chart_folders):
        print(f"  - {folder}")
    print()

    # Step 5: Filter to SMP services only and validate
    missing_images = []
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

        module_name = smp_services[service_name]
        print(f"  🔍 Checking service '{service_name}' (SMP module: {module_name})")
        checked_services += 1

        # helm template
        rendered = helm_template(absolute_chart_path)
        if not rendered:
            print(f"  ⚠️ Could not render templates for '{service_name}'. Skipping.")
            continue

        # Extract images
        images = extract_images_from_rendered(rendered)
        print(f"  📦 Found {len(images)} image reference(s) in rendered output")

        # Check each image against manifest
        for image_ref in sorted(images):
            short_name = extract_short_name(image_ref)

            if short_name in INFRA_IMAGES_IGNORE:
                continue

            if short_name not in manifest_short_names:
                missing_images.append({
                    'image_ref': image_ref,
                    'short_name': short_name,
                    'service': service_name,
                    'module': module_name,
                })

    # Step 6: Report results
    print()
    print(f"{'=' * 50}")

    if checked_services == 0:
        print("⏭️ No SMP service charts were affected. Skipping validation.")
        sys.exit(0)

    if not missing_images:
        print(f"✅ All images in {checked_services} checked service(s) are tracked in bundle-manifest.yaml!")
        sys.exit(0)

    # Failure - report missing images
    print(f"❌ Found {len(missing_images)} image(s) NOT in bundle-manifest.yaml:")
    print()

    for item in missing_images:
        print(f"  ❌ Image: {item['image_ref']}")
        print(f"     Short name: {item['short_name']}")
        print(f"     Found in service: {item['service']}")
        print(f"     Suggested module: {item['module']}")
        print(f"     → Add '{item['short_name']}' to module '{item['module']}' in src/bundle-manifest.yaml")
        print()

    print("💡 How to fix:")
    print("   1. Open helm-charts/src/bundle-manifest.yaml")
    print("   2. Find the appropriate module section (suggested above)")
    print("   3. Add the missing image short-name to the 'images' list")
    print("   4. Commit and push the change to the helm-charts repo")
    print()
    print("❌ Bundle image check FAILED!")
    sys.exit(1)


if __name__ == "__main__":
    main()
