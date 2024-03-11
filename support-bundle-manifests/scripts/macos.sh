#!/bin/bash

# Function to convert human-readable time to epoch time
human_to_epoch() {
    local duration=$1
    local unit=$2
    local current_time=$(date +%s)

    case $unit in
        days)
            echo $((current_time - (duration * 86400)))
            ;;
        hours)
            echo $((current_time - (duration * 3600)))
            ;;
        minutes)
            echo $((current_time - (duration * 60)))
            ;;
        *)
            echo "Invalid input. Please specify 'days' or 'hours'."
            exit 1
            ;;
    esac
}

# Function to convert DD-MM-YYYY date format to epoch time
date_to_epoch() {
    local input_date=$1
    local epoch_time=$(gdate -d "$input_date" +%s)

    echo "$epoch_time"
}

# Check if all required arguments are provided
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <namespace> <release_name>"
  echo "Flags"
  echo "--module <module-name>(optional): If not provided, all modules will be selected"
  echo "--last <x> <minutes/hours/days>(optional): Log duration to fetch"
  echo "--between <start_time> <end_time> (YYYY-DD-MM)(optional): Log duration to fetch"
  echo "--number-of-files <num_files>(optional): Number of log files to fetch (default: 2)"
  echo "--filepath <filepath>(optional): File path of logs, default is /opt/harness/logs/pods*.log"
  echo "provide '*.log' in the filepath at the end"
  exit 1
fi

# Assign arguments to variables
export NAMESPACE="$1"
export RELEASE_NAME="$2"
NUM_FILES=2

shift 2
# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    echo $1 $2 $3
    case $1 in
        --last)
            START_TIME=$(human_to_epoch "$2" "$3")
            echo $START_TIME
            shift 3
            ;;
        --between)
            time1=$(date_to_epoch "$2")
            time2=$(date_to_epoch "$3")
            if [ $time1 -gt $time2 ]; then
                START_TIME=$time2
                END_TIME=$time1
            else
                START_TIME=$time1
                END_TIME=$time2
            fi
            shift 3
            ;;
        --number-of-files)
            NUM_FILES=$2
            shift 2
            ;;
        --module)
            MODULE="$1"
            shift 2
            ;;
        --filepath)
            FILEPATH=$2
            shift 2
            ;;
        *)
            echo "Invalid argument: $1"
            exit 1
            ;;
    esac
done

if [ -z "$MODULE" ]; then
    MODULE="all"
fi

if [ -z "$FILEPATH" ]; then
    FILEPATH="/opt/harness/logs/pod*.log"
fi

BASE_URL="https://raw.githubusercontent.com/harness/helm-charts/main/support-bundle-manifests"

case "$MODULE" in
  "all")
    DOWNLOAD_URL="$BASE_URL/support-bundle-all.yaml"
    ;;
  *)
    DOWNLOAD_URL="$BASE_URL/module-wise/support-bundle-$MODULE.yaml"
    ;;
esac


# Download file
MANIFEST_FILENAME="support-bundle.yaml"
curl -o $MANIFEST_FILENAME "$DOWNLOAD_URL"

yq -i '(.. | select(has("namespace")) | .namespace) = env(NAMESPACE)' $MANIFEST_FILENAME
yq -i '(.. | select(has("releaseName")) | .releaseName) = env(RELEASE_NAME)' $MANIFEST_FILENAME
yq -i '.spec.collectors[0].clusterResources.namespaces = [env(NAMESPACE)]' $MANIFEST_FILENAME

if [ -z "$END_TIME" ]; then
    yq -i '(.. | select(has("args")) | .args) = ["'"${NUM_FILES}"'", "'"${FILEPATH}"'", "'"${START_TIME}"'"]' $MANIFEST_FILENAME

else
    yq -i '(.. | select(has("args")) | .args) = ["'"${NUM_FILES}"'", "'"${FILEPATH}"'", "'"${START_TIME}"'", "'"${END_TIME}"'"]' $MANIFEST_FILENAME
fi
