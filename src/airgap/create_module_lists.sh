#!/bin/bash

cleanup() {
  echo "Cleaning up generated files..."
  for file in "${generated_files[@]}"; do
    rm -f "$file"
  done
}

trap cleanup EXIT

if [ "$#" -ne 2 ]; then
  echo "Error: Incorrect number of arguments."
  echo "Usage: $0 <images.txt> <input_file>"
  exit 1
fi

IMAGES_TXT="$1"
INPUT_FILE="$2"

if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "Error: This script requires Bash version 4.0 or later."
    exit 1
fi

declare -A lines_read
declare -a generated_files

MODULE_IMAGE_FILE=""

while IFS= read -r line; do
  # Check if the line starts with "["
  if [[ $line == [* ]]; then
    
    MODULE_NAME=${line//[[:space:]]/}
    MODULE_NAME=${MODULE_NAME//[[:punct:]]/}
    MODULE_IMAGE_FILE="${MODULE_NAME//:/}_images.txt"

    > "$MODULE_IMAGE_FILE"
    generated_files+=("$MODULE_IMAGE_FILE")
    echo "Created module file: $MODULE_IMAGE_FILE"

    # Remove this file from MODULE_IMAGE_FILES array if it exists
    MODULE_IMAGE_FILES=($(echo "${MODULE_IMAGE_FILES[*]}" | sed "s/$MODULE_IMAGE_FILE//g" | tr -s ' '))
     
  elif [[ -n $MODULE_IMAGE_FILE ]]; then
    # Trim leading/trailing whitespaces from the image
    image=$(echo "$line" | awk '{$1=$1};1')

    # Check if the line is empty or starts with "["
    if [[ -z $image || $image == [* ]]; then
      continue
    fi
   
    MATCHING_LINES=$(grep -F "/$image:" "$IMAGES_TXT")
  
    if [[ -n $MATCHING_LINES && "$MATCHING_LINES" != docker.io/harness/looker-signed* ]]; then
      while IFS= read -r matching_line; do
        lines_read["$matching_line"]=1
      done <<< "$MATCHING_LINES"

      if ! grep -qF "/$image:" "$MODULE_IMAGE_FILE"; then
        # Append the matching lines to the module-specific image file
        echo "$MATCHING_LINES" >> "$MODULE_IMAGE_FILE"
      fi
    else
      echo "Error: Image '$image' not found in $IMAGES_TXT"
      exit 1
    fi
  fi
done < "$INPUT_FILE"

#Check if module_image files are not empty
if [[ -n $MODULE_IMAGE_FILE && ! -s $MODULE_IMAGE_FILE ]]; then
  echo "Error: Module image file $MODULE_IMAGE_FILE is empty"
  exit 1
fi

lines_not_read_flag=0

while IFS= read -r line; do
  if [[ -z ${lines_read["$line"]} && "$line" != docker.io/harness/looker-signed* ]]; then
    echo "$line"
    lines_not_read_flag=1
  fi
done < "$IMAGES_TXT"

if [[ $lines_not_read_flag -eq 1 ]]; then
  echo "Error: The above lines were not read from $IMAGES_TXT:"
  exit 1
fi

# Check if any expected module files were not generated
if [ ${#MODULE_IMAGE_FILES[*]} -gt 0 ]; then
  echo "Error: The following expected module files were not generated:"
  printf '%s\n' "${MODULE_IMAGE_FILES[*]}"
  exit 1
fi

trap - EXIT
