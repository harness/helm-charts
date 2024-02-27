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
debug=false
cleanup=false
error_occurred=false

# Function to display help message
function show_help {
  echo "Usage: $0 -r <registry> [-f <tgz_file> | -d <tgz_directory>]"
  echo "  -r <registry>       The Artifactory registry name (e.g., artifactory.harness.internal/platform-staging)."
  echo "  -f <tgz_file>       The name of the .tgz file to process (optional if -d is provided)."
  echo "  -d <tgz_directory>  The directory containing .tgz files to process (optional if -f is provided)."
  echo "  -D                  Enable debug mode for detailed logging."
  echo "  -c                  Enable cleanup after script execution."
  exit 1
}

check_image_in_registry() {
  local image=$1
  if docker manifest inspect "$image" > /dev/null 2>&1; then
    debug_log "Image $image is already present in the registry."
    return 0  # Image exists
  else
    debug_log "Image $image is not present in the registry."
    return 1  # Image does not exist
  fi
}

debug_log() {
  if [ "$debug" = true ]; then
    echo "[DEBUG] $1"
  fi
}

cleanup_images() {
  echo "Cleaning up Docker images..."
  # Iterate through verified_images array to remove images from the local Docker environment
  for image in "${verified_images[@]}"; do
    # Extracting the image ID from the registry path and tag
    local image_id=$(docker images -q "$image")
    if [[ ! -z "$image_id" ]]; then
      docker rmi "$image_id" || debug_log "Failed to remove Docker image: $image"
    else
      debug_log "Image not found or already removed: $image"
    fi
  done
}

# Parse command-line arguments
while getopts "hr:f:d:Dc:" opt; do
  case "$opt" in
    h) show_help ;;
    r) registry="$OPTARG" ;;
    f) tgz_file="$OPTARG" ;;
    d) tgz_directory="$OPTARG" ;;
    D) debug=true ;;
    c) cleanup=true ;;
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
  local load_result
  echo "Processing $file..."
  debug_log "Processing $file...This can take a while"
  
  #Ensures there is enough storage space for docker load
  local required_space=$(du -ks "$file" | awk '{print $1}')
  local available_space=$(df -Pk . | awk 'NR==2 {print $4}')
  if [ "$required_space" -gt "$available_space" ]; then
    debug_log "Insufficient disk space to load $file"
    failed_images+=("$file")
    ((fail_count++))
    return 1
  fi

  debug_log "Loading Docker image from $file..."
  load_result=$(docker load -q -i "$file" 2>&1)

  # Check the exit status of docker load
  local exit_status=$?
  if [ $exit_status -ne 0 ]; then
    echo "Failed to load Docker image from $file"
    ((fail_count++))
    error_occurred=true
    return 1
  fi
  
  # Extract the image names and tags
  while IFS= read -r line; do
    echo "Loading: $line"
    if [[ "$line" =~ Loaded\ image:\ (.+) ]]; then
      local image_info="${BASH_REMATCH[1]}"
      debug_log "Loaded image: $image_info"
      
      if ! check_image_in_registry "$registry/$image_info"; then
        debug_log "Tagging and pushing image $image_info to $registry"
        if docker tag "$image_info" "$registry/$image_info" && docker push "$registry/$image_info"; then
          echo "Successfully pushed $image_info to $registry"
          ((success_count++))
          verified_images+=("$registry/$image_info")
        else
          debug_log "Failed to tag or push image $image_info"
          failed_images+=("$image_info")
          ((fail_count++))
          error_occurred=true
        fi
      else
        verified_images+=("$image_info")
      fi
    fi
  done <<< "$load_result" # to avoid subshell (success_count)
}

# Process the specified .tgz file or directory
if [[ -n "$tgz_file" ]]; then
  process_tgz_file "$tgz_file"
elif [[ -n "$tgz_directory" ]]; then
  for file in "$tgz_directory"/*.tgz; do
    process_tgz_file "$file"
  done
fi

# Print statistics
if (( success_count > 0 || fail_count > 0 )); then
    echo "Total successful pushes: $success_count"
    echo "Total failed pushes: $fail_count"
elif [[ "$error_occurred" = false ]]; then
    echo "No new images were pushed."
else
    echo "Errors occurred during processing. Please review the error messages above."
fi

if [ ${#verified_images[@]} -gt 0 ]; then
    debug_log "Verified images in the registry:"
    for image in "${verified_images[@]}"; do
        debug_log "  - $image"
    done
fi

if [ ${#failed_images[@]} -gt 0 ]; then
    echo "Failed to process images:"
    for image in "${failed_images[@]}"; do
        debug_log "  - $image"
    done
fi

if [ "$cleanup" = true ]; then
    cleanup_images
fi
