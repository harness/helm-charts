#!/bin/bash

# Check if both folder paths are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 /path/to/charts /path/to/tests"
    exit 1
fi

folder1_path="$1"
folder2_path="$2"

# Get a list of files in folder1
folder1_files=("$folder1_path/templates"/*)

test_files=()
# Iterate through each file in folder1
for file1 in "${folder1_files[@]}"; do
    # Extract the filename without the path
    file1_name=$(basename "$file1")

    # Check if the corresponding _test file exists in folder2
    file2_name="${file1_name/.yaml/_test.yaml}"
    file2_path="$folder2_path/$file2_name"

    if [ -e "$file2_path" ]; then
        test_files+=("-f $file2_path")
    fi
done

test_input="${test_files[*]}"

# Regex to remove the trim copying/deleting log spam
regex_pattern='^[0-9]{4}/[0-9]{2}/[0-9]{2} ([0-9]{2}:[0-9]{2}:[0-9]{2}) (trim (copying|deleting) "(.*)")'

command_output=$(helm unittest $test_input $folder1_path --with-subchart=false)
exit_code=$?

# Cleaning the output from the trim copying/deleting log spam
cleaned_output=$(echo "$command_output" | awk -v pattern="$regex_pattern" '$0 !~ pattern')

# Printing the cleaned output
printf "%s\n" "$cleaned_output"

# Exit if the tests failed
if [ $exit_code -ne 0 ]; then
    exit 1
fi
