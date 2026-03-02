#!/usr/bin/env python3
"""
Validate bundle-manifest.yaml against images_raw.txt, images.txt,
images_internal.txt, and chart template directories.

Collects ALL errors and reports a summary at the end (never fails fast).
"""

import argparse
import logging
import os
import re
import sys

try:
    import yaml
except ImportError:
    print("[ERROR] PyYAML is required. Install with: pip install pyyaml", file=sys.stderr)
    sys.exit(1)

logging.basicConfig(format='[%(levelname)-5s] %(message)s', level=logging.INFO)
log = logging.getLogger(__name__)


def load_yaml(path):
    with open(path) as f:
        return yaml.safe_load(f)


def load_lines(path, skip_comments=True, skip_headers=True):
    if not os.path.exists(path):
        return []
    with open(path) as f:
        return [
            line.strip() for line in f
            if line.strip()
            and (not skip_comments or not line.strip().startswith('#'))
            and (not skip_headers or not line.strip().startswith('##'))
        ]


def load_lines_with_headers(path):
    if not os.path.exists(path):
        return [], []
    lines = []
    headers = []
    with open(path) as f:
        for line in f:
            stripped = line.strip()
            if stripped.startswith('##'):
                headers.append(stripped)
            elif stripped:
                lines.append(stripped)
    return lines, headers


def get_image_name(entry):
    return entry['name'] if isinstance(entry, dict) else entry


def get_all_short_names(manifest):
    names = set()
    for mod_config in manifest.get('modules', {}).values():
        for entry in mod_config.get('images', []):
            names.add(get_image_name(entry))
        names.update(mod_config.get('exclude', []))
    return names


def get_excluded_short_names(manifest):
    excluded = set()
    for mod_config in manifest.get('modules', {}).values():
        excluded.update(mod_config.get('exclude', []))
    return excluded


def get_root_modules(modules):
    return {k for k, v in modules.items() if not v.get('parent')}


def get_child_modules(modules):
    return {k for k, v in modules.items() if v.get('parent')}


def get_all_bucket_paths(modules):
    return [v.get('bucket_path', k) for k, v in modules.items()]


def parse_chart_yaml_modules(chart_yaml_path):
    chart = load_yaml(chart_yaml_path)
    result = set()
    name_map = {'chaos': 'ce', 'db-devops': 'dbdevops', 'cd': 'cdng', 'srm': 'platform'}
    for dep in chart.get('dependencies', []):
        name = dep.get('name', '')
        if name in ('harness', 'harness-common'):
            continue
        result.add(name_map.get(name, name))
    return result


def scan_chart_templates(harness_dir):
    found_images = set()
    image_pattern = re.compile(r'image:\s*["\']?([a-zA-Z0-9_./-]+:[a-zA-Z0-9_.-]+)')
    for subdir in ('charts', 'templates'):
        path = os.path.join(harness_dir, subdir)
        if not os.path.isdir(path):
            continue
        for root, _, files in os.walk(path):
            for fname in files:
                if not fname.endswith(('.yaml', '.yml', '.tpl')):
                    continue
                try:
                    with open(os.path.join(root, fname)) as f:
                        for line in f:
                            m = image_pattern.search(line)
                            if m and '{{' not in m.group(1):
                                found_images.add(m.group(1))
                except (IOError, UnicodeDecodeError):
                    pass
    return found_images


def validate(args):
    errors = []
    warnings = []

    manifest = load_yaml(args.manifest)
    modules = manifest.get('modules', {})
    total_checks = 11
    check_num = 0

    raw_images = load_lines(args.raw_images) if args.raw_images and os.path.exists(args.raw_images) else []
    images_txt_lines, images_txt_headers = load_lines_with_headers(args.images_txt) if args.images_txt else ([], [])
    internal_lines = load_lines(args.internal_txt) if args.internal_txt and os.path.exists(args.internal_txt) else []

    all_short_names = get_all_short_names(manifest)
    excluded_names = get_excluded_short_names(manifest)
    root_modules = get_root_modules(modules)

    # Check 1: Every image in images_raw.txt maps to a manifest entry
    check_num += 1
    log.info(f"[{check_num}/{total_checks}] Checking image coverage in manifest...")
    if raw_images:
        for img in raw_images:
            matched = any(f"/{sn}:" in img for sn in all_short_names)
            if not matched:
                errors.append(f"Image '{img}' from images_raw.txt not mapped to any module in manifest")
            elif any(f"/{ex}:" in img for ex in excluded_names):
                log.info(f"  Image '{img}' is in manifest but excluded from bundle")

    # Check 2: Every manifest short name resolves to at least one raw image
    check_num += 1
    log.info(f"[{check_num}/{total_checks}] Checking manifest references resolve...")
    if raw_images:
        for short_name in all_short_names:
            if short_name in excluded_names:
                continue
            if not any(f"/{short_name}:" in img for img in raw_images):
                errors.append(f"Manifest image '{short_name}' not found in images_raw.txt")

    # Check 3: Chart.yaml modules have manifest entries
    check_num += 1
    log.info(f"[{check_num}/{total_checks}] Checking Chart.yaml modules have manifest entries...")
    if args.chart_yaml and os.path.exists(args.chart_yaml):
        chart_modules = parse_chart_yaml_modules(args.chart_yaml)
        for cm in chart_modules:
            if cm not in root_modules:
                errors.append(f"Chart.yaml module '{cm}' has no root entry in bundle-manifest.yaml")

    # Check 4: Orphaned manifest modules
    check_num += 1
    log.info(f"[{check_num}/{total_checks}] Checking for orphaned manifest modules...")
    if args.chart_yaml and os.path.exists(args.chart_yaml):
        chart_modules = parse_chart_yaml_modules(args.chart_yaml)
        for mod_name in root_modules:
            if mod_name not in chart_modules:
                warnings.append(f"Manifest root module '{mod_name}' not found in Chart.yaml dependencies")

    # Check 5: Dependency references are valid
    check_num += 1
    log.info(f"[{check_num}/{total_checks}] Checking dependency references...")
    for mod_name, mod_config in modules.items():
        for req in mod_config.get('requires', []):
            if req not in modules:
                errors.append(f"Module '{mod_name}' requires '{req}' which doesn't exist in manifest")
        parent = mod_config.get('parent')
        if parent and parent not in modules:
            errors.append(f"Module '{mod_name}' has parent '{parent}' which doesn't exist in manifest")

    # Check 6: No circular dependencies
    check_num += 1
    log.info(f"[{check_num}/{total_checks}] Checking for circular dependencies...")

    def detect_cycle(mod, visited, stack):
        visited.add(mod)
        stack.add(mod)
        for req in modules.get(mod, {}).get('requires', []):
            if req in stack:
                return [mod, req]
            if req not in visited:
                cycle = detect_cycle(req, visited, stack)
                if cycle:
                    return cycle
        stack.discard(mod)
        return None

    visited = set()
    for mod_name in modules:
        if mod_name not in visited:
            cycle = detect_cycle(mod_name, visited, set())
            if cycle:
                errors.append(f"Circular dependency detected: {' -> '.join(cycle)}")

    # Check 7: Unique bucket paths
    check_num += 1
    log.info(f"[{check_num}/{total_checks}] Checking bucket path uniqueness...")
    paths = get_all_bucket_paths(modules)
    seen = set()
    for p in paths:
        if p in seen:
            errors.append(f"Duplicate bucket_path '{p}'")
        seen.add(p)

    # Check 8: Section header count matches
    check_num += 1
    log.info(f"[{check_num}/{total_checks}] Checking section counts...")
    if images_txt_headers:
        actual_sections = len(images_txt_headers)
        expected_sections = len(modules)
        if actual_sections != expected_sections:
            errors.append(f"images.txt has {actual_sections} sections but manifest defines {expected_sections}")

    # Check 9: Image count consistency (images.txt vs images_internal.txt)
    # images.txt includes excluded images (in their module section); images_internal.txt does not.
    check_num += 1
    log.info(f"[{check_num}/{total_checks}] Checking image count consistency...")
    if images_txt_lines and internal_lines:
        excluded_count = sum(
            1 for img in images_txt_lines
            if any(f"/{ex}:" in img for ex in excluded_names)
        )
        bundled_in_txt = len(images_txt_lines) - excluded_count
        diff = bundled_in_txt - len(internal_lines)
        if diff < 0:
            errors.append(f"images_internal.txt has more images ({len(internal_lines)}) than bundled images in images.txt ({bundled_in_txt})")
        elif diff > 0 and excluded_names:
            log.info(f"  images.txt has {diff} more images than images_internal.txt (expected: excluded images)")
        elif diff > 0:
            warnings.append(f"images.txt has {len(images_txt_lines)} images but images_internal.txt has {len(internal_lines)}")

    # Check 10: Chart template scan for unlisted images
    check_num += 1
    log.info(f"[{check_num}/{total_checks}] Scanning chart templates for unlisted images...")
    if args.harness_dir and os.path.isdir(args.harness_dir):
        chart_images = scan_chart_templates(args.harness_dir)
        if chart_images and raw_images:
            raw_set = set(raw_images)
            for ci in chart_images:
                if ci not in raw_set:
                    warnings.append(f"Chart template image '{ci}' not in images_raw.txt (may be template-conditional)")

    # Check 11: Variant definitions reference existing images
    check_num += 1
    log.info(f"[{check_num}/{total_checks}] Checking variant definitions...")
    for mod_name, mod_config in modules.items():
        for entry in mod_config.get('images', []):
            if isinstance(entry, dict) and ('variants' in entry or 'extra_variants' in entry):
                if entry['name'] not in all_short_names:
                    errors.append(f"Variant defined for '{entry['name']}' in '{mod_name}' but image not in manifest")

    # Duplication info
    image_module_map = {}
    for mod_name, mod_config in modules.items():
        if mod_config.get('parent'):
            continue
        for entry in mod_config.get('images', []):
            short = get_image_name(entry)
            image_module_map.setdefault(short, []).append(mod_name)
    for img, mods in image_module_map.items():
        if len(mods) > 1:
            warnings.append(f"Image '{img}' appears in {len(mods)} modules ({', '.join(mods)}) - duplicated in bundles")

    # Summary
    root_count = len(root_modules)
    child_count = len(get_child_modules(modules))
    combined_count = sum(1 for m in modules.values() if m.get('bundle_type') == 'combined')

    print()
    print("=== SUMMARY ===")
    print(f"Modules: {root_count}  |  Sub-bundles: {child_count}  |  Total sections: {len(modules)}")
    if raw_images:
        print(f"Base images (raw): {len(raw_images)}")
    if images_txt_lines:
        print(f"Images in images.txt: {len(images_txt_lines)}")
    if excluded_names:
        print(f"Excluded from bundle: {len(excluded_names)} ({', '.join(sorted(excluded_names))})")
    print(f"Combined bundles: {combined_count}")
    print()

    if warnings:
        print(f"=== WARNINGS ({len(warnings)}) ===")
        for i, w in enumerate(warnings, 1):
            print(f"  [W{i}] {w}")
        print()

    if errors:
        print(f"=== ERRORS ({len(errors)}) ===")
        for i, e in enumerate(errors, 1):
            print(f"  [E{i}] {e}")
        print()
        print("Validation FAILED")
        return 1

    print("=== ERRORS (0) ===")
    print("Validation PASSED")
    return 0


def main():
    parser = argparse.ArgumentParser(description='Validate bundle manifest')
    parser.add_argument('--manifest', required=True, help='Path to bundle-manifest.yaml')
    parser.add_argument('--raw-images', help='Path to images_raw.txt')
    parser.add_argument('--images-txt', help='Path to images.txt')
    parser.add_argument('--internal-txt', help='Path to images_internal.txt')
    parser.add_argument('--chart-yaml', help='Path to Chart.yaml')
    parser.add_argument('--harness-dir', help='Path to harness chart directory (for template scanning)')
    args = parser.parse_args()

    script_dir = os.path.dirname(os.path.abspath(__file__))
    harness_dir = os.path.join(script_dir, 'harness')

    if not args.raw_images and os.path.exists(os.path.join(harness_dir, 'images_raw.txt')):
        args.raw_images = os.path.join(harness_dir, 'images_raw.txt')
    if not args.images_txt and os.path.exists(os.path.join(harness_dir, 'images.txt')):
        args.images_txt = os.path.join(harness_dir, 'images.txt')
    if not args.internal_txt and os.path.exists(os.path.join(harness_dir, 'images_internal.txt')):
        args.internal_txt = os.path.join(harness_dir, 'images_internal.txt')
    if not args.chart_yaml and os.path.exists(os.path.join(harness_dir, 'Chart.yaml')):
        args.chart_yaml = os.path.join(harness_dir, 'Chart.yaml')
    if not args.harness_dir and os.path.isdir(harness_dir):
        args.harness_dir = harness_dir

    sys.exit(validate(args))


if __name__ == '__main__':
    main()
