#!/bin/bash

registry=""
tgz_file=""
tgz_directory=""
success_count=0
fail_count=0
skip_count=0
total_count=0
declare -a failed_images
declare -a verified_images
debug=false
cleanup=false
error_occurred=false
create_ecr=false
non_interactive=false

log_info()  { echo "[INFO]  $(date +%H:%M:%S) $*"; }
log_warn()  { echo "[WARN]  $(date +%H:%M:%S) $*" >&2; }
log_error() { echo "[ERROR] $(date +%H:%M:%S) $*" >&2; }
log_debug() { [ "$debug" = true ] && echo "[DEBUG] $(date +%H:%M:%S) $*"; }

function show_help {
    echo "Usage: $0 -r <registry> [-f <tgz_file> | -d <tgz_directory>] [options]"
    echo ""
    echo "  -r <registry>       Target registry (e.g., artifactory.harness.internal/platform-staging)"
    echo "  -f <tgz_file>       Single .tgz file to process"
    echo "  -d <tgz_directory>  Directory containing .tgz files (recursive)"
    echo "  -D                  Enable debug mode"
    echo "  -c                  Enable cleanup after processing"
    echo "  -n                  Non-interactive mode (skip prompts)"
    echo "  -e                  Create ECR repository before push (requires aws configure)"
    echo "  -h                  Show this help"
    exit 1
}

check_image_in_registry() {
    local image=$1
    if docker manifest inspect "$image" > /dev/null 2>&1; then
        log_debug "Already in registry: $image"
        return 0
    else
        return 1
    fi
}

create_ecr_repository() {
    local repository=$1
    local namespace=${ECR_NAMESPACE}
    local awsregion=$AWS_REGION

    if [[ -z "$awsregion" ]]; then
        log_error "AWS_REGION is not set"
        error_occurred=true
        return 1
    fi

    local full_repo_name
    if [[ -z "$namespace" ]]; then
        full_repo_name="$repository"
    else
        full_repo_name="$namespace/$repository"
    fi

    log_debug "Checking ECR repository: $full_repo_name"
    if aws ecr describe-repositories --repository-names "$full_repo_name" --region "$awsregion" > /dev/null 2>&1; then
        log_debug "Repository exists: $full_repo_name"
    else
        if aws ecr create-repository --repository-name "$full_repo_name" --region "$awsregion"; then
            log_info "Created ECR repository: $full_repo_name"
        else
            log_error "Failed to create ECR repository: $full_repo_name"
            error_occurred=true
            return 1
        fi
    fi
}

cleanup_images() {
    log_info "Cleaning up Docker images..."
    for image in "${verified_images[@]}"; do
        local image_id=$(docker images -q "$image")
        if [[ -n "$image_id" ]]; then
            docker rmi "$image_id" 2>/dev/null || log_debug "Failed to remove: $image"
        fi
    done
}

process_tgz_file() {
    local file=$1
    local relative_path="${file#$tgz_directory/}"
    [ "$relative_path" = "$file" ] && relative_path=$(basename "$file")

    log_debug "Processing: $relative_path"

    local required_space=$(du -ks "$file" | awk '{print $1}')
    local available_space=$(df -Pk . | awk 'NR==2 {print $4}')
    if [ "$required_space" -gt "$available_space" ]; then
        log_error "Insufficient disk space for $relative_path"
        failed_images+=("$relative_path")
        ((fail_count++))
        return 1
    fi

    local load_result
    load_result=$(docker load -q -i "$file" 2>&1)
    local exit_status=$?

    if [ $exit_status -ne 0 ]; then
        log_error "Failed to load: $relative_path"
        failed_images+=("$relative_path")
        ((fail_count++))
        error_occurred=true
        return 1
    fi

    while IFS= read -r line; do
        if [[ "$line" =~ Loaded\ image:\ (.+) ]]; then
            local image_info="${BASH_REMATCH[1]}"
            local service_name="${image_info%%:*}"

            if ! check_image_in_registry "$registry/$image_info"; then
                if [ "$create_ecr" = true ]; then
                    create_ecr_repository "$service_name"
                fi

                if docker tag "$image_info" "$registry/$image_info" && docker push "$registry/$image_info"; then
                    log_debug "Pushed: $image_info"
                    ((success_count++))
                    verified_images+=("$registry/$image_info")
                else
                    log_error "Failed to push: $image_info"
                    failed_images+=("$image_info")
                    ((fail_count++))
                    error_occurred=true
                fi
            else
                ((skip_count++))
                verified_images+=("$image_info")
            fi
        fi
    done <<< "$load_result"
}

process_looker() {
    if [ "$non_interactive" = true ]; then
        log_info "Skipping ng-dashboard (non-interactive mode)"
        return
    fi

    read -p "Do you want to install ng-dashboard (yes/no)? " response
    if [[ "$response" != "yes" ]]; then
        return
    fi

    read -p "Enter DockerHub username: " DOCKERHUB_USERNAME
    read -sp "Enter DockerHub password: " DOCKERHUB_PASSWORD
    echo
    read -p "Enter release version: " RELEASE_VERSION

    if [ -z "$DOCKERHUB_USERNAME" ] || [ -z "$DOCKERHUB_PASSWORD" ] || [ -z "$RELEASE_VERSION" ]; then
        log_warn "Credentials or version not provided, skipping ng-dashboard"
        return
    fi

    echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
    if [ $? -ne 0 ]; then
        log_error "DockerHub login failed"
        return
    fi

    local tgz_name="harness-${RELEASE_VERSION}.tgz"
    local dir_name="harness-${RELEASE_VERSION}"
    rm -rf "$tgz_name" "$dir_name"

    local url="https://github.com/harness/helm-charts/releases/download/harness-${RELEASE_VERSION}/${tgz_name}"
    log_info "Downloading $url"
    curl -L -o "$tgz_name" "$url"

    if [ $? -ne 0 ]; then
        log_error "Failed to download $tgz_name"
        return
    fi

    mkdir "$dir_name"
    tar -xzf "$tgz_name" -C "$dir_name"

    local looker_tag
    looker_tag=$(grep "looker" "${dir_name}/harness/images.txt" 2>/dev/null)
    if [ -z "$looker_tag" ]; then
        log_warn "Looker image not found in images.txt"
        rm -rf "$tgz_name" "$dir_name"
        docker logout
        return
    fi

    log_info "Pulling $looker_tag"
    docker pull "$looker_tag"

    local looker_image
    looker_image=$(echo "$looker_tag" | sed 's/^[^\/]*\///')
    if ! check_image_in_registry "$registry/$looker_image"; then
        if docker tag "$looker_tag" "$registry/$looker_image" && docker push "$registry/$looker_image"; then
            log_info "Pushed looker: $looker_image"
            ((success_count++))
            verified_images+=("$registry/$looker_image")
        else
            log_error "Failed to push looker: $looker_image"
            failed_images+=("$looker_image")
            ((fail_count++))
            error_occurred=true
        fi
    else
        verified_images+=("$looker_image")
    fi

    rm -rf "$tgz_name" "$dir_name"
    docker logout
}

while getopts "hr:f:d:Dcne" opt; do
    case "$opt" in
        h) show_help ;;
        r) registry="$OPTARG" ;;
        f) tgz_file="$OPTARG" ;;
        d) tgz_directory="$OPTARG" ;;
        D) debug=true ;;
        c) cleanup=true ;;
        n) non_interactive=true ;;
        e) create_ecr=true ;;
        *) show_help ;;
    esac
done

if [ -z "$registry" ]; then
    log_error "Registry not specified"
    show_help
fi

if [ -z "$tgz_file" ] && [ -z "$tgz_directory" ]; then
    log_error "No .tgz file or directory specified"
    show_help
fi

process_looker

if [[ -n "$tgz_file" ]]; then
    total_count=1
    log_info "[1/1] Processing: $(basename "$tgz_file")"
    process_tgz_file "$tgz_file"
elif [[ -n "$tgz_directory" ]]; then
    mapfile -t tgz_files < <(find "$tgz_directory" -name "*.tgz" -type f | sort)
    total_count=${#tgz_files[@]}

    if [ $total_count -eq 0 ]; then
        log_error "No .tgz files found in $tgz_directory"
        exit 1
    fi

    log_info "Found ${total_count} .tgz files in ${tgz_directory} (recursive)"
    for idx in "${!tgz_files[@]}"; do
        local_file="${tgz_files[$idx]}"
        relative="${local_file#$tgz_directory/}"
        log_info "[$(( idx + 1 ))/${total_count}] ${relative}"
        process_tgz_file "$local_file"
    done
fi

echo ""
log_info "=== SUMMARY ==="
log_info "Total bundles processed: ${total_count}"
log_info "Images pushed: ${success_count}"
log_info "Images skipped (already in registry): ${skip_count}"
log_info "Images failed: ${fail_count}"

if [ ${#failed_images[@]} -gt 0 ]; then
    log_error "Failed images:"
    for img in "${failed_images[@]}"; do
        log_error "  - $img"
    done
fi

if [ "$cleanup" = true ]; then
    cleanup_images
fi

if [ "$error_occurred" = true ]; then
    exit 1
fi
