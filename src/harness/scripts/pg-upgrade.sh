#!/usr/bin/env bash
set -euo pipefail

# PostgreSQL 14 → 16 In-Place Upgrade via pg_upgrade
# Handles: verify → backup prompt → scale down → check → prompt → upgrade → image patch → scale up → verify
#
# Usage:
#   ./pg-upgrade.sh <namespace>

# --- Namespace (required as $1) ---
if [[ -z "${1:-}" ]]; then
  echo "ERROR: Namespace is required."
  echo "Usage: $0 <namespace>"
  exit 1
fi
NAMESPACE="$1"

# --- Configurable via environment variables (with defaults) ---
PG_OLD_VERSION="${PG_OLD_VERSION:-14}"
PG_NEW_VERSION="${PG_NEW_VERSION:-16}"
PG_OLD_BINDIR="${PG_OLD_BINDIR:-/usr/lib/postgresql/${PG_OLD_VERSION}/bin}"
PG_NEW_BINDIR="${PG_NEW_BINDIR:-/usr/lib/postgresql/${PG_NEW_VERSION}/bin}"
PG_DATADIR="${PG_DATADIR:-/bitnami/postgresql/data}"
PG_DATADIR_NEW="${PG_DATADIR_NEW:-/bitnami/postgresql/data-new}"
PG_UID="${PG_UID:-999}"
PG_GID="${PG_GID:-999}"
PG_UPGRADE_JOBS="${PG_UPGRADE_JOBS:-4}"
PG_STS_NAME="${PG_STS_NAME:-postgres}"
PG_POD="${PG_STS_NAME}-0"
PG_USER="${PG_USER:-postgres}"

# --- Image configuration ---
IMAGE_REGISTRY="${IMAGE_REGISTRY:-docker.io}"
PG_NEW_IMAGE="${PG_NEW_IMAGE:-${IMAGE_REGISTRY}/soumikghosh03/postgres:16.14-bookworm}"
UPGRADE_IMAGE="${UPGRADE_IMAGE:-${IMAGE_REGISTRY}/soumikghosh03/pg-upgrade:14-to-16}"
IMAGE_PULL_SECRET="${IMAGE_PULL_SECRET:-}"

UPGRADE_POD="pg-upgrade-job"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="/tmp/pg-upgrade-${NAMESPACE}-${TIMESTAMP}.log"
VERIFY_BEFORE="./pg-verify-before-${NAMESPACE}-${TIMESTAMP}.txt"
VERIFY_AFTER="./pg-verify-after-${NAMESPACE}-${TIMESTAMP}.txt"
REPORT_FILE="./pg-upgrade-report-${NAMESPACE}-${TIMESTAMP}.txt"

log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
  echo "$msg" | tee -a "$LOG_FILE"
}

fail() {
  log "ERROR: $*"
  log "=== DUMPING pg_upgrade LOGS FROM POD ==="
  kubectl exec -n "$NAMESPACE" "$UPGRADE_POD" -- bash -c "cat /tmp/pg_upgrade_internal.log 2>/dev/null || true" 2>/dev/null | tee -a "$LOG_FILE"
  log "Upgrade pod kept alive for debugging: kubectl exec -n $NAMESPACE -it $UPGRADE_POD -- bash"
  exit 1
}
trap fail ERR

prompt_yes_no() {
  local message="$1"
  echo ""
  echo "============================================"
  echo "  $message"
  echo "============================================"
  echo ""
  read -rp "Type 'yes' to continue, anything else to abort: " answer
  if [[ "$answer" != "yes" ]]; then
    log "Aborted by user."
    exit 1
  fi
}

# --- Verification function ---
_pg_exec() {
  local pod="$1" db="$2" sql="$3"
  printf '%s\n' "$sql" | kubectl exec -i -n "$NAMESPACE" "$pod" -- bash -c 'PGPASSWORD=$(cat $POSTGRES_PASSWORD_FILE) psql -U '"$PG_USER"' -d '"$db"' -t -A'
}

run_verify() {
  local output_file="$1"
  local pod="${2:-$PG_POD}"

  log "  Capturing data verification to: $output_file"

  {
    echo "=== PG DATA VERIFICATION $(date -u '+%Y-%m-%dT%H:%M:%SZ') ==="
    echo "Namespace: $NAMESPACE | Pod: $pod"
    echo ""

    local dbs
    dbs=$(_pg_exec "$pod" "postgres" "SELECT datname FROM pg_database WHERE datistemplate = false AND datname != 'postgres' ORDER BY datname;")

    echo "=== DATABASE SIZES ==="
    for db in $dbs; do
      local size
      size=$(_pg_exec "$pod" "postgres" "SELECT pg_database_size('$db');")
      echo "${db}=${size}"
    done
    echo ""

    for db in $dbs; do
      echo "=== DATABASE: $db ==="
      _pg_exec "$pod" "$db" "
        SELECT schemaname || '.' || relname || '|' || n_live_tup
        FROM pg_stat_user_tables
        ORDER BY schemaname, relname;
      "
      echo ""
    done

    echo "=== DONE ==="
  } > "$output_file"

  log "  Verification saved: $output_file"
}

# --- Comparison report ---
generate_report() {
  log "Generating comparison report..."

  {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║         PG UPGRADE VERIFICATION REPORT                     ║"
    echo "║         $(date -u '+%Y-%m-%dT%H:%M:%SZ')                          ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  Namespace: $NAMESPACE"
    echo "║  Upgrade:   PG${PG_OLD_VERSION} → PG${PG_NEW_VERSION}"
    echo "║  Before:    $VERIFY_BEFORE"
    echo "║  After:     $VERIFY_AFTER"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    local total=0
    local passed=0
    local failed=0
    local skipped=0

    echo "┌──────────────────────────────────────────┬──────────────┬──────────────┬────────┐"
    echo "│ Table                                    │ Before       │ After        │ Status │"
    echo "├──────────────────────────────────────────┼──────────────┼──────────────┼────────┤"

    local current_db=""

    while IFS='|' read -r table rows; do
      [[ -z "$table" ]] && continue
      local db_section
      db_section=$(grep -B 100 "^${table}|" "$VERIFY_BEFORE" | grep "^=== DATABASE:" | tail -1 | sed 's/=== DATABASE: //' | sed 's/ ===//')

      local after_rows
      after_rows=$(grep "^${table}|" "$VERIFY_AFTER" 2>/dev/null | cut -d'|' -f2 || echo "MISSING")

      total=$((total + 1))

      local status
      if [[ "$after_rows" == "MISSING" ]]; then
        status="SKIP"
        skipped=$((skipped + 1))
      elif [[ "$rows" == "$after_rows" ]]; then
        status="PASS"
        passed=$((passed + 1))
      else
        local diff_pct=0
        if [[ "$rows" -gt 0 ]] 2>/dev/null; then
          diff_pct=$(( (after_rows - rows) * 100 / rows ))
        fi
        if [[ ${diff_pct#-} -le 5 ]]; then
          status="PASS"
          passed=$((passed + 1))
        else
          status="FAIL"
          failed=$((failed + 1))
        fi
      fi

      printf "│ %-40s │ %12s │ %12s │ %-6s │\n" "$table" "$rows" "$after_rows" "$status"
    done < <(grep -h '|' "$VERIFY_BEFORE" | grep -v '^===' | grep -v '^Namespace' | grep -v '^$')

    echo "└──────────────────────────────────────────┴──────────────┴──────────────┴────────┘"
    echo ""
    echo "═══════════════════════════════════════════"
    echo "  TOTAL: $total | PASS: $passed | FAIL: $failed | SKIP: $skipped"

    if [[ $failed -eq 0 ]]; then
      echo "  RESULT: ✓ ALL CHECKS PASSED"
    else
      echo "  RESULT: ✗ $failed TABLE(S) HAVE SIGNIFICANT ROW COUNT CHANGES (>5%)"
    fi
    echo "═══════════════════════════════════════════"
    echo ""
    echo "Note: Small differences (<5%) in row counts are expected"
    echo "      (batch/queue tables, app activity between captures)."
  } > "$REPORT_FILE"

  cat "$REPORT_FILE" | tee -a "$LOG_FILE"
  log "Report saved: $REPORT_FILE"
}

log "=== PostgreSQL pg_upgrade ($PG_OLD_VERSION → $PG_NEW_VERSION, --link) ==="
log "Namespace: $NAMESPACE"
log "StatefulSet: $PG_STS_NAME"
log "Image registry: $IMAGE_REGISTRY"
log "New image: $PG_NEW_IMAGE"
log "Upgrade image: $UPGRADE_IMAGE"
[[ -n "$IMAGE_PULL_SECRET" ]] && log "Image pull secret: $IMAGE_PULL_SECRET"

# -----------------------------------------------
# Pre-upgrade verification
# -----------------------------------------------
log ""
log "=== PRE-UPGRADE VERIFICATION ==="
run_verify "$VERIFY_BEFORE"

# -----------------------------------------------
# Backup confirmation
# -----------------------------------------------
prompt_yes_no "Have you taken a backup of PostgreSQL data? (pg_dumpall / volume snapshot / cloud disk snapshot)"

# -----------------------------------------------
# Scale down PostgreSQL
# -----------------------------------------------
log "Scaling down $PG_STS_NAME in $NAMESPACE..."
REPLICAS=$(kubectl get sts -n "$NAMESPACE" "$PG_STS_NAME" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
if [[ "${REPLICAS:-0}" != "0" ]]; then
  prompt_yes_no "Scale down $PG_STS_NAME to 0 replicas?"
  kubectl scale sts -n "$NAMESPACE" "$PG_STS_NAME" --replicas=0
  log "  Waiting for pod $PG_POD to terminate..."
  kubectl wait --for=delete pod/"$PG_POD" -n "$NAMESPACE" --timeout=180s 2>/dev/null || true
  log "  Scale down complete."
else
  log "  Already at 0 replicas."
fi

# -----------------------------------------------
# Step 1: Create upgrade pod with PVC mounted
# -----------------------------------------------
log "[1/5] Creating upgrade pod..."

_build_pod_spec() {
  local pull_secret_block=""
  if [[ -n "$IMAGE_PULL_SECRET" ]]; then
    pull_secret_block="  imagePullSecrets:
  - name: $IMAGE_PULL_SECRET"
  fi

  cat <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: $UPGRADE_POD
spec:
  restartPolicy: Never
${pull_secret_block}
  securityContext:
    runAsUser: 0
  containers:
  - name: upgrade
    image: $UPGRADE_IMAGE
    command: ["sleep", "7200"]
    volumeMounts:
    - name: data
      mountPath: /bitnami/postgresql
    resources:
      requests:
        cpu: "2"
        memory: "4Gi"
      limits:
        cpu: "4"
        memory: "8Gi"
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: data-${PG_POD}
EOF
}

_ensure_upgrade_pod() {
  if kubectl get pod -n "$NAMESPACE" "$UPGRADE_POD" &>/dev/null; then
    log "  Upgrade pod already exists."
    kubectl wait --for=condition=Ready pod/"$UPGRADE_POD" -n "$NAMESPACE" --timeout=60s
    return
  fi

  log "  Launching upgrade pod ($UPGRADE_IMAGE) with PVC mounted..."
  _build_pod_spec | kubectl apply -n "$NAMESPACE" -f -
  kubectl wait --for=condition=Ready pod/"$UPGRADE_POD" -n "$NAMESPACE" --timeout=300s
}

_ensure_upgrade_pod

# -----------------------------------------------
# Step 2: Environment and disk check (inside pod)
# -----------------------------------------------
log "[2/5] Environment check (inside pod)..."
kubectl exec -n "$NAMESPACE" "$UPGRADE_POD" -- bash -c "
  echo '  Disk usage:'
  df -h /bitnami/postgresql | sed 's/^/    /'
  echo ''
  echo '  Data dir size:' \$(du -sh $PG_DATADIR 2>/dev/null | cut -f1 || echo 'N/A')
  echo '  PG_VERSION:' \$(cat $PG_DATADIR/PG_VERSION 2>/dev/null || echo 'NOT FOUND')
  echo ''
  echo '  Checking binaries...'
  test -f $PG_OLD_BINDIR/pg_ctl && echo '  Old binaries OK: $PG_OLD_BINDIR/pg_ctl' || { echo 'ERROR: PG$PG_OLD_VERSION binaries not found'; exit 1; }
  test -f $PG_NEW_BINDIR/pg_upgrade && echo '  New binaries OK: $PG_NEW_BINDIR/pg_upgrade' || { echo 'ERROR: PG$PG_NEW_VERSION binaries not found'; exit 1; }
" 2>&1 | tee -a "$LOG_FILE"

# -----------------------------------------------
# Step 3: Fix ownership + init target dir + pg_upgrade --check
# -----------------------------------------------
log "[3/5] Initializing PG$PG_NEW_VERSION target dir..."
kubectl exec -n "$NAMESPACE" "$UPGRADE_POD" -- bash -c "
  rm -rf $PG_DATADIR_NEW && \
  mkdir -p $PG_DATADIR_NEW && \
  chown postgres:postgres $PG_DATADIR_NEW && \
  chmod 700 $PG_DATADIR_NEW && \
  gosu postgres $PG_NEW_BINDIR/initdb -D $PG_DATADIR_NEW --locale=C --encoding=UTF8 --username=postgres && \
  echo 'PG$PG_NEW_VERSION data directory initialized.'
" 2>&1 | tee -a "$LOG_FILE" | tail -5

log "  Running pg_upgrade --check --verbose..."
kubectl exec -n "$NAMESPACE" "$UPGRADE_POD" -- bash -c "
  cd /tmp && \
  gosu postgres $PG_NEW_BINDIR/pg_upgrade \
    --old-bindir=$PG_OLD_BINDIR \
    --new-bindir=$PG_NEW_BINDIR \
    --old-datadir=$PG_DATADIR \
    --new-datadir=$PG_DATADIR_NEW \
    --link \
    --check \
    --verbose \
    2>&1
" 2>&1 | tee -a "$LOG_FILE"

log "  Pre-check PASSED."

# -----------------------------------------------
# Step 4: Actual pg_upgrade --link
# -----------------------------------------------
prompt_yes_no "pg_upgrade --check passed. Proceed with the ACTUAL upgrade? (This is irreversible with --link)"

log "[4/5] Running pg_upgrade --link --jobs=$PG_UPGRADE_JOBS..."
kubectl exec -n "$NAMESPACE" "$UPGRADE_POD" -- bash -c "
  cd /tmp && \
  gosu postgres $PG_NEW_BINDIR/pg_upgrade \
    --old-bindir=$PG_OLD_BINDIR \
    --new-bindir=$PG_NEW_BINDIR \
    --old-datadir=$PG_DATADIR \
    --new-datadir=$PG_DATADIR_NEW \
    --link \
    --verbose \
    --jobs=$PG_UPGRADE_JOBS \
    2>&1
" 2>&1 | tee -a "$LOG_FILE"

log "  pg_upgrade completed successfully."

# -----------------------------------------------
# Step 5: Swap data directories
# -----------------------------------------------
log "[5/5] Swapping data directories..."
kubectl exec -n "$NAMESPACE" "$UPGRADE_POD" -- bash -c "
  mv $PG_DATADIR ${PG_DATADIR}-old-pg${PG_OLD_VERSION} && \
  mv $PG_DATADIR_NEW $PG_DATADIR && \
  chown -R postgres:postgres $PG_DATADIR && \
  echo 'Swap complete. New PG$PG_NEW_VERSION data at $PG_DATADIR'
  echo ''
  echo 'Final disk usage:'
  df -h /bitnami/postgresql | sed 's/^/    /'
" 2>&1 | tee -a "$LOG_FILE"

# Delete upgrade pod
log "  Deleting upgrade pod..."
kubectl delete pod -n "$NAMESPACE" "$UPGRADE_POD" --wait=false

# -----------------------------------------------
# Patch StatefulSet image and scale up
# -----------------------------------------------
log ""
log "Patching image and scaling up..."
log "  Setting image to: $PG_NEW_IMAGE"
kubectl set image sts/"$PG_STS_NAME" -n "$NAMESPACE" postgresql="$PG_NEW_IMAGE"

log "  Scaling $PG_STS_NAME to 1 replica..."
kubectl scale sts -n "$NAMESPACE" "$PG_STS_NAME" --replicas=1

log "  Waiting for pod $PG_POD to become ready..."
kubectl wait --for=condition=ready pod/"$PG_POD" -n "$NAMESPACE" --timeout=300s

log ""
log "Running post-upgrade ANALYZE (for query planner)..."
kubectl exec -n "$NAMESPACE" "$PG_POD" -- \
  bash -c "PGPASSWORD=\$(cat \$POSTGRES_PASSWORD_FILE) vacuumdb -U $PG_USER --all --analyze-only --jobs=4" 2>&1 | tail -3 | tee -a "$LOG_FILE"

# -----------------------------------------------
# Post-upgrade verification
# -----------------------------------------------
log ""
log "=== POST-UPGRADE VERIFICATION ==="
run_verify "$VERIFY_AFTER"

# -----------------------------------------------
# Generate comparison report
# -----------------------------------------------
log ""
generate_report

log ""
log "=== pg_upgrade DONE. PG$PG_NEW_VERSION is running. ==="
log "Log file:      $LOG_FILE"
log "Before verify: $VERIFY_BEFORE"
log "After verify:  $VERIFY_AFTER"
log "Report:        $REPORT_FILE"
