#!/usr/bin/env python3

"""
Virtual Service Path Validation Script

This script validates that virtual service paths in Helm charts match
the corresponding OpenAPI specifications.
"""

import os
import sys
import subprocess
import tempfile
import yaml
import argparse
import requests
import json
from pathlib import Path

def run_command(cmd, capture_output=True):
    """Run a shell command and return its output"""
    try:
        result = subprocess.run(cmd, shell=True, check=True, text=True, 
                                capture_output=capture_output)
        return result.stdout.strip() if capture_output else None
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {cmd}")
        print(f"Error message: {e.stderr}")
        sys.exit(1)

def get_current_dir_name():
    """Get the name of the current directory"""
    return os.path.basename(os.path.abspath(os.getcwd()))

def get_changed_files_from_api(repo_name, pr_number, harness_token):
    """Get files changed in PR using Harness API"""
    try:
        api_url = f"https://harness0.harness.io/gateway/code/api/v1/repos/{repo_name}/pullreq/{pr_number}/diff?accountIdentifier=l7B_kbSEQD2wjrM7PShm5w&orgIdentifier=PROD&projectIdentifier=Harness_Commons&routingId=l7B_kbSEQD2wjrM7PShm5w"
        
        headers = {
            'x-api-key': harness_token
        }
        
        print(f"🔍 Fetching changed files from API: {api_url}")
        response = requests.get(api_url, headers=headers)
        
        if response.status_code != 200:
            print(f"❌ Error fetching changed files: HTTP {response.status_code}")
            print(f"Response: {response.text}")
            return []
        
        diff_data = response.json()
        changed_files = [item['path'] for item in diff_data if 'path' in item]
        
        print(f"📁 Found {len(changed_files)} changed files")
        for file in changed_files:
            print(f"  - {file}")
            
        return changed_files
        
    except Exception as e:
        print(f"❌ Error getting changed files from API: {e}")
        return []

def get_changed_files(repo_name=None):
    """Get files changed between current and previous commit (fallback method)"""
    try:
        cmd = "git diff --name-only || true"
        if repo_name:
            cmd = f"cd {repo_name} && {cmd}"
        output = run_command(cmd)
        return output.splitlines() if output else []
    except Exception as e:
        print(f"Error getting changed files: {e}")
        return []

def load_mapping():
    """Load the openapi mapping yaml file"""
    # Try different possible paths for the mapping file
    possible_paths = [
        'openapimapping.yml',  # Current directory
        'virtual_service_test/openapimapping.yml',  # Subdirectory
        '/harness-temp/helm-charts/tests/virtual_service_test/openapimapping.yml'  # Pipeline path
    ]
    
    for path in possible_paths:
        try:
            if os.path.exists(path):
                print(f"📋 Loading mapping from: {path}")
                with open(path, 'r') as f:
                    return yaml.safe_load(f)
        except yaml.YAMLError as e:
            print(f"Error parsing {path}: {e}")
            continue
    
    print("❌ Error: openapimapping.yml file not found in any expected location")
    print("Searched paths:")
    for path in possible_paths:
        print(f"  - {path}")
    sys.exit(1)

def find_api_specs_for_chart(chart_path, mapping):
    """Find all API specs associated with a chart path"""
    # Find the key in the mapping that matches this chart
    for chart_key, api_specs in mapping.items():
        if chart_path.endswith(chart_key):
            return api_specs
    
    return []

def find_api_specs_containing_file(file_path, mapping):
    """Find all API specs in arrays that contain the changed file"""
    result = []
    
    # Check each array in the mapping for the file path
    for chart_key, api_specs in mapping.items():
        if any(api_spec == file_path for api_spec in api_specs):
            result = api_specs
            break
    
    return result

def get_chart_path_from_api_spec(api_spec_path, mapping):
    """Get the chart path associated with an API spec"""
    for chart_key, api_specs in mapping.items():
        if api_spec_path in api_specs:
            return chart_key
    
    return None

def compare_paths(chart_path, api_specs):
    """Compare virtual service paths between generated and existing configuration"""
    # Get the service name from Chart.yaml in the chart folder
    chart_yaml_path = os.path.join(chart_path, 'Chart.yaml')
    try:
        with open(chart_yaml_path, 'r') as f:
            chart_yaml = yaml.safe_load(f)
            service_name = chart_yaml.get('name')
            print(f"📋 Using service name from Chart.yaml: {service_name}")
    except (FileNotFoundError, yaml.YAMLError):
        # Fallback to directory name if Chart.yaml not found or invalid
        service_name = Path(chart_path).name.split('/')[0]
        print(f"⚠️ Chart.yaml not found, using directory name: {service_name}")
        
    print(f"🔄 Service name for virtual service validation: {service_name}")
    
    # Create a temporary file
    with tempfile.NamedTemporaryFile(delete=False) as temp:
        temp_file = temp.name
    
    try:
        # Generate command with all API specs
        api_specs_args = ' '.join(api_specs)
        cmd = f"python3 generate_virtualService_paths.py {service_name} {api_specs_args} > {temp_file}"
        run_command(cmd, capture_output=False)
        
        # Get values.yaml path
        values_file = os.path.join(chart_path, "values.yaml")
        if not os.path.isfile(values_file):
            print(f"Error: values.yaml not found in {chart_path}")
            os.unlink(temp_file)
            sys.exit(1)
        
        print("🔄 Comparing virtual service configuration...")
        
        # Load the generated and existing virtual service configurations
        with open(temp_file, 'r') as f:
            generated_config = yaml.safe_load(f)
        
        with open(values_file, 'r') as f:
            values_config = yaml.safe_load(f)
        
        # Extract the virtual service objects
        if not generated_config.get('virtualService', {}).get('objects'):
            print("Error: No virtualService objects found in generated configuration")
            os.unlink(temp_file)
            sys.exit(1)
            
        if not values_config.get('virtualService', {}).get('objects'):
            print("Error: No virtualService objects found in values.yaml")
            os.unlink(temp_file)
            sys.exit(1)
        
        # Extract paths from values.yaml, only keeping v1 and v2 versioned paths
        values_paths = []
        for obj in values_config.get('virtualService', {}).get('objects', []):
            for path in obj.get('paths', []):
                path_str = path
                if isinstance(path, dict) and 'path' in path:
                    path_str = path['path']
                path_str = path_str.strip()
                # Only include paths that are for v1 or v2 API endpoints
                if '/(v1/' in path_str or '/(v2/' in path_str:
                    values_paths.append(path_str)
        
        # Extract paths from generated config, only keeping v1 and v2 versioned paths
        generated_paths = []
        for obj in generated_config.get('virtualService', {}).get('objects', []):
            for path in obj.get('paths', []):
                path_str = path
                if isinstance(path, dict) and 'path' in path:
                    path_str = path['path']
                path_str = path_str.strip()
                # Only include paths that are for v1 or v2 API endpoints
                if '/(v1/' in path_str or '/(v2/' in path_str:
                    generated_paths.append(path_str)
                    
        values_paths_set = set(values_paths)
        generated_paths_set = set(generated_paths)
        
        # Compare the paths
        if values_paths_set == generated_paths_set:
            print("✅ No changes in virtual service paths")
            return True
        else:
            print("❌ Error: Differences found in virtual service paths:")
            print(" + Paths in generated (from openapi spec) but not in values (from values.yaml)")
            print(" - Paths in values (from values.yaml) but not in generated (from openapi spec)")
            print("=== Differences ===")
            # Paths in values but not in generated
            for path in sorted(values_paths_set - generated_paths_set):
                print(f"- {path}")
            
            # Paths in generated but not in values
            for path in sorted(generated_paths_set - values_paths_set):
                print(f"+ {path}")
            
            print("==================")
            print("\n⚠️ The virtualService paths in values.yaml should be updated to match the generated paths.")
            
            # Find the versioned API objects in values.yaml for this service
            print("\n📋 === Copy-Pasteable YAML for values.yaml (Paste under virtualService.objects) ===\n")
            versioned_objects = {}
            
            for obj in values_config.get('virtualService', {}).get('objects', []):
                name = obj.get('name', '')
                if 'v1' in name or 'v2' in name:
                    version = 'v1' if 'v1' in name else 'v2'
                    path_rewrite = obj.get('pathRewrite')
                    if not path_rewrite:
                        # Add extra backslashes for proper escaping in the YAML output
                        path_rewrite = '/\\\\1'
                    else:
                        # Ensure backslashes are properly escaped
                        path_rewrite = path_rewrite[:-2] + "\\" + path_rewrite[-2:]
                    
                    versioned_objects[version] = {
                        'name': name,
                        'pathMatchType': obj.get('pathMatchType', 'regex'),
                        'pathRewrite': path_rewrite,
                    }
            
            # Group generated paths by version and sort them by segment length (more segments first)
            def sort_by_segment_length(path):
                # Extract the actual API path pattern from inside the parentheses
                import re
                match = re.search(r'\(([^)]+)\)', path)
                if match:
                    api_path = match.group(1)
                    # Count segments (separated by /)
                    segments = [seg for seg in api_path.split('/') if seg]
                    # Return negative length to sort in descending order (more segments first)
                    return -len(segments), api_path
                return 0, path
            
            v1_paths = sorted([p for p in generated_paths_set if '/(v1/' in p], key=sort_by_segment_length)
            v2_paths = sorted([p for p in generated_paths_set if '/(v2/' in p], key=sort_by_segment_length)
            
            # Generate YAML for each version that has paths
            objects_yaml = []
            if v1_paths and 'v1' in versioned_objects:
                v1_obj = versioned_objects['v1']
                v1_yaml = f"    - name: {v1_obj['name']}\n"
                v1_yaml += f"      pathMatchType: {v1_obj['pathMatchType']}\n"
                v1_yaml += f"      pathRewrite: \"{v1_obj['pathRewrite']}\"\n"
                v1_yaml += "      paths:\n"
                for path in v1_paths:
                    v1_yaml += f"        - path: '{path}'\n"
                objects_yaml.append(v1_yaml)
                
            if v2_paths and 'v2' in versioned_objects:
                v2_obj = versioned_objects['v2']
                v2_yaml = f"    - name: {v2_obj['name']}\n"
                v2_yaml += f"      pathMatchType: {v2_obj['pathMatchType']}\n"
                v2_yaml += f"      pathRewrite: \"{v2_obj['pathRewrite']}\"\n"
                v2_yaml += "      paths:\n"
                for path in v2_paths:
                    v2_yaml += f"        - path: '{path}'\n"
                objects_yaml.append(v2_yaml)
                
            if objects_yaml:
                complete_yaml = ''.join(objects_yaml)
                print(complete_yaml)
            
            return False
    
    finally:
        # Clean up temp file if it still exists
        if os.path.exists(temp_file):
            os.unlink(temp_file)

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(
        description='Virtual Service Path Validation Script',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument('--repo_name', required=True,
                        help='Repository name (e.g., harness-core)')
    parser.add_argument('--pr_number', required=True,
                        help='Pull request number')
    parser.add_argument('--harness_token', required=True,
                        help='Harness API token')
    
    args = parser.parse_args()
    
    print(f"🔍 Repository name: {args.repo_name}")
    print(f"🔍 PR number: {args.pr_number}")
    print(f"🔍 Token: {args.harness_token[:10]}...")
    
    # Get changed files from Harness API
    changed_files = get_changed_files_from_api(args.repo_name, args.pr_number, args.harness_token)
    
    if not changed_files:
        print("📝 No changes to files or failed to fetch changes")
        sys.exit(0)
        
    # Load the mapping
    mapping = load_mapping()
    
    # Use provided repo name as directory prefix
    dir_name = args.repo_name
    print(f"🔍 Running validation for repository: {dir_name}")
    
    # Set to track charts that need to be validated to avoid duplicates
    charts_to_validate = {}
    
    # Process changed files
    for file_path in changed_files:
        # Create a path with directory prefix for matching
        prefixed_path = f"{dir_name}/{file_path}"
        print(f"🔍 Checking file: {file_path} (with prefix: {prefixed_path})")
        
        # Check if it's a chart folder change
        chart_path = None
        api_specs = []
        
        # Check if the changed file is in a chart folder
        for chart_key in mapping.keys():
            # Try both with and without prefix
            if file_path.startswith(chart_key) or file_path.endswith(chart_key) or \
               prefixed_path.startswith(chart_key) or prefixed_path.endswith(chart_key):
                print(f"📊 Chart folder change detected: {chart_key}")
                chart_path = chart_key
                api_specs = mapping[chart_key]
                break
                
        # If not in chart folder, check if it's an api.yaml file
        if not chart_path and ('api.yaml' in file_path or 'openapi.yaml' in file_path):
            print(f"📄 API spec file change detected: {file_path}")
            for chart_key, spec_files in mapping.items():
                # Try both with and without prefix
                if file_path in spec_files or prefixed_path in spec_files:
                    chart_path = chart_key
                    api_specs = spec_files
                    break
        
        # If a chart path and specs were found, add to validation set
        if chart_path and api_specs:
            charts_to_validate[chart_path] = api_specs
    
    # Skip validation if no matches were found
    if not charts_to_validate:
        print("⏭️ No matching chart folders or API specs were found. Skipping validation.")
        sys.exit(0)
    
    # Validate each chart
    success = True
    for chart_path, api_specs in charts_to_validate.items():
        print(f"🔄 Validating chart: {chart_path} with {len(api_specs)} API specs")
        for api_spec in api_specs:
            print(f"📥 Processing API spec: {api_spec}")
            
        if not compare_paths(chart_path, api_specs):
            success = False
    
    if success:
        print("✅ All virtual service path validations passed!")
    else:
        print("❌ Virtual service path validation failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()
