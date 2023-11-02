#!/bin/bash

# Default values
registry=""
tgz_file=""
tgz_directory=""

# Function to display help message
function show_help {
  echo "Usage: $0 -r <registry> [-f <tgz_file> | -d <tgz_directory>]"
  echo "  -r <registry>       The Artifactory registry name (e.g., artifactory.harness.internal/platform-staging)."
  echo "  -f <tgz_file>       The name of the .tgz file to process (optional if -d is provided)."
  echo "  -d <tgz_directory>  The directory containing .tgz files to process (optional if -f is provided)."
  exit 1
}

# Parse command-line arguments
while getopts "r:f:d:" opt; do
  case "$opt" in
    r) registry="$OPTARG" ;;
    f) tgz_file="$OPTARG" ;;
    d) tgz_directory="$OPTARG" ;;
    *) show_help ;;
  esac
done

if [ -z "$tgz_file" ] && [ -z "$tgz_directory" ]; then
  show_help
fi

if [ -z "$registry" ]; then
  show_help
fi

if [ -n "$tgz_file" ]; then
  echo "Processing $tgz_file"

  tmp_file=$(mktemp)

  docker load -i "$tgz_file" > "$tmp_file"

  while read -r image_info; do
    image_info="${image_info#Loaded image: }"
    if [ -n "$image_info" ]; then
      docker tag "$image_info" "$registry/$image_info" && echo "Tagged: $registry/$image_info"
      docker push "$registry/$image_info" && echo "Pushed: $registry/$image_info"
    else
      echo "Failed to extract image info from load output."
    fi
  done < "$tmp_file"

  rm "$tmp_file"

  echo "Finished processing $tgz_file"
fi

if [ -n "$tgz_directory" ]; then
  for tgz_file in "$tgz_directory"/*.tgz; do
    echo "Processing $tgz_file"

    tmp_file=$(mktemp)

    docker load -i "$tgz_file" > "$tmp_file"

    while read -r image_info; do
      image_info="${image_info#Loaded image: }"
      if [ -n "$image_info" ]; then
        docker tag "$image_info" "$registry/$image_info" && echo "Tagged: $registry/$image_info"
        docker push "$registry/$image_info" && echo "Pushed: $registry/$image_info"
      else
        echo "Failed to extract image info from load output."
      fi
    done < "$tmp_file"

    rm "$tmp_file"

    echo "Finished processing $tgz_file"
  done
fi

