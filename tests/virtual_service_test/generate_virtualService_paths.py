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

def extract_paths(openapi_spec):
    """Extract paths from the OpenAPI specification."""
    paths = openapi_spec.get('paths', {})
    formatted_paths = set()

    for path in paths:
        # Convert {variables} directly to [^\/.]+ for more precise matching
        regex_path = re.sub(r'\{[^}]+\}', '[^\\/.]+', path)
        formatted_paths.add(regex_path)

    return formatted_paths

def group_paths_by_version(paths):
    """Group paths by their version (v1, v2)"""
    v1_paths = []
    v2_paths = []
    
    for path in paths:
        if path.startswith('/v1/'):
            v1_paths.append(path)
        elif path.startswith('/v2/'):
            v2_paths.append(path)
    
    # Sort by number of segments (longest first) and then alphabetically
    sort_key = lambda path: (-len([seg for seg in path.split('/') if seg]), path)
    
    return {
        'v1': sorted(v1_paths, key=sort_key),
        'v2': sorted(v2_paths, key=sort_key)
    }

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
    
    # Generate v1 paths
    if grouped_paths['v1']:
        template = Template(virtual_service_template.split('\n', 3)[3])  # Skip the header
        result.append(template.render(
            global_prefix=global_prefix,
            paths=grouped_paths['v1'],
            service_name=service_name,
            version='v1'
        ))
    
    # Generate v2 paths
    if grouped_paths['v2']:
        template = Template(virtual_service_template.split('\n', 3)[3])  # Skip the header
        result.append(template.render(
            global_prefix=global_prefix,
            paths=grouped_paths['v2'],
            service_name=service_name,
            version='v2'
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
