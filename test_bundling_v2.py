#!/usr/bin/env python3
"""
Comprehensive test plan for the minimal SMP bundling v2.

Validates new bundle-manifest.yaml + generate_bundle_images.py against:
  - Original images.txt from git HEAD (the old flat list)
  - Old airgap_input.txt (the legacy module-to-image mapping)
  - Old generate-image-list.sh variant logic (hardcoded suffixes)
  - Internal consistency of generated outputs

Each test either PASSES or FAILS with a clear explanation.
"""
import os
import re
import sys
import subprocess

try:
    import yaml
except ImportError:
    print("[FATAL] PyYAML required: pip install pyyaml", file=sys.stderr)
    sys.exit(1)

HELM_DIR = os.path.dirname(os.path.abspath(__file__))
MANIFEST_PATH = os.path.join(HELM_DIR, "src/bundle-manifest.yaml")
IMAGES_TXT = os.path.join(HELM_DIR, "src/harness/images.txt")
IMAGES_INTERNAL = os.path.join(HELM_DIR, "src/harness/images_internal.txt")
IMAGES_RAW = os.path.join(HELM_DIR, "src/harness/images_raw.txt")
ORIGINAL_IMAGES = "/tmp/original_images.txt"
AIRGAP_INPUT = os.path.join(HELM_DIR, "src/airgap/airgap_input.txt")

passed = 0
failed = 0
results = []


def test(name, condition, detail=""):
    global passed, failed
    if condition:
        passed += 1
        results.append(("PASS", name, detail))
    else:
        failed += 1
        results.append(("FAIL", name, detail))


def load_lines(path, skip_comments=True, skip_headers=True):
    lines = []
    if not os.path.exists(path):
        return lines
    with open(path) as f:
        for line in f:
            s = line.strip()
            if not s:
                continue
            if skip_comments and s.startswith('#'):
                continue
            if skip_headers and s.startswith('##'):
                continue
            lines.append(s)
    return lines


def load_manifest():
    with open(MANIFEST_PATH) as f:
        return yaml.safe_load(f)


def normalize_image(img):
    """Normalize image ref: ensure docker.io/ prefix for harness/ and plugins/."""
    if img.startswith("harness/") or img.startswith("plugins/"):
        return f"docker.io/{img}"
    return img


def parse_old_airgap_input():
    modules = {}
    current = None
    with open(AIRGAP_INPUT) as f:
        for line in f:
            line = line.rstrip()
            m = re.match(r'^\[([^\]]+)\]:', line)
            if m:
                current = m.group(1)
                modules[current] = []
            elif current and line.strip():
                modules[current].append(line.strip())
    return modules


print("=" * 70)
print("MINIMAL SMP BUNDLING V2 - TEST PLAN")
print("=" * 70)
print()

# Prerequisite: files exist
for path, label in [
    (MANIFEST_PATH, "bundle-manifest.yaml"),
    (IMAGES_TXT, "images.txt (generated)"),
    (IMAGES_INTERNAL, "images_internal.txt (generated)"),
    (IMAGES_RAW, "images_raw.txt"),
    (ORIGINAL_IMAGES, "original images.txt (git HEAD)"),
    (AIRGAP_INPUT, "airgap_input.txt (old)"),
]:
    test(f"File exists: {label}", os.path.exists(path), path)

manifest = load_manifest()
modules = manifest.get("modules", {})
original_lines = load_lines(ORIGINAL_IMAGES)
new_images_txt = load_lines(IMAGES_TXT)
new_internal = load_lines(IMAGES_INTERNAL)
raw_images = load_lines(IMAGES_RAW)

root_modules = {k for k, v in modules.items() if not v.get('parent')}
child_modules = {k for k, v in modules.items() if v.get('parent')}

# Collect all short names (images + exclude lists)
all_manifest_shorts = set()
for mod_config in modules.values():
    for entry in mod_config.get("images", []):
        all_manifest_shorts.add(entry["name"] if isinstance(entry, dict) else entry)
    all_manifest_shorts.update(mod_config.get("exclude", []))

# Collect excluded names
excluded_names = set()
for mod_config in modules.values():
    excluded_names.update(mod_config.get("exclude", []))

# component-analysis-service-signed was in airgap_input.txt but never in chart images
KNOWN_NOT_IN_CHARTS = {"component-analysis-service-signed"}

# ---------------------------------------------------------------
# TEST 1: Every image from original images.txt in new images.txt (normalized)
# ---------------------------------------------------------------
print("\n--- TEST 1: Original images.txt coverage ---")
original_normalized = {normalize_image(img) for img in set(original_lines)}
new_normalized = {normalize_image(img) for img in set(new_images_txt)}
new_set = set(new_images_txt)
missing_from_new = original_normalized - new_normalized
test(
    "All original images present in new images.txt (normalized)",
    len(missing_from_new) == 0,
    f"Missing {len(missing_from_new)}: {sorted(missing_from_new)[:10]}" if missing_from_new else "All matched"
)

# ---------------------------------------------------------------
# TEST 2: airgap_input.txt -> manifest migration
# ---------------------------------------------------------------
print("\n--- TEST 2: airgap_input.txt -> manifest migration ---")
old_modules = parse_old_airgap_input()
missing_from_manifest = set()
for shorts in old_modules.values():
    for s in shorts:
        if s not in all_manifest_shorts and s not in KNOWN_NOT_IN_CHARTS:
            missing_from_manifest.add(s)
test(
    "All airgap_input.txt short names exist in bundle-manifest.yaml (excl. known gaps)",
    len(missing_from_manifest) == 0,
    f"Missing: {sorted(missing_from_manifest)}" if missing_from_manifest else "All mapped"
)
test(
    "Known gap: component-analysis-service-signed documented",
    "component-analysis-service-signed" not in all_manifest_shorts,
    "Not in charts yet, excluded from manifest until chart adds it"
)

# ---------------------------------------------------------------
# TEST 3: Variant generation parity
# ---------------------------------------------------------------
print("\n--- TEST 3: Variant generation parity ---")
OLD_VARIANT_RULES = {
    "delegate": [".minimal", ".minimal-fips", "-fips"],
    "upgrader": ["-fips"],
    "aqua-trivy-job-runner": ["-fips"],
    "bandit-job-runner": ["-fips"],
    "grype-job-runner": ["-fips"],
    "osv-job-runner": ["-fips"],
    "sonarqube-agent-job-runner": ["-fips"],
    "semgrep-job-runner": ["-fips"],
}

variant_issues = []
for short_name, expected_suffixes in OLD_VARIANT_RULES.items():
    base_matches = [img for img in new_set if f"/{short_name}:" in img and not any(img.endswith(s) for s in expected_suffixes)]
    for base in base_matches:
        for suffix in expected_suffixes:
            if f"{base}{suffix}" not in new_set:
                variant_issues.append(f"{short_name}: missing {suffix} variant for {base}")

test("Old variant suffixes all present in new images.txt", len(variant_issues) == 0,
     "\n    ".join(variant_issues[:10]) if variant_issues else "All variant parity matched")

NEW_FIPS_SCANNERS = [
    "anchore-job-runner", "aqua-security-job-runner", "aws-ecr-job-runner",
    "aws-security-hub-job-runner", "blackduckhub-job-runner", "brakeman-job-runner",
    "burp-job-runner", "checkmarx-job-runner", "checkov-job-runner",
    "docker-content-trust-job-runner", "fossa-job-runner",
    "github-advanced-security-job-runner", "gitleaks-job-runner",
    "modelscan-job-runner", "nexusiq-job-runner", "nikto-job-runner",
    "nmap-job-runner", "owasp-dependency-check-job-runner", "prowler-job-runner",
    "shiftleft-job-runner", "snyk-job-runner", "sysdig-job-runner",
    "traceable-job-runner", "twistlock-job-runner", "veracode-agent-job-runner",
    "whitesource-agent-job-runner", "wiz-job-runner", "zap-job-runner"
]
fips_count = sum(1 for s in NEW_FIPS_SCANNERS if any(f"/{s}:" in img and img.endswith("-fips") for img in new_set))
test("New module-level -fips variants applied to all sto-scanners",
     fips_count == len(NEW_FIPS_SCANNERS), f"{fips_count}/{len(NEW_FIPS_SCANNERS)}")

# ---------------------------------------------------------------
# TEST 4: Exclude mechanism
# ---------------------------------------------------------------
print("\n--- TEST 4: exclude mechanism ---")
test("Excluded images defined in manifest", len(excluded_names) > 0, f"Excluded: {sorted(excluded_names)}")

for name in excluded_names:
    test(f"Excluded '{name}' present in images.txt", any(f"/{name}:" in img for img in new_set))

internal_set = set(new_internal)
for name in excluded_names:
    test(f"Excluded '{name}' absent from images_internal.txt", not any(f"/{name}:" in img for img in internal_set))

# ---------------------------------------------------------------
# TEST 5: images_raw.txt full coverage
# ---------------------------------------------------------------
print("\n--- TEST 5: images_raw.txt -> manifest coverage ---")
unmapped = [img for img in set(raw_images) if not any(f"/{sn}:" in img for sn in all_manifest_shorts)]
test("Every image in images_raw.txt maps to a manifest entry", len(unmapped) == 0,
     f"Unmapped: {sorted(unmapped)}" if unmapped else "All covered")

# ---------------------------------------------------------------
# TEST 6: Manifest structural integrity
# ---------------------------------------------------------------
print("\n--- TEST 6: Manifest structural integrity ---")

bad_requires = [f"{k} -> {r}" for k, v in modules.items() for r in v.get('requires', []) if r not in modules]
test("All dependency references are valid", len(bad_requires) == 0, str(bad_requires))

bad_parents = [f"{k} -> {v.get('parent')}" for k, v in modules.items() if v.get('parent') and v['parent'] not in modules]
test("All parent references are valid", len(bad_parents) == 0, str(bad_parents))

def has_cycle(name, visited, stack):
    visited.add(name)
    stack.add(name)
    for req in modules.get(name, {}).get('requires', []):
        if req in stack:
            return True
        if req not in visited and has_cycle(req, visited, stack):
            return True
    stack.discard(name)
    return False

test("No circular dependencies", not any(has_cycle(m, set(), set()) for m in modules))

paths = [v.get('bucket_path', k) for k, v in modules.items()]
test("All bucket_path values are unique", len(paths) == len(set(paths)))

# Flat structure: no 'children' key anywhere
has_children_key = any('children' in v for v in modules.values())
test("No 'children' key in manifest (flat structure)", not has_children_key,
     "Found 'children' key - should use 'parent' field instead" if has_children_key else "")

# ---------------------------------------------------------------
# TEST 7: images_internal.txt metadata structure
# ---------------------------------------------------------------
print("\n--- TEST 7: images_internal.txt metadata structure ---")
with open(IMAGES_INTERNAL) as f:
    internal_content = f.read()

module_headers = re.findall(r'^# @module=(\S+)', internal_content, re.MULTILINE)
test("images_internal.txt has correct number of @module headers",
     len(module_headers) == len(modules), f"Expected {len(modules)}, got {len(module_headers)}")

image_markers = re.findall(r'^# @image=(\S+)', internal_content, re.MULTILINE)
test("Single-type sections have @image markers", len(image_markers) > 0, f"Found {len(image_markers)}")

# Check parent modules use @parent, root modules use @requires
parent_headers = re.findall(r'@parent=(\S+)', internal_content)
requires_headers = re.findall(r'@requires=', internal_content)
test("Parent modules use @parent annotation", len(parent_headers) == len(child_modules),
     f"Expected {len(child_modules)}, got {len(parent_headers)}")
test("Root modules use @requires annotation", len(requires_headers) == len(root_modules),
     f"Expected {len(root_modules)}, got {len(requires_headers)}")

# ---------------------------------------------------------------
# TEST 8: --internal-only mode consistency
# ---------------------------------------------------------------
print("\n--- TEST 8: --internal-only mode ---")
test_dir = "/tmp/bundling_test_internal_only"
os.makedirs(test_dir, exist_ok=True)
result = subprocess.run(
    ["python3", os.path.join(HELM_DIR, "src/generate_bundle_images.py"),
     "--manifest", MANIFEST_PATH, "--internal-only",
     "--images-txt", IMAGES_TXT, "--output-dir", test_dir],
    capture_output=True, text=True
)
test("--internal-only mode exits successfully", result.returncode == 0, result.stderr.strip())
if result.returncode == 0:
    with open(IMAGES_INTERNAL) as f:
        orig = f.read()
    with open(os.path.join(test_dir, "images_internal.txt")) as f:
        regen = f.read()
    test("--internal-only output matches full generation", orig == regen,
         f"Full: {len(orig)} chars, Regen: {len(regen)} chars")

# ---------------------------------------------------------------
# TEST 9: Validation script passes
# ---------------------------------------------------------------
print("\n--- TEST 9: validate_bundle_manifest.py ---")
result = subprocess.run(
    ["python3", os.path.join(HELM_DIR, "src/validate_bundle_manifest.py"),
     "--manifest", MANIFEST_PATH, "--raw-images", IMAGES_RAW,
     "--images-txt", IMAGES_TXT, "--internal-txt", IMAGES_INTERNAL],
    capture_output=True, text=True
)
test("Validation script passes", result.returncode == 0, result.stdout.strip()[-200:])

# ---------------------------------------------------------------
# TEST 10: Old module -> new module mapping
# ---------------------------------------------------------------
print("\n--- TEST 10: Old -> new module mapping ---")
MODULE_MAP = {
    "platform": "platform", "ci": "ci", "cdng": "cdng", "sto": "sto",
    "ff": "ff", "ccm": "ccm", "ce": "ce", "ssca": "ssca",
    "db-devops": "dbdevops", "code": "code", "iacm": "iacm", "idp": "idp",
}

for old_mod, new_mod in MODULE_MAP.items():
    test(f"Old [{old_mod}] -> manifest '{new_mod}'", new_mod in modules)

old_to_new_issues = []
for old_mod, old_shorts in old_modules.items():
    new_mod = MODULE_MAP.get(old_mod)
    if not new_mod or new_mod not in modules:
        continue
    # Collect all shorts in this module + its children (modules with parent=new_mod)
    new_mod_shorts = set()
    for entry in modules[new_mod].get("images", []):
        new_mod_shorts.add(entry["name"] if isinstance(entry, dict) else entry)
    new_mod_shorts.update(modules[new_mod].get("exclude", []))
    for k, v in modules.items():
        if v.get('parent') == new_mod:
            for entry in v.get("images", []):
                new_mod_shorts.add(entry["name"] if isinstance(entry, dict) else entry)
            new_mod_shorts.update(v.get("exclude", []))
    for old_s in set(old_shorts):
        if old_s not in new_mod_shorts and old_s not in KNOWN_NOT_IN_CHARTS:
            old_to_new_issues.append(f"[{old_mod}] {old_s} not in {new_mod} or sub-bundles")

test("Every old module image in corresponding new module (or sub-bundles)",
     len(old_to_new_issues) == 0, "\n    ".join(old_to_new_issues) if old_to_new_issues else "All mapped")

# ---------------------------------------------------------------
# TEST 11: images.txt section structure
# ---------------------------------------------------------------
print("\n--- TEST 11: images.txt structure ---")
with open(IMAGES_TXT) as f:
    content = f.read()

h2_count = len(re.findall(r'^## ', content, re.MULTILINE))
h3_count = len(re.findall(r'^### ', content, re.MULTILINE))
test("images.txt ## headers = root modules", h2_count == len(root_modules),
     f"Expected {len(root_modules)}, got {h2_count}")
test("images.txt ### headers = child modules", h3_count == len(child_modules),
     f"Expected {len(child_modules)}, got {h3_count}")

# ---------------------------------------------------------------
# TEST 12: No unexpected extra images
# ---------------------------------------------------------------
print("\n--- TEST 12: No unexpected extra images ---")
extra = new_normalized - original_normalized
expected_new = {normalize_image(img) for s in NEW_FIPS_SCANNERS for img in new_set if f"/{s}:" in img and img.endswith("-fips")}
unexpected = extra - expected_new
test("No unexpected extras beyond new -fips variants", len(unexpected) == 0,
     f"Unexpected ({len(unexpected)}): {sorted(unexpected)[:10]}" if unexpected else "Clean")

# ---------------------------------------------------------------
# TEST 13: BUNDLE_SECTIONS
# ---------------------------------------------------------------
print("\n--- TEST 13: BUNDLE_SECTIONS ---")
sections_list = list(modules.keys())
test("Total sections = 18", len(sections_list) == 18, f"Got {len(sections_list)}")
test("No duplicate section names", len(sections_list) == len(set(sections_list)))

# ---------------------------------------------------------------
# SUMMARY
# ---------------------------------------------------------------
print()
print("=" * 70)
print(f"TEST RESULTS: {passed} PASSED, {failed} FAILED, {passed + failed} TOTAL")
print("=" * 70)
print()
for status, name, detail in results:
    line = f"  [{status}] {name}"
    if detail and status == "FAIL":
        line += f"\n         {detail}"
    print(line)

if failed:
    print(f"\n{failed} test(s) FAILED.")
    sys.exit(1)
else:
    print(f"\nAll {passed} tests PASSED.")
    sys.exit(0)
