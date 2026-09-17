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
import re
from pathlib import Path

VERSIONED_PATH_RE = re.compile(r'/\(v\d+/')
VERSION_IN_NAME_RE = re.compile(r'(v\d+)')

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

def compare_paths(chart_path, api_specs, repo_name=None):
    """Compare virtual service paths between generated and existing configuration"""
    # Convert chart path to absolute path in the repository
    # The chart_path already includes the repo name, so we just need the base temp path
    repo_base_path = "/harness-temp"
    absolute_chart_path = os.path.join(repo_base_path, chart_path)
    
    print(f"📁 Looking for chart at: {absolute_chart_path}")
    
    # Get the service name from Chart.yaml in the chart folder
    chart_yaml_path = os.path.join(absolute_chart_path, 'Chart.yaml')
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
        # Convert API spec paths to absolute paths in the repository
        # The api_spec paths already include the repo name, so we just need the base temp path
        repo_base_path = "/harness-temp"
        absolute_api_specs = []
        
        for api_spec in api_specs:
            # Check if the API spec file exists in the repository
            absolute_path = os.path.join(repo_base_path, api_spec)
            if os.path.exists(absolute_path):
                absolute_api_specs.append(absolute_path)
                print(f"✅ Found API spec: {absolute_path}")
            else:
                print(f"⚠️ API spec not found: {absolute_path}")
        
        if not absolute_api_specs:
            print("❌ No valid API specifications found")
            os.unlink(temp_file)
            return False
        
        # Generate command with all API specs
        api_specs_args = ' '.join(absolute_api_specs)
        cmd = f"python3 generate_virtualService_paths.py {service_name} {api_specs_args} > {temp_file}"
        run_command(cmd, capture_output=False)
        
        # Get values.yaml path
        values_file = os.path.join(absolute_chart_path, "values.yaml")
        if not os.path.isfile(values_file):
            print(f"Error: values.yaml not found in {absolute_chart_path}")
            os.unlink(temp_file)
            return False
        
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
        
        # Extract paths from values.yaml, only keeping versioned paths
        values_paths = []
        for obj in values_config.get('virtualService', {}).get('objects', []):
            for path in obj.get('paths', []):
                path_str = path
                if isinstance(path, dict) and 'path' in path:
                    path_str = path['path']
                path_str = path_str.strip()
                # Only include versioned API endpoints (any /vN/)
                if VERSIONED_PATH_RE.search(path_str):
                    values_paths.append(path_str)
        
        # Extract paths from generated config, only keeping versioned paths
        generated_paths = []
        for obj in generated_config.get('virtualService', {}).get('objects', []):
            for path in obj.get('paths', []):
                path_str = path
                if isinstance(path, dict) and 'path' in path:
                    path_str = path['path']
                path_str = path_str.strip()
                # Only include versioned API endpoints (any /vN/)
                if VERSIONED_PATH_RE.search(path_str):
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
                object_version_match = VERSION_IN_NAME_RE.search(name)
                if object_version_match:
                    version = object_version_match.group(1)
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
            
            # Generate YAML for each version that has paths
            objects_yaml = []
            generated_by_version = {}
            for path in generated_paths_set:
                match = re.search(r'/\((v\d+)/', path)
                if match:
                    generated_by_version.setdefault(match.group(1), []).append(path)

            for version in sorted(generated_by_version):
                version_paths = sorted(generated_by_version[version], key=sort_by_segment_length)
                if version in versioned_objects:
                    version_obj = versioned_objects[version]
                    version_yaml = f"    - name: {version_obj['name']}\n"
                    version_yaml += f"      pathMatchType: {version_obj['pathMatchType']}\n"
                    version_yaml += f"      pathRewrite: \"{version_obj['pathRewrite']}\"\n"
                    version_yaml += "      paths:\n"
                    for path in version_paths:
                        version_yaml += f"        - path: '{path}'\n"
                    objects_yaml.append(version_yaml)
                
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
            
        if not compare_paths(chart_path, api_specs, args.repo_name):
            success = False
    
    if success:
        print("✅ All virtual service path validations passed!")
    else:
        print("❌ Virtual service path validation failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()
