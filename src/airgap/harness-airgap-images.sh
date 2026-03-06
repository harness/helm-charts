#!/usr/bin/env bash
#
# harness-airgap-images.sh
#
# Push airgap .tgz bundle(s) to a target container registry.
#
# Uses docker mode by default (docker load/tag/push).
# Use -s to request skopeo mode (daemonless copy). If skopeo/jq are missing,
# script falls back to docker mode automatically.
#
# Usage:
#   ./harness-airgap-images.sh -r <registry> -d <bundle-dir> [options]
#   ./harness-airgap-images.sh -r <registry> -f <bundle.tgz> [options]
#

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Colours (auto-disabled when stdout is not a terminal)
# ─────────────────────────────────────────────────────────────────────────────
if [ -t 1 ] && command -v tput &>/dev/null && tput colors &>/dev/null 2>&1; then
    RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; GREEN=$'\033[0;32m'
    CYAN=$'\033[0;36m'; BOLD=$'\033[1m'; DIM=$'\033[2m'; RESET=$'\033[0m'
else
    RED=''; YELLOW=''; GREEN=''; CYAN=''; BOLD=''; DIM=''; RESET=''
fi

# ─────────────────────────────────────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────────────────────────────────────
log_info()  { printf "${GREEN}[INFO]${RESET}  %s %s\n"  "$(date +%H:%M:%S)" "$*"; }
log_warn()  { printf "${YELLOW}[WARN]${RESET}  %s %s\n"  "$(date +%H:%M:%S)" "$*" >&2; }
log_error() { printf "${RED}[ERROR]${RESET} %s %s\n"  "$(date +%H:%M:%S)" "$*" >&2; }
log_debug() { [ "$debug" = true ] && printf "${DIM}[DEBUG] %s %s${RESET}\n" "$(date +%H:%M:%S)" "$*" >&2 || true; }
log_step()  { printf "\n${BOLD}${CYAN}┌─ %s${RESET}\n" "$*"; }
log_done()  { printf "${GREEN}  ✓${RESET} %s\n" "$*"; }
log_fail()  { printf "${RED}  ✗ failed:  %s${RESET}\n" "$*" >&2; }

# ─────────────────────────────────────────────────────────────────────────────
# Defaults
# ─────────────────────────────────────────────────────────────────────────────
registry=""
tgz_file=""
tgz_directory=""
debug=false
cleanup=false
create_ecr=false
non_interactive=false
use_skopeo=false
request_skopeo=false

success_count=0
fail_count=0
total_count=0
declare -a failed_images=()
declare -a verified_images=()
START_TIME=$(date +%s)

# ─────────────────────────────────────────────────────────────────────────────
# Usage
# ─────────────────────────────────────────────────────────────────────────────
show_help() {
    cat <<EOF
${BOLD}Usage:${RESET} $(basename "$0") -r <registry> [-f <tgz_file> | -d <tgz_directory>] [options]

${BOLD}Required:${RESET}
  -r <registry>       Target registry URL
                        e.g. artifactory.harness.internal/harness

${BOLD}Source (one required):${RESET}
  -f <tgz_file>       Single .tgz bundle file to process
  -d <tgz_directory>  Directory containing .tgz files (searched recursively)

${BOLD}Options:${RESET}
  -s, --use-skopeo    Use skopeo mode (faster daemonless copy). Falls back to docker if unavailable
  -c                  Clean up locally loaded Docker images after pushing (docker mode only)
  -e                  Create ECR repository before push  (requires: aws configure + AWS_REGION)
  -n                  Non-interactive mode — skip optional prompts (e.g. ng-dashboard)
  -D                  Enable debug output
  -h                  Show this help

${BOLD}Environment variables:${RESET}
  AWS_REGION          AWS region for ECR operations (required with -e)
  ECR_NAMESPACE       Optional namespace prefix for ECR repository names

${BOLD}Examples:${RESET}
  # Push all bundles in a directory
  ./$(basename "$0") -r myregistry.example.com/harness -d ./bundles

  # Push a single bundle
  ./$(basename "$0") -r myregistry.example.com/harness -f ./bundles/platform_images.tgz

  # Push using skopeo mode
  ./$(basename "$0") -r myregistry.example.com/harness -f ./bundles/platform_images.tgz -s

  # Non-interactive, with cleanup, ECR auto-create
  ./$(basename "$0") -r 123456789.dkr.ecr.us-east-1.amazonaws.com/harness \\
    -d ./bundles -n -c -e
EOF
    exit 1
}

# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

# Extract image RepoTags from a bundle produced by create-airgap-bundle.sh.
# manifest.json is placed first in the archive so tar stops after the first entry.
# Requires jq (already a dependency of create-airgap-bundle.sh and validate_airgap.sh).
extract_image_names_from_tgz() {
    local tgz="$1"
    local raw=""
    for mpath in manifest.json ./manifest.json; do
        raw=$(tar -xzOf "$tgz" "$mpath" 2>/dev/null) && [ -n "$raw" ] && break || true
    done
    [ -z "$raw" ] && return 1
    printf '%s' "$raw" | jq -r '.[].RepoTags[]?'
}

extract_image_names_from_tar() {
    local tar_file="$1"
    local raw=""
    for mpath in manifest.json ./manifest.json; do
        raw=$(tar -xOf "$tar_file" "$mpath" 2>/dev/null) && [ -n "$raw" ] && break || true
    done
    [ -z "$raw" ] && return 1
    printf '%s' "$raw" | jq -r '.[].RepoTags[]?'
}

# Strip registry host prefix if first path segment looks like a hostname.
# Example: docker.io/harness/foo:1.0 -> harness/foo:1.0
strip_registry_prefix() {
    local ref="$1"
    local first="${ref%%/*}"
    case "$first" in
        *.*|*:*|localhost) printf '%s\n' "${ref#*/}" ;;
        *)                 printf '%s\n' "$ref" ;;
    esac
}

# skopeo docker-archive transport expects an uncompressed tar archive.
# Our bundles are .tgz (gzip-compressed tar), so convert to a temporary .tar.
prepare_skopeo_archive() {
    local tgz="$1"
    local out_tar="$2"

    if command -v pigz >/dev/null 2>&1; then
        pigz -dc "$tgz" >"$out_tar"
    else
        gzip -dc "$tgz" >"$out_tar"
    fi
}

create_ecr_repository() {
    local repository="$1"
    local region="${AWS_REGION:-}"
    local namespace="${ECR_NAMESPACE:-}"

    if [ -z "$region" ]; then
        log_error "AWS_REGION is not set — cannot create ECR repository"
        return 1
    fi

    local full_repo="${namespace:+${namespace}/}${repository}"
    log_debug "Ensuring ECR repository exists: ${full_repo}"

    if aws ecr describe-repositories --repository-names "$full_repo" --region "$region" >/dev/null 2>&1; then
        log_debug "ECR repository already exists: ${full_repo}"
    else
        if aws ecr create-repository --repository-name "$full_repo" --region "$region" >/dev/null; then
            log_info "Created ECR repository: ${BOLD}${full_repo}${RESET}"
        else
            log_error "Failed to create ECR repository: ${full_repo}"
            return 1
        fi
    fi
}

cleanup_images() {
    log_step "Cleaning up local Docker images"
    local removed=0
    for image in "${verified_images[@]}"; do
        local image_id
        image_id=$(docker images -q "$image" 2>/dev/null || true)
        if [ -n "$image_id" ]; then
            docker rmi "$image_id" >/dev/null 2>&1 && removed=$((removed + 1)) || log_debug "Could not remove: ${image}"
        fi
    done
    log_info "Removed ${removed} local image(s)"
}

# ─────────────────────────────────────────────────────────────────────────────
# process_tgz_file_skopeo <path> <index> <total>
#
# Streams images directly from the .tgz archive to the registry using skopeo.
# No docker daemon, no local disk extraction, no docker load.
# ─────────────────────────────────────────────────────────────────────────────
process_tgz_file_skopeo() {
    local file="$1"
    local idx="$2"
    local total="$3"

    local relative_path="${file#${tgz_directory}/}"
    [ "$relative_path" = "$file" ] && relative_path=$(basename "$file")

    local file_size
    file_size=$(du -sh "$file" 2>/dev/null | awk '{print $1}' || echo "?")

    printf "\n${BOLD}[%d/%d]${RESET} %s  ${DIM}(%s)${RESET}\n" "$idx" "$total" "$relative_path" "$file_size"

    # docker-archive transport can not directly consume compressed .tgz.
    local skopeo_tar
    skopeo_tar=$(mktemp "${TMPDIR:-/tmp}/airgap-skopeo-archive.XXXXXX.tar")
    log_info "Preparing skopeo archive (decompressing .tgz → .tar) …"
    if ! prepare_skopeo_archive "$file" "$skopeo_tar"; then
        log_fail "Failed to prepare skopeo archive for ${relative_path}"
        rm -f "$skopeo_tar"
        failed_images+=("$relative_path")
        fail_count=$((fail_count + 1))
        return 1
    fi

    log_info "Reading archive manifest …"
    # Read RepoTags from already prepared .tar to avoid decompressing twice.
    local images_raw
    images_raw=$(extract_image_names_from_tar "$skopeo_tar") || true
    if [ -z "$images_raw" ]; then
        log_fail "Could not read image names from ${relative_path}"
        rm -f "$skopeo_tar"
        failed_images+=("$relative_path")
        fail_count=$((fail_count + 1))
        return 1
    fi

    local images=()
    while IFS= read -r _img; do
        [ -n "$_img" ] && images+=("$_img")
    done <<EOF
$images_raw
EOF

    local img_total=${#images[@]}
    log_info "Found ${BOLD}${img_total}${RESET} image(s) in archive"

    local bundle_pushed=0 bundle_failed=0
    local img_idx=0

    for image_ref in "${images[@]}"; do
        [ -z "$image_ref" ] && continue
        img_idx=$((img_idx + 1))

        local target="${registry}/${image_ref}"
        local service_name="${image_ref%%:*}"
        service_name="${service_name##*/}"

        printf "  ${DIM}[%d/%d]${RESET} %s\n" "$img_idx" "$img_total" "$image_ref"
        printf "    ${DIM}copying → %s …${RESET}\n" "$target"

        if [ "$create_ecr" = true ]; then
            create_ecr_repository "$service_name" || true
        fi

        # Run skopeo with output going to a temp file so we capture both the
        # exit code (in the parent shell) and the output for display.
        # Also retry with stripped registry prefix to handle mixed tag formats.
        local cmd_tmp cmd_rc=1
        local src_ref="$image_ref"
        local alt_src_ref
        alt_src_ref=$(strip_registry_prefix "$image_ref")
        cmd_tmp=$(mktemp)

        skopeo copy --remove-signatures \
            "docker-archive:${skopeo_tar}:${src_ref}" \
            "docker://${target}" >"$cmd_tmp" 2>&1 || cmd_rc=$?

        if [ "$cmd_rc" -ne 0 ] && [ "$alt_src_ref" != "$src_ref" ]; then
            printf "    ${DIM}retrying source tag lookup as %s …${RESET}\n" "$alt_src_ref"
            cmd_rc=0
            skopeo copy --remove-signatures \
                "docker-archive:${skopeo_tar}:${alt_src_ref}" \
                "docker://${target}" >"$cmd_tmp" 2>&1 || cmd_rc=$?
        fi

        while IFS= read -r line; do
            printf "    ${DIM}%s${RESET}\n" "$line"
        done <"$cmd_tmp"

        if [ "$cmd_rc" -eq 0 ]; then
            rm -f "$cmd_tmp"
            log_done "Copied → ${target}"
            success_count=$((success_count + 1))
            bundle_pushed=$((bundle_pushed + 1))
        else
            # Some registries can still end up with the image present even when
            # skopeo exits non-zero near the end of the operation.
            local verify_tmp verify_rc=0
            verify_tmp=$(mktemp)
            skopeo inspect "docker://${target}" >"$verify_tmp" 2>&1 || verify_rc=$?

            if [ "$verify_rc" -eq 0 ]; then
                rm -f "$verify_tmp" "$cmd_tmp"
                log_warn "skopeo exited ${cmd_rc}, but destination image is present; treating as success"
                log_done "Copied (verified) → ${target}"
                success_count=$((success_count + 1))
                bundle_pushed=$((bundle_pushed + 1))
            else
                log_error "skopeo copy exited with code ${cmd_rc} for ${image_ref}"
                while IFS= read -r vline; do
                    [ -n "$vline" ] && printf "    ${RED}verify:${RESET} ${DIM}%s${RESET}\n" "$vline"
                done <"$verify_tmp"
                rm -f "$verify_tmp" "$cmd_tmp"
                log_fail "${image_ref} → ${target}"
                failed_images+=("$image_ref")
                fail_count=$((fail_count + 1))
                bundle_failed=$((bundle_failed + 1))
            fi
        fi
    done

    rm -f "$skopeo_tar"

    # Per-file mini-summary
    local parts=""
    [ "$bundle_pushed" -gt 0 ] && parts="${parts}  ${GREEN}${bundle_pushed} pushed${RESET}"
    [ "$bundle_failed" -gt 0 ] && parts="${parts}  ${RED}${bundle_failed} failed${RESET}"
    [ -n "$parts" ] && printf "  └─%s\n" "$parts"
}

# ─────────────────────────────────────────────────────────────────────────────
# process_tgz_file_docker <path> <index> <total>
#
# Fallback: docker load → docker tag → docker push (sequential, with output).
# ─────────────────────────────────────────────────────────────────────────────
process_tgz_file_docker() {
    local file="$1"
    local idx="$2"
    local total="$3"

    local relative_path="${file#${tgz_directory}/}"
    [ "$relative_path" = "$file" ] && relative_path=$(basename "$file")

    local file_size
    file_size=$(du -sh "$file" 2>/dev/null | awk '{print $1}' || echo "?")

    printf "\n${BOLD}[%d/%d]${RESET} %s  ${DIM}(%s)${RESET}\n" "$idx" "$total" "$relative_path" "$file_size"

    # ── Disk space check ─────────────────────────────────────────────────────
    local required_kb available_kb
    required_kb=$(du -ks "$file" | awk '{print $1}')
    available_kb=$(df -Pk . | awk 'NR==2 {print $4}')
    if [ "$required_kb" -gt "$available_kb" ]; then
        log_error "Insufficient disk space to load ${relative_path}"
        log_error "  Required : $(( required_kb / 1024 )) MB"
        log_error "  Available: $(( available_kb / 1024 )) MB"
        failed_images+=("$relative_path (disk space)")
        fail_count=$((fail_count + 1))
        return 1
    fi

    # ── docker load ──────────────────────────────────────────────────────────
    log_info "Loading ${DIM}${relative_path}${RESET} …"
    local load_output load_rc=0
    load_output=$(docker load -i "$file" 2>&1) || load_rc=$?

    if [ "$load_rc" -ne 0 ]; then
        log_fail "docker load failed for ${relative_path}"
        echo "$load_output" | while IFS= read -r line; do
            printf "    ${RED}│${RESET} ${DIM}%s${RESET}\n" "$line"
        done
        failed_images+=("$relative_path")
        fail_count=$((fail_count + 1))
        return 1
    fi

    local loaded_count
    loaded_count=$(echo "$load_output" | grep -c "^Loaded image" 2>/dev/null || echo 0)
    log_info "Loaded ${BOLD}${loaded_count}${RESET} image(s)"

    # ── docker tag + docker push (sequential, visible output) ────────────────
    local bundle_pushed=0 bundle_failed=0 img_idx=0

    while IFS= read -r line; do
        local image_ref=""
        case "$line" in
            "Loaded image: "*)  image_ref="${line#Loaded image: }" ;;
            "Loaded image ID: "*) image_ref="${line#Loaded image ID: }" ;;
        esac
        [ -z "$image_ref" ] && continue

        img_idx=$((img_idx + 1))
        local target="${registry}/${image_ref}"
        local service_name="${image_ref%%:*}"
        service_name="${service_name##*/}"

        printf "  ${DIM}[%d/%d]${RESET} %s\n" "$img_idx" "$loaded_count" "$image_ref"

        if [ "$create_ecr" = true ]; then
            create_ecr_repository "$service_name" || true
        fi

        # Tag
        printf "    ${DIM}tagging → %s${RESET}\n" "$target"
        if ! docker tag "$image_ref" "$target" 2>/dev/null; then
            log_fail "docker tag failed: ${image_ref} → ${target}"
            failed_images+=("$image_ref")
            fail_count=$((fail_count + 1))
            bundle_failed=$((bundle_failed + 1))
            continue
        fi

        # Push — capture to temp file so exit code is in the parent shell.
        printf "    ${DIM}pushing → %s …${RESET}\n" "$target"
        local push_tmp push_rc=0
        push_tmp=$(mktemp)
        docker push "$target" >"$push_tmp" 2>&1 || push_rc=$?
        while IFS= read -r pline; do
            printf "    ${DIM}%s${RESET}\n" "$pline"
        done <"$push_tmp"
        rm -f "$push_tmp"

        if [ "$push_rc" -eq 0 ]; then
            log_done "Pushed → ${target}"
            success_count=$((success_count + 1))
            bundle_pushed=$((bundle_pushed + 1))
            verified_images+=("$target")
        else
            log_fail "${image_ref} → ${target}"
            failed_images+=("$image_ref")
            fail_count=$((fail_count + 1))
            bundle_failed=$((bundle_failed + 1))
        fi
    done <<< "$load_output"

    # Per-file mini-summary
    local parts=""
    [ "$bundle_pushed" -gt 0 ] && parts="${parts}  ${GREEN}${bundle_pushed} pushed${RESET}"
    [ "$bundle_failed" -gt 0 ] && parts="${parts}  ${RED}${bundle_failed} failed${RESET}"
    [ -n "$parts" ] && printf "  └─%s\n" "$parts"
}

# ─────────────────────────────────────────────────────────────────────────────
# process_looker — optional ng-dashboard / Looker image (interactive only)
# ─────────────────────────────────────────────────────────────────────────────
process_looker() {
    if [ "$non_interactive" = true ]; then
        log_debug "Skipping ng-dashboard (non-interactive mode)"
        return
    fi

    printf "\n${BOLD}Optional: ng-dashboard (Looker)${RESET}\n"
    read -rp "  Do you want to install ng-dashboard? [yes/no]: " response
    [[ "$response" != "yes" ]] && return

    read -rp "  DockerHub username: " DOCKERHUB_USERNAME
    read -rsp "  DockerHub password: " DOCKERHUB_PASSWORD
    echo
    read -rp "  Harness release version (e.g. 0.37.0): " RELEASE_VERSION

    if [ -z "$DOCKERHUB_USERNAME" ] || [ -z "$DOCKERHUB_PASSWORD" ] || [ -z "$RELEASE_VERSION" ]; then
        log_warn "Incomplete credentials or version — skipping ng-dashboard"
        return
    fi

    echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
    if [ $? -ne 0 ]; then
        log_error "DockerHub login failed — skipping ng-dashboard"
        return
    fi

    local tgz_name="harness-${RELEASE_VERSION}.tgz"
    local dir_name="harness-${RELEASE_VERSION}"
    rm -rf "$tgz_name" "$dir_name"

    local url="https://github.com/harness/helm-charts/releases/download/harness-${RELEASE_VERSION}/${tgz_name}"
    log_info "Downloading ${url}"
    if ! curl -fSL -o "$tgz_name" "$url"; then
        log_error "Failed to download ${tgz_name}"
        docker logout
        return
    fi

    mkdir "$dir_name"
    tar -xzf "$tgz_name" -C "$dir_name"

    local looker_tag
    looker_tag=$(grep "looker" "${dir_name}/harness/images.txt" 2>/dev/null || true)
    if [ -z "$looker_tag" ]; then
        log_warn "Looker image not found in images.txt — skipping"
        rm -rf "$tgz_name" "$dir_name"
        docker logout
        return
    fi

    log_info "Pulling ${looker_tag}"
    docker pull "$looker_tag"

    local looker_image
    looker_image=$(echo "$looker_tag" | sed 's|^[^/]*/||')
    local looker_target="${registry}/${looker_image}"

    if docker tag "$looker_tag" "$looker_target" && docker push "$looker_target"; then
        log_done "Pushed Looker → ${looker_target}"
        success_count=$((success_count + 1))
        verified_images+=("$looker_target")
    else
        log_fail "Failed to push Looker: ${looker_image}"
        failed_images+=("$looker_image")
        fail_count=$((fail_count + 1))
    fi

    rm -rf "$tgz_name" "$dir_name"
    docker logout
}

# ─────────────────────────────────────────────────────────────────────────────
# Argument parsing
# ─────────────────────────────────────────────────────────────────────────────
# Long option compatibility shim for getopts.
# Supports:
#   --use-skopeo -> -s
#   --help       -> -h
if [ "$#" -gt 0 ]; then
    normalized_args=()
    for arg in "$@"; do
        case "$arg" in
            --use-skopeo) normalized_args+=("-s") ;;
            --help)       normalized_args+=("-h") ;;
            *)            normalized_args+=("$arg") ;;
        esac
    done
    set -- "${normalized_args[@]}"
fi

while getopts "hr:f:d:Dcsne" opt; do
    case "$opt" in
        h) show_help ;;
        r) registry="$OPTARG" ;;
        f) tgz_file="$OPTARG" ;;
        d) tgz_directory="$OPTARG" ;;
        s) request_skopeo=true ;;
        D) debug=true ;;
        c) cleanup=true ;;
        n) non_interactive=true ;;
        e) create_ecr=true ;;
        *) show_help ;;
    esac
done

# ─────────────────────────────────────────────────────────────────────────────
# Validation
# ─────────────────────────────────────────────────────────────────────────────
errors=0
if [ -z "$registry" ]; then
    log_error "Registry not specified (-r)"
    errors=$((errors + 1))
fi
if [ -z "$tgz_file" ] && [ -z "$tgz_directory" ]; then
    log_error "No source specified — use -f <file> or -d <directory>"
    errors=$((errors + 1))
fi
if [ -n "$tgz_file" ] && [ -n "$tgz_directory" ]; then
    log_error "-f and -d are mutually exclusive"
    errors=$((errors + 1))
fi
if [ -n "$tgz_file" ] && [ ! -f "$tgz_file" ]; then
    log_error "File not found: ${tgz_file}"
    errors=$((errors + 1))
fi
if [ -n "$tgz_directory" ] && [ ! -d "$tgz_directory" ]; then
    log_error "Directory not found: ${tgz_directory}"
    errors=$((errors + 1))
fi
if [ "$errors" -gt 0 ]; then
    printf "\nRun ${BOLD}$(basename "$0") -h${RESET} for usage.\n" >&2
    exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# Detect push method
# ─────────────────────────────────────────────────────────────────────────────
if [ "$request_skopeo" = true ]; then
    if command -v skopeo &>/dev/null && command -v jq &>/dev/null; then
        use_skopeo=true
    else
        use_skopeo=false
        log_warn "skopeo mode requested (-s), but skopeo/jq not found — falling back to docker mode"
    fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# Banner
# ─────────────────────────────────────────────────────────────────────────────
echo ""
printf "${BOLD}${CYAN}╔══════════════════════════════════════════════════════╗${RESET}\n"
printf "${BOLD}${CYAN}║   Harness Airgap Image Pusher                       ║${RESET}\n"
printf "${BOLD}${CYAN}╚══════════════════════════════════════════════════════╝${RESET}\n"
echo ""
log_info "Registry : ${BOLD}${registry}${RESET}"
[ -n "$tgz_file"      ] && log_info "Source   : ${BOLD}${tgz_file}${RESET}"
[ -n "$tgz_directory" ] && log_info "Source   : ${BOLD}${tgz_directory}${RESET}"
if [ "$use_skopeo" = true ]; then
    log_info "Method   : ${BOLD}skopeo${RESET}  ${DIM}(copying, no docker load)${RESET}"
else
    log_info "Method   : ${BOLD}docker${RESET}  ${DIM}(load → tag → push)${RESET}"
    if [ "$request_skopeo" = true ]; then
        log_info "Install skopeo + jq and re-run with --use-skopeo for faster daemonless uploads"
    else
        log_info "Tip      : Install skopeo + jq and use ${BOLD}--use-skopeo${RESET} for faster daemonless uploads"
    fi
fi
[ "$create_ecr" = true ]       && log_info "ECR auto-create enabled  (region: ${AWS_REGION:-not set})"
[ "$cleanup" = true ]          && log_info "Local image cleanup enabled after push"
[ "$non_interactive" = true ]  && log_info "Non-interactive mode"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Optional Looker step
# ─────────────────────────────────────────────────────────────────────────────
process_looker

# ─────────────────────────────────────────────────────────────────────────────
# Collect files
# ─────────────────────────────────────────────────────────────────────────────
declare -a tgz_files=()

if [ -n "$tgz_file" ]; then
    tgz_files=("$tgz_file")
else
    while IFS= read -r _f; do
        [ -n "$_f" ] && tgz_files+=("$_f")
    done < <(find "$tgz_directory" -name "*.tgz" -type f | sort)
fi

total_count=${#tgz_files[@]}

if [ "$total_count" -eq 0 ]; then
    log_error "No .tgz files found${tgz_directory:+ in ${tgz_directory}}"
    exit 1
fi

log_step "Processing ${total_count} bundle(s)"
[ "$use_skopeo" = true ] && log_info "Runtime mode: ${BOLD}skopeo${RESET}"
[ "$use_skopeo" = true ] || log_info "Runtime mode: ${BOLD}docker${RESET}"
[ -n "$tgz_directory" ] && log_info "Found ${total_count} .tgz file(s) in ${BOLD}${tgz_directory}${RESET}"

# ─────────────────────────────────────────────────────────────────────────────
# Main processing loop
# ─────────────────────────────────────────────────────────────────────────────
for idx in "${!tgz_files[@]}"; do
    if [ "$use_skopeo" = true ]; then
        process_tgz_file_skopeo "${tgz_files[$idx]}" "$((idx + 1))" "$total_count"
    else
        process_tgz_file_docker "${tgz_files[$idx]}" "$((idx + 1))" "$total_count"
    fi
done

# ─────────────────────────────────────────────────────────────────────────────
# Cleanup (docker mode only)
# ─────────────────────────────────────────────────────────────────────────────
if [ "$cleanup" = true ] && [ "$use_skopeo" != true ]; then
    cleanup_images
fi

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
END_TIME=$(date +%s)
ELAPSED=$(( END_TIME - START_TIME ))
ELAPSED_FMT=$(printf '%dm %ds' $(( ELAPSED / 60 )) $(( ELAPSED % 60 )))

echo ""
printf "${BOLD}${CYAN}╔══════════════════════════════════════════════════════╗${RESET}\n"
printf "${BOLD}${CYAN}║   Summary                                           ║${RESET}\n"
printf "${BOLD}${CYAN}╚══════════════════════════════════════════════════════╝${RESET}\n"
echo ""
log_info "Bundles processed : ${BOLD}${total_count}${RESET}"
log_info "Images pushed     : ${BOLD}${GREEN}${success_count}${RESET}"
if [ "$fail_count" -gt 0 ]; then
    log_info "Images failed     : ${BOLD}${RED}${fail_count}${RESET}"
else
    log_info "Images failed     : ${BOLD}${fail_count}${RESET}"
fi
log_info "Elapsed           : ${BOLD}${ELAPSED_FMT}${RESET}"
echo ""

if [ "${#failed_images[@]}" -gt 0 ]; then
    printf "${RED}${BOLD}Failed images:${RESET}\n"
    for img in "${failed_images[@]}"; do
        printf "  ${RED}✗${RESET} %s\n" "$img"
    done
    echo ""
    exit 1
fi
