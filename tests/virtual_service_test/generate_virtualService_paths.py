import yaml
from jinja2 import Template
import re
import sys
import argparse
import os

# Load OpenAPI specification
def load_openapi_spec(file_path):
    with open(file_path, 'r') as file:
        return yaml.safe_load(file)

PATH_VERSION_RE = re.compile(r'^/(v\d+)(/|$)')
SERVER_VERSION_RE = re.compile(r'/(v\d+)(?:/|$)')

def get_version_from_servers(openapi_spec):
    """Get the API version from servers.url (e.g. /api/v1 -> v1).

    Some specs keep the version only in servers.url instead of in each path.
    """
    for server in openapi_spec.get('servers') or []:
        match = SERVER_VERSION_RE.search(server.get('url') or '')
        if match:
            return match.group(1)

    return None

def extract_paths(openapi_spec):
    """Extract paths from the OpenAPI specification."""
    paths = openapi_spec.get('paths', {})
    formatted_paths = set()

    # Specs that already version their paths are used as-is; only specs that
    # keep the version in servers.url need it added back to every path.
    version = None
    if not any(PATH_VERSION_RE.match(path) for path in paths):
        version = get_version_from_servers(openapi_spec)

    for path in paths:
        if version:
            path = f"/{version}{path}"
        # Convert {variables} directly to [^\/]+ for more precise matching
        regex_path = re.sub(r'\{[^}]+\}', '[^\\/]+', path)
        formatted_paths.add(regex_path)

    return formatted_paths

def group_paths_by_version(paths):
    """Group versioned API paths (any /vN/) into one list per version."""
    grouped = {}
    sort_key = lambda path: (-len([seg for seg in path.split('/') if seg]), path)

    for path in paths:
        match = PATH_VERSION_RE.match(path)
        if not match:
            continue
        grouped.setdefault(match.group(1), []).append(path)

    return {version: sorted(grouped[version], key=sort_key) for version in sorted(grouped)}

virtual_service_template = """virtualService:
  annotations: {}
  objects:
    - name: {{ service_name }}-{{ version }}-apis
      pathMatchType: regex
      pathRewrite: "/\\\\1"
      paths:
{%- for path in paths %}
        - path: '{{ global_prefix }}/({{ path[1:] }}){% if not path.startswith("/v") %}\/?{% else %}\/?${% endif %}'
{%- endfor %}
"""

def generate_virtual_service(global_prefix, paths, service_name):
    """Generate virtual service configuration with grouped paths."""
    grouped_paths = group_paths_by_version(paths)
    result = ["virtualService:", "  annotations: {}", "  objects:"]
    
    for version, version_paths in grouped_paths.items():
        template = Template(virtual_service_template.split('\n', 3)[3])  # Skip the header
        result.append(template.render(
            global_prefix=global_prefix,
            paths=version_paths,
            service_name=service_name,
            version=version
        ))
    
    return '\n'.join(result)

def merge_paths(all_paths):
    """Merge multiple sets of paths and sort them"""
    merged_paths = set()
    for paths in all_paths:
        merged_paths.update(paths)
    
    # Sort by number of segments (longest first) and then alphabetically
    sort_key = lambda path: (-len([seg for seg in path.split('/') if seg]), path)
    return sorted(list(merged_paths), key=sort_key)

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description='Generate virtual service configuration from OpenAPI spec')
    parser.add_argument('service_name', help='Service name for the virtual service')
    parser.add_argument('openapi_paths', nargs='+', help='Paths to openapi.yaml files')
    
    # Parse arguments
    args = parser.parse_args()

    # Load specifications and extract paths from all files
    all_extracted_paths = []
    for openapi_path in args.openapi_paths:
        if os.path.exists(openapi_path):
            try:
                openapi_spec = load_openapi_spec(openapi_path)
                extracted_paths = extract_paths(openapi_spec)
                all_extracted_paths.append(extracted_paths)
                print(f"Loaded paths from {openapi_path}", file=sys.stderr)
            except Exception as e:
                print(f"Error loading {openapi_path}: {e}", file=sys.stderr)
    
    if not all_extracted_paths:
        print("No valid OpenAPI specifications were loaded", file=sys.stderr)
        sys.exit(1)
    
    # Merge and sort paths
    merged_paths = merge_paths(all_extracted_paths)
    
    # Generate and print virtual service configuration
    virtual_service_config = generate_virtual_service(
        "{{ .Values.global.istio.virtualService.pathPrefix }}", 
        merged_paths,
        args.service_name
    )
    print(virtual_service_config)

if __name__ == "__main__":
    main()
