#!/usr/bin/env python3
"""
SMP tools: unified CLI for bundle image generation, Helm flag extraction, and manifest validation.

Subcommands:
  bundle-images     Resolve bundle-manifest.yaml to produce images.txt and images_internal.txt
  auto-enable-flags Scan a Helm YAML file and emit --set <path>=true flags for enabled/create keys
  validate-bundle   Validate bundle-manifest.yaml against images_raw.txt, images.txt, etc.

Usage:
  python3 smp-tools.py bundle-images --manifest bundle-manifest.yaml --raw-images images_raw.txt --output-dir .
  python3 smp-tools.py bundle-images --manifest bundle-manifest.yaml --internal-only --images-txt images.txt --output-dir .
  python3 smp-tools.py auto-enable-flags values.yaml
  python3 smp-tools.py auto-enable-flags --mode true generate-image.yaml
  python3 smp-tools.py validate-bundle --manifest bundle-manifest.yaml
"""

import argparse
import logging
import math
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

# ---------------------------------------------------------------------------
# auto-enable-flags
# ---------------------------------------------------------------------------

AUTO_ENABLE_BLOCKLIST = {
    "global.lwd.enabled",
    "global.lwd.autocud.enabled",
    "global.jfr.enabled",
}

FLAG_KEYS = {"enabled", "create"}


def collect_flags(data, target_value, path=""):
    """Walk the YAML tree and yield --set flags for matching keys."""
    if not isinstance(data, dict):
        return
    for key, value in data.items():
        dotted = f"{path}.{key}" if path else key
        if key in FLAG_KEYS and value is target_value:
            if "." not in dotted or dotted in AUTO_ENABLE_BLOCKLIST:
                continue
            yield f"--set {dotted}=true"
        elif isinstance(value, dict):
            yield from collect_flags(value, target_value, dotted)


def cmd_auto_enable_flags(args):
    """Emit --set flags from a Helm values YAML file."""
    try:
        with open(args.values_yaml) as f:
            data = yaml.safe_load(f)
    except FileNotFoundError:
        print(f"[ERROR] File not found: {args.values_yaml}", file=sys.stderr)
        sys.exit(1)

    target_value = args.mode == "true"
    if data:
        for flag in collect_flags(data, target_value):
            print(flag)


# ---------------------------------------------------------------------------
# bundle-images
# ---------------------------------------------------------------------------

def load_manifest(path):
    with open(path) as f:
        return yaml.safe_load(f)


def load_raw_images(path):
    with open(path) as f:
        return [line.strip() for line in f if line.strip() and not line.startswith('#')]


def find_matching_images(short_name, raw_images):
    """Find all images in raw_images matching a short name like 'ci-manager-signed'."""
    pattern = f"/{short_name}:"
    return [img for img in raw_images if pattern in img]


def get_image_name(entry):
    """Return the short name from a plain string or dict image entry."""
    return entry['name'] if isinstance(entry, dict) else entry


def get_image_variants(entry, section_variants, global_variants):
    """
    Resolve variant suffixes using cascading: inline entry > section > global.

    Image entries may be:
      - plain string: inherit from section or global
      - dict with 'variants': use those directly
      - dict with 'extra_variants': append to inherited list
      - dict with 'variants_only: true': same as 'variants' but the base image is
        suppressed from output (only the variant images are emitted). The base tag
        is still resolved from images_raw.txt so that the versioned variant tags can
        be constructed correctly.
    """
    if isinstance(entry, dict):
        if 'variants' in entry:
            return entry['variants']
        if 'extra_variants' in entry:
            parent = section_variants.get('variants', []) if section_variants else global_variants.get('variants', [])
            return list(set(parent + entry['extra_variants']))

    if section_variants:
        return section_variants.get('variants', [])

    return global_variants.get('variants', [])


def process_section(name, config, raw_images, global_variants):
    """
    Process a single module section uniformly.
    Returns (customer_lines, internal_lines, resolved_images, errors).

    For single bundle-type sections each variant (base tag + suffix) gets its own
    @image= group marker so the pipeline treats them as independent bundles.

    Excluded images (module-level exclude list) appear in customer_lines (images.txt)
    but are omitted from internal_lines so they are never bundled.
    """
    bundle_type = config.get('bundle_type', 'combined')
    bucket_path = config.get('bucket_path', name)
    parent = config.get('parent')
    requires = config.get('requires', [])
    section_variants = config.get('variants')
    images_list = config.get('images', [])
    exclude_list = set(config.get('exclude', []))

    customer_lines = []
    internal_lines = []
    resolved_images = []
    errors = []

    if parent:
        internal_header = f"# @module={name} @type={bundle_type} @path={bucket_path} @parent={parent}"
    else:
        requires_str = ','.join(requires) if requires else ''
        internal_header = f"# @module={name} @type={bundle_type} @path={bucket_path} @requires={requires_str}"

    internal_lines.append(internal_header)

    for short_name in exclude_list:
        for match in find_matching_images(short_name, raw_images):
            customer_lines.append(match)
            resolved_images.append(match)

    for image_entry in images_list:
        short_name = get_image_name(image_entry)
        matches = find_matching_images(short_name, raw_images)

        if not matches:
            errors.append(f"Image '{short_name}' in section '{name}' not found in images_raw.txt")
            continue

        variants = get_image_variants(image_entry, section_variants, global_variants)
        # When variants_only=True the base image is used only as a tag anchor; it is
        # never written to customer or internal output.  Requires 'variants' to be set.
        variants_only = isinstance(image_entry, dict) and image_entry.get('variants_only', False)

        # For single bundles, use only the first match as base; variants are constructed from it.
        # Each @image= gets a unique name (short_name for base, short_name+variant for variants).
        match_iter = [matches[0]] if bundle_type == 'single' and matches else matches

        for match in match_iter:
            if not variants_only:
                customer_lines.append(match)
                resolved_images.append(match)

            if bundle_type == 'single':
                if not variants_only:
                    # Base image gets its own group
                    internal_lines.append(f"# @image={short_name}")
                    internal_lines.append(match)

                # Each variant is a separate group so they bundle independently.
                # Normalize variant for bundle name: .minimal -> -minimal, -fips -> -fips
                for variant in variants:
                    variant_image = f"{match}{variant}"
                    suffix = variant.lstrip('.-').replace('.', '-')
                    internal_lines.append(f"# @image={short_name}-{suffix}")
                    internal_lines.append(variant_image)
                    customer_lines.append(variant_image)
                    resolved_images.append(variant_image)
            else:
                if not variants_only:
                    internal_lines.append(match)
                for variant in variants:
                    variant_image = f"{match}{variant}"
                    customer_lines.append(variant_image)
                    resolved_images.append(variant_image)
                    internal_lines.append(variant_image)

    return customer_lines, internal_lines, resolved_images, errors


PIPELINE_BATCH_SIZE = 12


def count_pulls(internal_lines):
    """Count the number of pull operations (non-comment, non-empty lines) in a section."""
    return sum(1 for l in internal_lines if l.strip() and not l.startswith('#'))


def split_single_section_into_batches(name, internal_lines, batch_size):
    """
    Split a single-type section's internal lines into batches of batch_size image groups.
    Returns list of (batch_name, batch_lines) tuples.
    """
    header = internal_lines[0]
    groups = []
    current_group = []

    for line in internal_lines[1:]:
        if line.startswith('# @image='):
            if current_group:
                groups.append(current_group)
            current_group = [line]
        elif line.strip():
            current_group.append(line)

    if current_group:
        groups.append(current_group)

    if len(groups) <= batch_size:
        return [(name, internal_lines)]

    num_batches = math.ceil(len(groups) / batch_size)
    batches = []
    for b in range(num_batches):
        batch_groups = groups[b * batch_size:(b + 1) * batch_size]
        batch_header = header.replace(f"@module={name}", f"@module={name}@{b + 1}")
        batch_lines = [batch_header]
        for g in batch_groups:
            batch_lines.extend(g)
        batches.append((f"{name}@{b + 1}", batch_lines))
    return batches


def sort_and_batch_internal_sections(sections_data):
    """
    Takes list of (name, config, internal_lines) and returns
    sorted, batched internal text (heaviest pull count first).
    """
    entries = []
    for name, config, internal_lines in sections_data:
        bundle_type = config.get('bundle_type', 'combined')
        if bundle_type == 'single':
            batches = split_single_section_into_batches(name, internal_lines, PIPELINE_BATCH_SIZE)
        else:
            batches = [(name, internal_lines)]
        for batch_name, batch_lines in batches:
            pulls = count_pulls(batch_lines)
            entries.append((batch_name, batch_lines, pulls))

    entries.sort(key=lambda x: -x[2])

    all_lines = []
    for batch_name, batch_lines, pulls in entries:
        all_lines.extend(batch_lines)
        all_lines.append('')

    return '\n'.join(all_lines).rstrip() + '\n'


def bundle_generate(manifest, raw_images):
    """
    Main generation logic. Returns (customer_text, internal_text, all_resolved, all_excluded, all_errors).
    """
    global_cfg = manifest.get('global', {})
    global_variants_list = global_cfg.get('variants', [])
    global_variants = {'variants': global_variants_list}
    modules = manifest.get('modules', {})

    all_customer_lines = []
    all_resolved = []
    all_excluded = []
    all_errors = []
    sections_data = []

    total = len(modules)

    for idx, (name, config) in enumerate(modules.items(), 1):
        parent = config.get('parent')
        log.info(f"[{idx}/{total}] Processing: {name}")

        customer, internal, resolved, errors = process_section(
            name, config, raw_images, global_variants
        )

        header_prefix = "###" if parent else "##"
        header = f"{header_prefix} {config.get('description', name)}"
        all_customer_lines.append(header)
        all_customer_lines.extend(customer)
        all_customer_lines.append('')

        sections_data.append((name, config, internal))
        all_resolved.extend(resolved)
        all_errors.extend(errors)

    customer_text = '\n'.join(all_customer_lines).rstrip() + '\n'
    internal_text = sort_and_batch_internal_sections(sections_data)

    return customer_text, internal_text, all_resolved, all_excluded, all_errors


def bundle_generate_internal_only(manifest, images_txt_path):
    """
    Regenerate images_internal.txt from committed images.txt + manifest.
    Parses section headers in images.txt to map images back to modules.
    Output is sorted by pull count (heaviest first) with single-type batching.
    """
    modules = manifest.get('modules', {})

    with open(images_txt_path) as f:
        images_txt_content = f.read()

    sections = []
    current_desc = None
    current_images = []

    for line in images_txt_content.splitlines():
        if line.startswith('### ') or line.startswith('## '):
            if current_desc is not None:
                sections.append((current_desc, current_images))
            current_desc = line.lstrip('#').strip()
            current_images = []
        elif line.strip():
            current_images.append(line.strip())

    if current_desc is not None:
        sections.append((current_desc, current_images))

    desc_to_module = {}
    excluded_short_names = set()
    for mod_name, mod_config in modules.items():
        desc_to_module[mod_config.get('description', mod_name)] = (mod_name, mod_config)
        excluded_short_names.update(mod_config.get('exclude', []))

    def is_image_excluded(img_ref):
        for short in excluded_short_names:
            if f"/{short}:" in img_ref:
                return True
        return False

    sections_data = []
    for desc, imgs in sections:
        if desc not in desc_to_module:
            continue

        mod_name, mod_config = desc_to_module[desc]
        bundle_type = mod_config.get('bundle_type', 'combined')
        bucket_path = mod_config.get('bucket_path', mod_name)
        parent = mod_config.get('parent')
        non_excluded_imgs = [img for img in imgs if not is_image_excluded(img)]

        if parent:
            header = f"# @module={mod_name} @type={bundle_type} @path={bucket_path} @parent={parent}"
        else:
            requires = ','.join(mod_config.get('requires', []))
            header = f"# @module={mod_name} @type={bundle_type} @path={bucket_path} @requires={requires}"

        internal_lines = [header]
        if bundle_type == 'single':
            # Build short_name -> variants from manifest (sort by length desc to match longest first)
            variants_by_short = {}
            for entry in mod_config.get('images', []):
                short = entry['name'] if isinstance(entry, dict) else entry
                variants = entry.get('variants', []) if isinstance(entry, dict) else []
                variants_by_short[short] = sorted(variants, key=len, reverse=True)

            for img in non_excluded_imgs:
                tag_part = img.rsplit(':', 1)[0] if ':' in img else img
                base_name = tag_part.rsplit('/', 1)[-1] if '/' in tag_part else tag_part
                tag = img.rsplit(':', 1)[1] if ':' in img else 'latest'
                variants = variants_by_short.get(base_name, [])
                # Match tag to variant: base uses base_name, variants use base_name-variant_suffix
                bundle_name = base_name
                for v in variants:
                    if tag.endswith(v):
                        # Normalize .minimal -> -minimal, -fips -> -fips
                        suffix = v.lstrip('.-').replace('.', '-')
                        bundle_name = f"{base_name}-{suffix}"
                        break
                internal_lines.append(f"# @image={bundle_name}")
                internal_lines.append(img)
        else:
            internal_lines.extend(non_excluded_imgs)

        sections_data.append((mod_name, mod_config, internal_lines))

    return sort_and_batch_internal_sections(sections_data)


def cmd_bundle_images(args):
    """Resolve bundle manifest against raw images."""
    manifest = load_manifest(args.manifest)

    if args.internal_only:
        images_txt = args.images_txt
        if not images_txt:
            if args.output_dir:
                images_txt = os.path.join(args.output_dir, 'images.txt')
            else:
                log.error("--images-txt or --output-dir required for --internal-only mode")
                sys.exit(1)

        log.info(f"Regenerating images_internal.txt from {images_txt}")
        internal_text = bundle_generate_internal_only(manifest, images_txt)

        output_dir = args.output_dir or os.path.dirname(images_txt)
        internal_path = os.path.join(output_dir, 'images_internal.txt')
        with open(internal_path, 'w') as f:
            f.write(internal_text)
        log.info(f"Written {internal_path}")
        return

    if not args.raw_images:
        log.error("--raw-images is required when not using --internal-only")
        sys.exit(1)

    if not args.output_dir:
        log.error("--output-dir is required when not using --internal-only")
        sys.exit(1)

    raw_images = load_raw_images(args.raw_images)
    log.info(f"Loaded {len(raw_images)} base images from {args.raw_images}")

    customer_text, internal_text, resolved, excluded, errors = bundle_generate(manifest, raw_images)

    if errors:
        log.warning(f"Encountered {len(errors)} resolution errors:")
        for err in errors:
            log.warning(f"  {err}")

    images_path = os.path.join(args.output_dir, 'images.txt')
    internal_path = os.path.join(args.output_dir, 'images_internal.txt')

    with open(images_path, 'w') as f:
        f.write(customer_text)

    with open(internal_path, 'w') as f:
        f.write(internal_text)

    unique_base = set()
    unique_all = set()
    for img in resolved:
        unique_all.add(img)
        base = img.rsplit(':', 1)[0] if ':' in img else img
        unique_base.add(base)

    log.info(f"Written {images_path} ({customer_text.count(chr(10))} lines)")
    log.info(f"Written {internal_path}")
    log.info(f"Resolved {len(unique_all)} total image references ({len(unique_base)} unique base images)")

    if excluded:
        log.info(f"Excluded from bundle ({len(excluded)} images, still in images.txt):")
        for img in excluded:
            log.info(f"  {img}")

    unmatched = set(raw_images) - set(r for r in resolved if r in raw_images)
    if unmatched:
        log.warning(f"{len(unmatched)} images in images_raw.txt not mapped to any module:")
        for img in sorted(unmatched):
            log.warning(f"  {img}")


# ---------------------------------------------------------------------------
# validate-bundle
# ---------------------------------------------------------------------------

def _load_validate_lines(path, skip_comments=True, skip_headers=True):
    if not path or not os.path.exists(path):
        return []
    with open(path) as f:
        return [
            line.strip() for line in f
            if line.strip()
            and (not skip_comments or not line.strip().startswith('#'))
            and (not skip_headers or not line.strip().startswith('##'))
        ]


def _load_lines_with_headers(path):
    if not path or not os.path.exists(path):
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


def _get_all_short_names(manifest):
    names = set()
    for mod_config in manifest.get('modules', {}).values():
        for entry in mod_config.get('images', []):
            names.add(get_image_name(entry))
        names.update(mod_config.get('exclude', []))
    return names


def _get_excluded_short_names(manifest):
    excluded = set()
    for mod_config in manifest.get('modules', {}).values():
        excluded.update(mod_config.get('exclude', []))
    return excluded


def _get_root_modules(modules):
    return {k for k, v in modules.items() if not v.get('parent')}


def _get_child_modules(modules):
    return {k for k, v in modules.items() if v.get('parent')}


def _get_all_bucket_paths(modules):
    return [v.get('bucket_path', k) for k, v in modules.items()]


def _parse_chart_yaml_modules(chart_yaml_path):
    chart = load_manifest(chart_yaml_path)
    result = set()
    name_map = {'chaos': 'ce', 'db-devops': 'dbdevops', 'cd': 'cdng', 'srm': 'platform'}
    for dep in chart.get('dependencies', []):
        name = dep.get('name', '')
        if name in ('harness', 'harness-common'):
            continue
        result.add(name_map.get(name, name))
    return result


def _scan_chart_templates(harness_dir):
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


def cmd_validate_bundle(args):
    """Validate bundle-manifest.yaml against images_raw.txt, images.txt, images_internal.txt, and chart templates."""
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

    errors = []
    warnings = []

    manifest = load_manifest(args.manifest)
    modules = manifest.get('modules', {})
    total_checks = 11
    check_num = 0

    raw_images = _load_validate_lines(args.raw_images) if args.raw_images else []
    images_txt_lines, images_txt_headers = _load_lines_with_headers(args.images_txt) if args.images_txt else ([], [])
    internal_lines = _load_validate_lines(args.internal_txt) if args.internal_txt else []

    all_short_names = _get_all_short_names(manifest)
    excluded_names = _get_excluded_short_names(manifest)
    root_modules = _get_root_modules(modules)

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
        chart_modules = _parse_chart_yaml_modules(args.chart_yaml)
        for cm in chart_modules:
            if cm not in root_modules:
                errors.append(f"Chart.yaml module '{cm}' has no root entry in bundle-manifest.yaml")

    # Check 4: Orphaned manifest modules
    check_num += 1
    log.info(f"[{check_num}/{total_checks}] Checking for orphaned manifest modules...")
    if args.chart_yaml and os.path.exists(args.chart_yaml):
        chart_modules = _parse_chart_yaml_modules(args.chart_yaml)
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
    paths = _get_all_bucket_paths(modules)
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
        chart_images = _scan_chart_templates(args.harness_dir)
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
    child_count = len(_get_child_modules(modules))
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
        sys.exit(1)

    print("=== ERRORS (0) ===")
    print("Validation PASSED")


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="SMP tools: bundle image generation and Helm flag extraction",
        epilog="Use 'smp-tools.py <subcommand> --help' for subcommand-specific help.",
    )
    subparsers = parser.add_subparsers(dest="command", required=True, help="Subcommand to run")

    # bundle-images
    bp = subparsers.add_parser("bundle-images", help="Resolve bundle manifest to produce images.txt and images_internal.txt")
    bp.add_argument("--manifest", required=True, help="Path to bundle-manifest.yaml")
    bp.add_argument("--raw-images", help="Path to images_raw.txt")
    bp.add_argument("--output-dir", help="Output directory for images.txt and images_internal.txt")
    bp.add_argument("--internal-only", action="store_true",
                    help="Regenerate only images_internal.txt from existing images.txt")
    bp.add_argument("--images-txt", help="Path to existing images.txt (for --internal-only mode)")
    bp.set_defaults(func=cmd_bundle_images)

    # auto-enable-flags
    ap = subparsers.add_parser("auto-enable-flags", help="Emit --set flags from a Helm values YAML file")
    ap.add_argument("values_yaml", help="Path to the YAML file to scan")
    ap.add_argument(
        "--mode",
        choices=["false", "true"],
        default="false",
        help=(
            "'false' (default): emit flags for every enabled/create that is False "
            "(use with values.yaml to flip disabled features on). "
            "'true': emit flags for every enabled/create that is True "
            "(use with generate-image.yaml to forward explicit overrides as --set flags)."
        ),
    )
    ap.set_defaults(func=cmd_auto_enable_flags)

    # validate-bundle
    vp = subparsers.add_parser("validate-bundle", help="Validate bundle-manifest.yaml against images_raw.txt, images.txt, images_internal.txt, and chart templates")
    vp.add_argument("--manifest", required=True, help="Path to bundle-manifest.yaml")
    vp.add_argument("--raw-images", help="Path to images_raw.txt")
    vp.add_argument("--images-txt", help="Path to images.txt")
    vp.add_argument("--internal-txt", help="Path to images_internal.txt")
    vp.add_argument("--chart-yaml", help="Path to Chart.yaml")
    vp.add_argument("--harness-dir", help="Path to harness chart directory (for template scanning)")
    vp.set_defaults(func=cmd_validate_bundle)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
