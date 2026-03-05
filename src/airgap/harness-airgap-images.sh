#!/usr/bin/env bash
#
# harness-airgap-images.sh
#
# Load airgap .tgz bundle(s) into Docker and push every image to a target
# registry. Supports a single file (-f) or a directory tree (-d).
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
log_skip()  { printf "${DIM}  ↷ skipped: %s${RESET}\n" "$*"; }
log_fail()  { printf "${RED}  ✗ failed:  %s${RESET}\n" "$*" >&2; }

_spin() {
    local pid="$1" msg="$2"
    local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    local i=0
    if [ -t 1 ]; then
        tput civis 2>/dev/null || true
        while kill -0 "$pid" 2>/dev/null; do
            printf "\r  ${CYAN}%s${RESET}  %s " "${frames[$((i % 10))]}" "$msg"
            sleep 0.1
            i=$((i + 1))
        done
        tput cnorm 2>/dev/null || true
        printf "\r\033[K"   # erase spinner line
    fi
}

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

success_count=0
fail_count=0
skip_count=0
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
  -c                  Clean up locally loaded Docker images after pushing
  -e                  Create ECR repository before push  (requires: aws configure + AWS_REGION)
  -n                  Non-interactive mode — skip optional prompts (e.g. ng-dashboard)
  -D                  Enable debug output
  -h                  Show this help

${BOLD}Environment variables (ECR only):${RESET}
  AWS_REGION          AWS region for ECR operations (required with -e)
  ECR_NAMESPACE       Optional namespace prefix for ECR repository names

${BOLD}Examples:${RESET}
  # Push all bundles in a directory
  ./$(basename "$0") -r myregistry.example.com/harness -d ./bundles

  # Push a single bundle
  ./$(basename "$0") -r myregistry.example.com/harness -f ./bundles/platform_images.tgz

  # Non-interactive, with cleanup, ECR auto-create
  ./$(basename "$0") -r 123456789.dkr.ecr.us-east-1.amazonaws.com/harness \\
    -d ./bundles -n -c -e
EOF
    exit 1
}

# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

# Returns 0 (skip push) if the remote tag exists AND its config digest matches
# the local image's ID.  Returns 1 (push needed) if the tag is absent or
# the content differs (stale tag → will overwrite).
#
# Args: <local_image_ref>  <remote_image_ref>
#
# Digest comparison works for single-arch images (config digest == image ID).
# For multi-arch manifest lists we fall back to tag-existence only, because
# the top-level manifest has no single config digest to compare against.
check_image_in_registry() {
    local local_ref="$1"
    local remote_ref="$2"

    # ── 1. Does the tag exist at all? ─────────────────────────────────────────
    local manifest_json
    manifest_json=$(docker manifest inspect "$remote_ref" 2>/dev/null) || return 1
    [ -z "$manifest_json" ] && return 1

    # ── 2. Get the local image config digest ─────────────────────────────────
    local local_id
    local_id=$(docker inspect --format='{{.Id}}' "$local_ref" 2>/dev/null) || return 1
    [ -z "$local_id" ] && return 1

    # ── 3. Extract the remote config digest (python3 for safe JSON parsing) ───
    local remote_digest
    if command -v python3 &>/dev/null; then
        remote_digest=$(printf '%s' "$manifest_json" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'manifests' in data:          # manifest list / multi-arch
        print('multiarch')
    else:
        print(data.get('config', {}).get('digest', ''))
except Exception:
    print('')
" 2>/dev/null) || remote_digest=""
    else
        # Fallback: crude grep — works for the common single-arch manifest layout
        remote_digest=$(printf '%s' "$manifest_json" \
            | grep -o '"config"[^}]*"digest":"sha256:[^"]*"' \
            | grep -o 'sha256:[^"]*' | head -1 || true)
    fi

    case "$remote_digest" in
        "multiarch")
            # Can't compare digests for a manifest list; tag exists → skip.
            return 0 ;;
        "$local_id")
            # Exact content match — nothing to push.
            return 0 ;;
        "")
            # Couldn't parse digest; fall back to "tag exists → skip".
            return 0 ;;
        *)
            # Tag exists but content differs → push (overwrite stale tag).
            return 1 ;;
    esac
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
# process_tgz_file <path> <index> <total>
# ─────────────────────────────────────────────────────────────────────────────
process_tgz_file() {
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
        log_error "Insufficient disk space to extract ${relative_path}"
        log_error "  Required : $(( required_kb / 1024 )) MB"
        log_error "  Available: $(( available_kb / 1024 )) MB"
        failed_images+=("$relative_path (disk space)")
        fail_count=$((fail_count + 1))
        return 1
    fi

    # ── Load the bundle ───────────────────────────────────────────────────────
    # Use pv for byte-level progress when available; fall back to a spinner.
    log_debug "Running: docker load -i ${file}"
    local load_tmp load_rc=0
    load_tmp=$(mktemp)

    if command -v pv &>/dev/null; then
        pv -N "  loading" "$file" | docker load > "$load_tmp" 2>&1 || load_rc=$?
    else
        docker load -i "$file" > "$load_tmp" 2>&1 &
        local load_pid=$!
        _spin "$load_pid" "Loading ${relative_path}"
        wait "$load_pid" 2>/dev/null || load_rc=$?
    fi

    local load_output
    load_output=$(cat "$load_tmp")
    rm -f "$load_tmp"

    if [ "$load_rc" -ne 0 ]; then
        log_fail "docker load failed for ${relative_path}"
        echo "$load_output" | while IFS= read -r line; do
            printf "    ${RED}│${RESET} ${DIM}%s${RESET}\n" "$line"
        done
        failed_images+=("$relative_path")
        fail_count=$((fail_count + 1))
        return 1
    fi

    # Count and report loaded images
    local loaded_count
    loaded_count=$(echo "$load_output" | grep -c "^Loaded image" 2>/dev/null || echo 0)
    log_info "Loaded ${BOLD}${loaded_count}${RESET} image(s) from ${DIM}${relative_path}${RESET}"

    # ── Tag and push every loaded image ──────────────────────────────────────
    local bundle_pushed=0 bundle_skipped=0 bundle_failed=0 img_idx=0

    while IFS= read -r line; do
        local image_ref=""
        if [[ "$line" =~ ^Loaded\ image:\ (.+)$ ]]; then
            image_ref="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^Loaded\ image\ ID:\ (.+)$ ]]; then
            image_ref="${BASH_REMATCH[1]}"
        fi
        [ -z "$image_ref" ] && continue

        img_idx=$((img_idx + 1))
        local target="${registry}/${image_ref}"
        local service_name="${image_ref%%:*}"
        service_name="${service_name##*/}"   # strip org prefix for ECR repo name

        printf "  ${DIM}[%d/%d]${RESET} %s\n" "$img_idx" "$loaded_count" "$image_ref"

        if check_image_in_registry "$image_ref" "$target"; then
            log_skip "digest unchanged — already in registry: ${DIM}${target}${RESET}"
            skip_count=$((skip_count + 1))
            bundle_skipped=$((bundle_skipped + 1))
            verified_images+=("$target")
            continue
        fi

        if [ "$create_ecr" = true ]; then
            create_ecr_repository "$service_name" || true
        fi

        if ! docker tag "$image_ref" "$target" 2>/dev/null; then
            log_fail "docker tag failed: ${image_ref} → ${target}"
            failed_images+=("$image_ref")
            fail_count=$((fail_count + 1))
            bundle_failed=$((bundle_failed + 1))
            continue
        fi

        # Push — stream output directly when on a terminal (native progress bars);
        # use a spinner + error capture when stdout is not a terminal (CI/scripts).
        local push_rc=0
        if [ -t 1 ]; then
            docker push "$target" || push_rc=$?
        else
            local push_tmp push_pid
            push_tmp=$(mktemp)
            docker push "$target" > "$push_tmp" 2>&1 &
            push_pid=$!
            _spin "$push_pid" "Pushing ${image_ref}"
            wait "$push_pid" 2>/dev/null || push_rc=$?

            if [ "$push_rc" -ne 0 ]; then
                cat "$push_tmp" | while IFS= read -r eline; do
                    printf "    ${RED}│${RESET} ${DIM}%s${RESET}\n" "$eline"
                done
            else
                # Show digest line on success so there's something visible
                local digest
                digest=$(grep "digest:" "$push_tmp" 2>/dev/null | tail -1 || true)
                [ -n "$digest" ] && printf "    ${DIM}%s${RESET}\n" "$digest"
            fi
            rm -f "$push_tmp"
        fi

        if [ "$push_rc" -eq 0 ]; then
            success_count=$((success_count + 1))
            bundle_pushed=$((bundle_pushed + 1))
            verified_images+=("$target")
            log_done "Pushed → ${target}"
        else
            log_fail "${image_ref}  →  ${target}"
            failed_images+=("$image_ref")
            fail_count=$((fail_count + 1))
            bundle_failed=$((bundle_failed + 1))
        fi
    done <<< "$load_output"

    # ── Per-file mini-summary ─────────────────────────────────────────────────
    local parts=""
    [ "$bundle_pushed"  -gt 0 ] && parts="${parts}  ${GREEN}${bundle_pushed} pushed${RESET}"
    [ "$bundle_skipped" -gt 0 ] && parts="${parts}  ${DIM}${bundle_skipped} skipped${RESET}"
    [ "$bundle_failed"  -gt 0 ] && parts="${parts}  ${RED}${bundle_failed} failed${RESET}"
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

    if check_image_in_registry "$looker_tag" "$looker_target"; then
        log_skip "Looker digest unchanged — already in registry: ${looker_target}"
        verified_images+=("$looker_target")
    elif docker tag "$looker_tag" "$looker_target" && docker push "$looker_target"; then
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
# Banner
# ─────────────────────────────────────────────────────────────────────────────
echo ""
printf "${BOLD}${CYAN}╔══════════════════════════════════════════════════════╗${RESET}\n"
printf "${BOLD}${CYAN}║   Harness Airgap Image Pusher                       ║${RESET}\n"
printf "${BOLD}${CYAN}╚══════════════════════════════════════════════════════╝${RESET}\n"
echo ""
log_info "Registry    : ${BOLD}${registry}${RESET}"
[ -n "$tgz_file"      ] && log_info "Source file : ${BOLD}${tgz_file}${RESET}"
[ -n "$tgz_directory" ] && log_info "Source dir  : ${BOLD}${tgz_directory}${RESET}"
[ "$create_ecr"   = true ] && log_info "ECR auto-create enabled  (region: ${AWS_REGION:-not set})"
[ "$cleanup"      = true ] && log_info "Local image cleanup enabled after push"
[ "$non_interactive" = true ] && log_info "Non-interactive mode"
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
    mapfile -t tgz_files < <(find "$tgz_directory" -name "*.tgz" -type f | sort)
fi

total_count=${#tgz_files[@]}

if [ "$total_count" -eq 0 ]; then
    log_error "No .tgz files found${tgz_directory:+ in ${tgz_directory}}"
    exit 1
fi

log_step "Processing ${total_count} bundle(s)"
[ -n "$tgz_directory" ] && log_info "Found ${total_count} .tgz file(s) in ${BOLD}${tgz_directory}${RESET}"

# ─────────────────────────────────────────────────────────────────────────────
# Main processing loop
# ─────────────────────────────────────────────────────────────────────────────
for idx in "${!tgz_files[@]}"; do
    process_tgz_file "${tgz_files[$idx]}" "$((idx + 1))" "$total_count"
done

# ─────────────────────────────────────────────────────────────────────────────
# Cleanup
# ─────────────────────────────────────────────────────────────────────────────
if [ "$cleanup" = true ]; then
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
log_info "Images skipped    : ${BOLD}${DIM}${skip_count}${RESET}  ${DIM}(already in registry)${RESET}"
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
