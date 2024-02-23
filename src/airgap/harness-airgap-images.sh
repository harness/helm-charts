#!/bin/bash

# Default values
registry=""
tgz_file=""
tgz_directory=""
success_count=0
fail_count=0
declare -a failed_images
declare -a missing_images
declare -a verified_images

# Function to display help message
function show_help {
  echo "Usage: $0 -r <registry> [-f <tgz_file> | -d <tgz_directory>]"
  echo "  -r <registry>       The Artifactory registry name (e.g., artifactory.harness.internal/platform-staging)."
  echo "  -f <tgz_file>       The name of the .tgz file to process (optional if -d is provided)."
  echo "  -d <tgz_directory>  The directory containing .tgz files to process (optional if -f is provided)."
  exit 1
}

check_image_in_registry() {
  local image=$1
  if docker manifest inspect "$image" > /dev/null 2>&1; then
    return 0  # Image exists
  else
    return 1  # Image does not exist
  fi
}

# Parse command-line arguments
while getopts "hr:f:d:" opt; do
  case "$opt" in
    h) show_help ;;
    r) registry="$OPTARG" ;;
    f) tgz_file="$OPTARG" ;;
    d) tgz_directory="$OPTARG" ;;
    *) show_help ;;
  esac
done

# Check for mandatory options
if [ -z "$registry" ]; then
  echo "Registry not specified!"
  show_help
  exit 1
fi

if [ -z "$tgz_file" ] && [ -z "$tgz_directory" ]; then
  echo "No .tgz file or directory specified!"
  show_help
  exit 1
fi

process_tgz_file() {
  local file=$1
  echo "Processing $file..."
  local image_info
  local load_output

  # Load the Docker image from a .tgz file
  load_output=$(docker load -i "$file" 2>&1)

  # Check the exit status of docker load
  local exit_status=$?
  if [ $exit_status -ne 0 ]; then
    echo "Failed to load Docker image from $file"
    exit $exit_status
  fi
  
  # Extract the image names and tags
  while IFS= read -r line; do
    if [[ "$line" =~ Loaded\ image:\ (.+) ]]; then
      image_info="${BASH_REMATCH[1]}"
      echo "Loaded image: $image_info"
      
      # Tag the image with the provided registry
      if docker tag "$image_info" "$registry/$image_info"; then
        # Push the image to the registry
        if docker push "$registry/$image_info"; then
          echo "Successfully pushed $image_info to $registry"
          ((success_count++))
          verified_images+=("$image_info")
        else
          echo "Failed to push $image_info to $registry"
          failed_images+=("$image_info")
          ((fail_count++))
        fi
      else
        echo "Failed to tag $image_info with $registry"
        failed_images+=("$image_info")
        ((fail_count++))
      fi
    fi
  done <<< "$load_output"
}

# Process the specified .tgz file or directory
if [[ -n "$tgz_file" ]]; then
  process_tgz_file "$tgz_file"
elif [[ -n "$tgz_directory" ]]; then
  for file in "$tgz_directory"/*.tgz; do
    process_tgz_file "$file"
  done
fi

# Verify all pushed images are in the registry
for image in "${verified_images[@]}"; do
  if ! check_image_in_registry "$registry/$image"; then
    echo "Image missing in registry: $registry/$image"
    missing_images+=("$image")
  fi
done

# Print statistics
echo "Total successful pushes: $success_count"
echo "Total failed pushes: $fail_count"
if [[ ${#failed_images[@]} -gt 0 ]]; then
  echo "Failed images:"
  for image in "${failed_images[@]}"; do
    echo "$image"
  done
fi
if [[ ${#missing_images[@]} -gt 0 ]]; then
  echo "Images missing in registry after push: ${#missing_images[@]}"
  for image in "${missing_images[@]}"; do
    echo "$image"
  done
else
  echo "All pushed images verified in registry."
fi

