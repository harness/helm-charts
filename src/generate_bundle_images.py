#!/usr/bin/env python3
"""
Resolve bundle-manifest.yaml against images_raw.txt to produce:
  - images.txt       (customer-facing, hierarchical sections, committed)
  - images_internal.txt  (transient, metadata annotations for bundling)

When called with --internal-only, regenerates only images_internal.txt
from an existing images.txt + bundle-manifest.yaml (used in airgap pipeline).
"""

import argparse
import logging
import os
import sys

try:
    import yaml
except ImportError:
    print("[ERROR] PyYAML is required. Install with: pip install pyyaml", file=sys.stderr)
    sys.exit(1)

logging.basicConfig(format='[%(levelname)-5s] %(message)s', level=logging.INFO)
log = logging.getLogger(__name__)


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


def resolve_variants(image_entry, section_variants, global_variants):
    """
    Resolve variant suffixes using cascading: image > section > global.
    Returns list of suffixes to append to each base tag.
    """
    if isinstance(image_entry, dict) and 'variants' in image_entry:
        suffixes = image_entry['variants'].get('suffixes', [])
        extra = image_entry['variants'].get('extra_suffixes', [])
        if extra:
            parent_suffixes = section_variants.get('suffixes', []) if section_variants else global_variants.get('suffixes', [])
            return list(set(parent_suffixes + extra))
        return suffixes

    if section_variants:
        return section_variants.get('suffixes', [])

    return global_variants.get('suffixes', [])


def get_image_short_name(image_entry):
    if isinstance(image_entry, dict):
        return image_entry['name']
    return image_entry


def process_section(name, config, raw_images, global_variants):
    """
    Process a single module section uniformly.
    Returns (customer_lines, internal_lines, resolved_images, excluded_images, errors).
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
    excluded_images = []
    errors = []

    if parent:
        internal_header = f"# @module={name} @type={bundle_type} @path={bucket_path} @parent={parent}"
    else:
        requires_str = ','.join(requires) if requires else ''
        internal_header = f"# @module={name} @type={bundle_type} @path={bucket_path} @requires={requires_str}"

    internal_lines.append(internal_header)

    for short_name in exclude_list:
        matches = find_matching_images(short_name, raw_images)
        for match in matches:
            customer_lines.append(match)
            resolved_images.append(match)
            excluded_images.append(match)

    for image_entry in images_list:
        short_name = get_image_short_name(image_entry)
        matches = find_matching_images(short_name, raw_images)

        if not matches:
            errors.append(f"Image '{short_name}' in section '{name}' not found in images_raw.txt")
            continue

        suffixes = resolve_variants(image_entry, section_variants, global_variants)

        if bundle_type == 'single':
            internal_lines.append(f"# @image={short_name}")

        for match in matches:
            customer_lines.append(match)
            resolved_images.append(match)
            internal_lines.append(match)

            for suffix in suffixes:
                variant_image = f"{match}{suffix}"
                customer_lines.append(variant_image)
                resolved_images.append(variant_image)
                internal_lines.append(variant_image)

    return customer_lines, internal_lines, resolved_images, excluded_images, errors


def generate(manifest, raw_images):
    """
    Main generation logic. Returns (customer_text, internal_text, all_resolved, all_excluded, all_errors).
    """
    global_variants = manifest.get('global_variants', {'suffixes': []})
    modules = manifest.get('modules', {})

    all_customer_lines = []
    all_internal_lines = []
    all_resolved = []
    all_excluded = []
    all_errors = []

    total = len(modules)

    for idx, (name, config) in enumerate(modules.items(), 1):
        parent = config.get('parent')
        log.info(f"[{idx}/{total}] Processing: {name}")

        customer, internal, resolved, excluded, errors = process_section(
            name, config, raw_images, global_variants
        )

        header_prefix = "###" if parent else "##"
        header = f"{header_prefix} {config.get('description', name)}"
        all_customer_lines.append(header)
        all_customer_lines.extend(customer)
        all_customer_lines.append('')

        all_internal_lines.extend(internal)
        all_internal_lines.append('')
        all_resolved.extend(resolved)
        all_excluded.extend(excluded)
        all_errors.extend(errors)

    customer_text = '\n'.join(all_customer_lines).rstrip() + '\n'
    internal_text = '\n'.join(all_internal_lines).rstrip() + '\n'

    return customer_text, internal_text, all_resolved, all_excluded, all_errors


def generate_internal_only(manifest, images_txt_path):
    """
    Regenerate images_internal.txt from committed images.txt + manifest.
    Parses section headers in images.txt to map images back to modules.
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

    internal_lines = []
    for desc, imgs in sections:
        if desc not in desc_to_module:
            continue

        mod_name, mod_config = desc_to_module[desc]
        bundle_type = mod_config.get('bundle_type', 'combined')
        bucket_path = mod_config.get('bucket_path', mod_name)
        parent = mod_config.get('parent')
        non_excluded_imgs = [img for img in imgs if not is_image_excluded(img)]

        if parent:
            internal_lines.append(f"# @module={mod_name} @type={bundle_type} @path={bucket_path} @parent={parent}")
        else:
            requires = ','.join(mod_config.get('requires', []))
            internal_lines.append(f"# @module={mod_name} @type={bundle_type} @path={bucket_path} @requires={requires}")

        if bundle_type == 'single':
            current_base = None
            for img in non_excluded_imgs:
                base = img.rsplit(':', 1)[0] if ':' in img else img
                short = base.rsplit('/', 1)[-1] if '/' in base else base
                if short != current_base:
                    internal_lines.append(f"# @image={short}")
                    current_base = short
                internal_lines.append(img)
        else:
            internal_lines.extend(non_excluded_imgs)
        internal_lines.append('')

    return '\n'.join(internal_lines).rstrip() + '\n'


def main():
    parser = argparse.ArgumentParser(description='Resolve bundle manifest against raw images')
    parser.add_argument('--manifest', required=True, help='Path to bundle-manifest.yaml')
    parser.add_argument('--raw-images', help='Path to images_raw.txt')
    parser.add_argument('--output-dir', help='Output directory for images.txt and images_internal.txt')
    parser.add_argument('--internal-only', action='store_true',
                        help='Regenerate only images_internal.txt from existing images.txt')
    parser.add_argument('--images-txt', help='Path to existing images.txt (for --internal-only mode)')
    args = parser.parse_args()

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
        internal_text = generate_internal_only(manifest, images_txt)

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

    customer_text, internal_text, resolved, excluded, errors = generate(manifest, raw_images)

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


if __name__ == '__main__':
    main()
