#!/usr/bin/env python3
"""
Scan a Helm YAML file and emit --set <path>=true flags for 'enabled' and
'create' keys matching the requested value mode.

Usage:
    # Flip every disabled flag to true (for values.yaml — the default mode):
    python3 auto-enable-flags.py <values.yaml>
    python3 auto-enable-flags.py --mode false <values.yaml>

    # Emit flags for every already-true override (for generate-image.yaml):
    python3 auto-enable-flags.py --mode true <generate-image.yaml>

Output (one flag per line, ready for shell command substitution):
    --set global.ci.enabled=true
    --set platform.bootstrap.networking.nginx.create=true
    ...

BLOCKLIST: paths that must never be emitted even if they appear in the file
(unsupported features or ones requiring external infrastructure).
"""

import argparse
import sys

try:
    import yaml
except ImportError:
    print("[ERROR] PyYAML is required: pip install pyyaml", file=sys.stderr)
    sys.exit(1)

# Paths that must NOT be emitted regardless of mode.
BLOCKLIST = {
    "global.lwd.enabled",
    "global.lwd.autocud.enabled",
}

FLAG_KEYS = {"enabled", "create"}


def collect_flags(data, target_value, path=""):
    """Walk the YAML tree and print --set flags for matching keys."""
    if not isinstance(data, dict):
        return
    for key, value in data.items():
        dotted = f"{path}.{key}" if path else key
        if key in FLAG_KEYS and value is target_value:
            # Skip bare top-level keys (no namespace) and blocklisted paths.
            if "." not in dotted or dotted in BLOCKLIST:
                continue
            print(f"--set {dotted}=true")
        elif isinstance(value, dict):
            collect_flags(value, target_value, dotted)


def main():
    parser = argparse.ArgumentParser(
        description="Emit --set flags from a Helm values YAML file"
    )
    parser.add_argument(
        "values_yaml",
        help="Path to the YAML file to scan",
    )
    parser.add_argument(
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
    args = parser.parse_args()

    try:
        with open(args.values_yaml) as f:
            data = yaml.safe_load(f)
    except FileNotFoundError:
        print(f"[ERROR] File not found: {args.values_yaml}", file=sys.stderr)
        sys.exit(1)

    target_value = args.mode == "true"

    if data:
        collect_flags(data, target_value)


if __name__ == "__main__":
    main()
