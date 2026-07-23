#!/usr/bin/env bash
set -euo pipefail

# PostgreSQL Parallel Backup & Restore & Verify
# Uses pg_dump/pg_restore directory format with --jobs for parallel I/O per database.
#
# Usage:
#   ./pg-backup-restore.sh <namespace> backup
#   ./pg-backup-restore.sh <namespace> restore [backup-dir]
#   ./pg-backup-restore.sh <namespace> verify

if [[ -z "${1:-}" || -z "${2:-}" ]]; then
  echo "Usage: $0 <namespace> <backup|restore|verify> [backup-dir]"
  echo ""
  echo "Examples:"
  echo "  $0 harness backup"
  echo "  $0 harness restore"
  echo "  $0 harness restore pg_backup_20260628-120000"
  echo "  $0 harness verify"
  exit 1
fi

NAMESPACE="$1"
ACTION="$2"
RESTORE_DIR="${3:-}"

if [[ "$ACTION" != "backup" && "$ACTION" != "restore" && "$ACTION" != "verify" ]]; then
  echo "ERROR: Action must be 'backup', 'restore', or 'verify'. Got: $ACTION"
  exit 1
fi

# --- Configuration (override via env vars) ---
PG_STS_NAME="${PG_STS_NAME:-postgres}"
PG_POD="${PG_STS_NAME}-0"
PG_USER="${PG_USER:-postgres}"
PG_SERVICE="${PG_SERVICE:-postgres}"
PG_PORT="${PG_PORT:-5432}"
PG_DUMP_JOBS="${PG_DUMP_JOBS:-4}"
PG_COMPRESSION="${PG_COMPRESSION:-lz4}"

BACKUP_PVC_NAME="${BACKUP_PVC_NAME:-pg-backup-data}"
BACKUP_PVC_STORAGE_CLASS="${BACKUP_PVC_STORAGE_CLASS:-}"
BACKUP_MOUNT="/backup"
BACKUP_POD_NAME="pg-backup-job"

PG_PASSWORD_SECRET="${PG_PASSWORD_SECRET:-postgres}"
PG_PASSWORD_SECRET_KEY="${PG_PASSWORD_SECRET_KEY:-postgres-password}"

# Read image, pull secret, and service account from the postgres StatefulSet.
# Reuse postgres's SA so the pod inherits its SCC (OpenShift).
BACKUP_IMAGE="${BACKUP_IMAGE:-$(kubectl get sts -n "$NAMESPACE" "$PG_STS_NAME" -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)}"
IMAGE_PULL_SECRET=$(kubectl get sts -n "$NAMESPACE" "$PG_STS_NAME" -o jsonpath='{.spec.template.spec.imagePullSecrets[0].name}' 2>/dev/null || true)
PG_SERVICE_ACCOUNT="${PG_SERVICE_ACCOUNT:-$(kubectl get sts -n "$NAMESPACE" "$PG_STS_NAME" -o jsonpath='{.spec.template.spec.serviceAccountName}' 2>/dev/null || true)}"

# Size backup PVC to match postgres data PVC
if [[ -z "${BACKUP_PVC_SIZE:-}" ]]; then
  BACKUP_PVC_SIZE=$(kubectl get pvc -n "$NAMESPACE" "data-${PG_POD}" -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null || true)
  BACKUP_PVC_SIZE="${BACKUP_PVC_SIZE:-50Gi}"
fi

# Resolve backup PVC storage class if not explicitly set.
# Reuse the class of the postgres data PVC so the backup volume lands on the same sc
if [[ -z "${BACKUP_PVC_STORAGE_CLASS:-}" ]]; then
  BACKUP_PVC_STORAGE_CLASS=$(kubectl get pvc -n "$NAMESPACE" "data-${PG_POD}" -o jsonpath='{.spec.storageClassName}' 2>/dev/null || true)
fi

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="/tmp/pg-${ACTION}-${NAMESPACE}-${TIMESTAMP}.log"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

fail() { log "ERROR: $*"; exit 1; }
trap 'fail "Unexpected error on line $LINENO"' ERR

prompt() {
  echo ""
  echo "  $1"
  read -rp "  Type 'yes' to continue: " answer
  [[ "$answer" == "yes" ]] || { log "Aborted."; exit 1; }
}

pod_exec() { kubectl exec -n "$NAMESPACE" "$BACKUP_POD_NAME" -- bash -c "$1"; }

# --- Create backup PVC if needed ---
ensure_pvc() {
  kubectl get pvc -n "$NAMESPACE" "$BACKUP_PVC_NAME" &>/dev/null && return

  log "Creating PVC $BACKUP_PVC_NAME ($BACKUP_PVC_SIZE, storageClass: ${BACKUP_PVC_STORAGE_CLASS:-<cluster default>})..."
  local sc=""
  [[ -n "$BACKUP_PVC_STORAGE_CLASS" ]] && sc="  storageClassName: $BACKUP_PVC_STORAGE_CLASS"

  cat <<EOF | kubectl apply -n "$NAMESPACE" -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $BACKUP_PVC_NAME
spec:
${sc}
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: $BACKUP_PVC_SIZE
EOF
}

# --- Launch backup pod ---
launch_pod() {
  kubectl get pod -n "$NAMESPACE" "$BACKUP_POD_NAME" &>/dev/null && {
    kubectl wait --for=condition=Ready pod/"$BACKUP_POD_NAME" -n "$NAMESPACE" --timeout=120s
    return
  }

  local pull_secret=""
  [[ -n "$IMAGE_PULL_SECRET" ]] && pull_secret="  imagePullSecrets:
  - name: $IMAGE_PULL_SECRET"

  local sa_line=""
  [[ -n "$PG_SERVICE_ACCOUNT" ]] && sa_line="  serviceAccountName: $PG_SERVICE_ACCOUNT"

  log "Launching pod ($BACKUP_IMAGE, serviceAccount: ${PG_SERVICE_ACCOUNT:-<default>})..."
  cat <<EOF | kubectl apply -n "$NAMESPACE" -f -
apiVersion: v1
kind: Pod
metadata:
  name: $BACKUP_POD_NAME
spec:
  restartPolicy: Never
${sa_line}
${pull_secret}
  securityContext:
    runAsUser: 1001
    fsGroup: 1001
  containers:
  - name: backup
    image: $BACKUP_IMAGE
    command: ["sleep", "infinity"]
    env:
    - name: PGPASSWORD
      valueFrom:
        secretKeyRef:
          name: $PG_PASSWORD_SECRET
          key: $PG_PASSWORD_SECRET_KEY
    volumeMounts:
    - name: data
      mountPath: $BACKUP_MOUNT
    resources:
      requests: {cpu: "2", memory: "4Gi"}
      limits:   {cpu: "4", memory: "8Gi"}
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: $BACKUP_PVC_NAME
EOF
  kubectl wait --for=condition=Ready pod/"$BACKUP_POD_NAME" -n "$NAMESPACE" --timeout=300s
  log "  Pod ready."
}

# --- Get database list from running postgres ---
get_db_list() {
  kubectl exec -n "$NAMESPACE" "$PG_POD" -- bash -c \
    "PGPASSWORD=\$(cat \$POSTGRES_PASSWORD_FILE 2>/dev/null || echo \$POSTGRES_PASSWORD) \
     psql -U $PG_USER -t -A -c \"SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname;\""
}

# --- Compression flag ---
compress_flag() {
  case "$PG_COMPRESSION" in
    lz4)  echo "--compress=lz4" ;;
    zstd) echo "--compress=zstd" ;;
    gzip) echo "--compress=gzip" ;;
    none) echo "" ;;
    *)    echo "--compress=lz4" ;;
  esac
}

# --- Capture per-table report to local file ---
capture_report() {
  local output_file="$1"
  log "  Capturing report to: $output_file"

  {
    echo "=== PG DATA REPORT $(date -u '+%Y-%m-%dT%H:%M:%SZ') ==="
    echo "Namespace: $NAMESPACE"
    echo ""

    local dbs
    dbs=$(pod_exec "psql --host=$PG_SERVICE --port=$PG_PORT --username=$PG_USER -d postgres -t -A -c \
      \"SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname;\"")

    echo "=== DATABASE SIZES ==="
    for db in $dbs; do
      local size
      size=$(pod_exec "psql --host=$PG_SERVICE --port=$PG_PORT --username=$PG_USER -d postgres -t -A -c \
        \"SELECT pg_size_pretty(pg_database_size('$db'));\"")
      echo "${db}=${size}"
    done
    echo ""

    for db in $dbs; do
      echo "=== DATABASE: $db ==="
      pod_exec "psql --host=$PG_SERVICE --port=$PG_PORT --username=$PG_USER -d '$db' -t -A -c \
        \"SELECT '${db}:' || schemaname || '.' || relname || '|' || n_live_tup
         FROM pg_stat_user_tables
         ORDER BY schemaname, relname;\""
      echo ""
    done

    echo "=== DONE ==="
  } > "$output_file"

  log "  Report saved: $output_file"
}

# =============================================
# BACKUP
# =============================================
do_backup() {
  local backup_dir="pg_backup_${TIMESTAMP}"
  local backup_path="${BACKUP_MOUNT}/${backup_dir}"

  log "=== BACKUP ==="
  log "Namespace: $NAMESPACE | PVC: $BACKUP_PVC_NAME | Jobs: $PG_DUMP_JOBS | Compression: $PG_COMPRESSION"

  kubectl wait --for=condition=Ready pod/"$PG_POD" -n "$NAMESPACE" --timeout=60s

  local db_list
  db_list=$(get_db_list)
  local db_count
  db_count=$(echo "$db_list" | wc -l | tr -d ' ')
  log "Databases ($db_count): $(echo $db_list | tr '\n' ' ')"

  ensure_pvc
  launch_pod
  pod_exec "mkdir -p $backup_path"

  # Checkpoint + ANALYZE for consistent dump and accurate stats
  log "Running CHECKPOINT + ANALYZE..."
  pod_exec "psql --host=$PG_SERVICE --port=$PG_PORT --username=$PG_USER -d postgres -c 'CHECKPOINT;'"
  pod_exec "vacuumdb --host=$PG_SERVICE --port=$PG_PORT --username=$PG_USER --all --analyze-only --jobs=4" 2>&1 | tail -1

  # Capture report BEFORE backup (reflects exact state at dump time)
  local report_file="./pg-backup-report-${NAMESPACE}-${TIMESTAMP}.txt"
  capture_report "$report_file"

  # Dump globals
  log "Dumping globals..."
  pod_exec "pg_dumpall --host=$PG_SERVICE --port=$PG_PORT --username=$PG_USER --globals-only > ${backup_path}/globals.sql"

  # Dump each database (--jobs parallelizes tables within each DB)
  local cflag
  cflag=$(compress_flag)
  local failed=0

  for db in $db_list; do
    log "  Dumping $db..."
    if pod_exec "pg_dump --host=$PG_SERVICE --port=$PG_PORT --username=$PG_USER \
        --format=directory --jobs=$PG_DUMP_JOBS $cflag \
        --dbname='$db' --file='${backup_path}/${db}' 2>${backup_path}/${db}.log"; then
      local size
      size=$(pod_exec "du -sh '${backup_path}/${db}' | cut -f1")
      log "  Done: $db ($size)"
    else
      log "  FAILED: $db (see ${db}.log)"
      failed=$((failed + 1))
    fi
  done

  # Verify
  log ""
  if [[ $failed -gt 0 ]]; then
    fail "$failed database(s) failed to dump."
  fi

  pod_exec "echo 'completed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)' > ${backup_path}/BACKUP_COMPLETE"
  local total_size
  total_size=$(pod_exec "du -sh $backup_path | cut -f1")

  log "=== BACKUP COMPLETE === ($total_size on PVC: $BACKUP_PVC_NAME/$backup_dir)"
  log "Report: $report_file"

  kubectl delete pod -n "$NAMESPACE" "$BACKUP_POD_NAME" --wait=false
}

# =============================================
# RESTORE
# =============================================
do_restore() {
  log "=== RESTORE ==="
  log "Namespace: $NAMESPACE | Jobs: $PG_DUMP_JOBS"

  ensure_pvc
  launch_pod

  # Find backup to restore
  local target_dir
  if [[ -n "$RESTORE_DIR" ]]; then
    target_dir="$RESTORE_DIR"
  else
    target_dir=$(pod_exec "ls -dt $BACKUP_MOUNT/pg_backup_* 2>/dev/null | head -1 | xargs basename")
    [[ -z "$target_dir" ]] && fail "No backups found on PVC."
    log "Using latest: $target_dir"
  fi

  local target_path="${BACKUP_MOUNT}/${target_dir}"
  pod_exec "test -d $target_path" || fail "Backup '$target_dir' not found."
  pod_exec "test -f ${target_path}/BACKUP_COMPLETE" || log "WARNING: BACKUP_COMPLETE marker missing — backup may be incomplete."

  # List databases in backup
  local db_list
  db_list=$(pod_exec "ls -d ${target_path}/*/ 2>/dev/null | xargs -I{} basename {}")
  local db_count
  db_count=$(echo "$db_list" | wc -l | tr -d ' ')
  log "Databases to restore ($db_count): $(echo $db_list | tr '\n' ' ')"

  kubectl wait --for=condition=Ready pod/"$PG_POD" -n "$NAMESPACE" --timeout=60s

  prompt "DESTRUCTIVE: Drop and restore $db_count databases?"

  # Restore globals
  log "Restoring globals..."
  pod_exec "test -f ${target_path}/globals.sql && psql --host=$PG_SERVICE --port=$PG_PORT --username=$PG_USER -d postgres -f ${target_path}/globals.sql 2>&1 | grep -c '' | xargs -I{} echo '  {} lines processed' || echo '  No globals.sql'"

  # Restore each database
  local failed=0

  for db in $db_list; do
    log "  Restoring $db..."

    # Create database if it doesn't exist (no drop — avoids collation/connection issues)
    pod_exec "psql --host=$PG_SERVICE --port=$PG_PORT --username=$PG_USER -d postgres \
      -c \"SELECT 1 FROM pg_database WHERE datname='$db';\" | grep -q 1" 2>/dev/null || {
      local create_out
      if ! create_out=$(pod_exec "psql --host=$PG_SERVICE --port=$PG_PORT --username=$PG_USER -d postgres \
        -c 'CREATE DATABASE \"$db\";' 2>&1"); then
        log "  FAILED to create $db: $create_out"
        failed=$((failed + 1))
        continue
      fi
      log "    created: $db"
    }

    # Restore with --clean --if-exists (drops/recreates objects inside the DB)
    local restore_out rc
    restore_out=$(pod_exec "pg_restore --host=$PG_SERVICE --port=$PG_PORT --username=$PG_USER \
        --dbname='$db' --jobs=$PG_DUMP_JOBS --no-owner --no-acl --clean --if-exists \
        '${target_path}/${db}' 2>&1; echo \"EXIT_CODE:\$?\"")
    rc=$(echo "$restore_out" | grep -o 'EXIT_CODE:[0-9]*' | cut -d: -f2)
    rc="${rc:-1}"

    if [[ "$rc" -eq 0 ]]; then
      log "  Done: $db"
    elif [[ "$rc" -eq 1 ]]; then
      local warn_count
      warn_count=$(echo "$restore_out" | grep -c "WARNING\|ERROR" || true)
      log "  Done: $db ($warn_count warnings)"
    else
      log "  FAILED: $db (exit=$rc)"
      echo "$restore_out" | tail -20 | tee -a "$LOG_FILE"
      failed=$((failed + 1))
    fi
  done

  if [[ $failed -gt 0 ]]; then
    fail "$failed database(s) failed to restore."
  fi

  # ANALYZE
  log "Running ANALYZE..."
  kubectl exec -n "$NAMESPACE" "$PG_POD" -- bash -c \
    "PGPASSWORD=\$(cat \$POSTGRES_PASSWORD_FILE 2>/dev/null || echo \$POSTGRES_PASSWORD) vacuumdb -U $PG_USER --all --analyze-only --jobs=4" \
    2>&1 | tail -3

  local report_file="./pg-restore-report-${NAMESPACE}-${TIMESTAMP}.txt"
  capture_report "$report_file"
  log "=== RESTORE COMPLETE === (from $target_dir)"
  log "Report: $report_file"

  prompt "Delete backup pod? (PVC is retained)"
  kubectl delete pod -n "$NAMESPACE" "$BACKUP_POD_NAME" --wait=false
}

# =============================================
# VERIFY (on-demand — runs directly on postgres pod, no PVC or extra pod)
# =============================================
_pg_exec() {
  kubectl exec -n "$NAMESPACE" "$PG_POD" -- bash -c \
    "PGPASSWORD=\$(cat \$POSTGRES_PASSWORD_FILE 2>/dev/null || echo \$POSTGRES_PASSWORD) $1"
}

do_verify() {
  log "=== VERIFY ==="
  log "Namespace: $NAMESPACE | Pod: $PG_POD"

  kubectl wait --for=condition=Ready pod/"$PG_POD" -n "$NAMESPACE" --timeout=60s

  log "Running ANALYZE for accurate row counts..."
  _pg_exec "vacuumdb -U $PG_USER --all --analyze-only --jobs=4" 2>&1 | tail -3

  local report_file="./pg-verify-${NAMESPACE}-${TIMESTAMP}.txt"
  log "Capturing verification data..."

  {
    echo "=== PG DATA VERIFICATION $(date -u '+%Y-%m-%dT%H:%M:%SZ') ==="
    echo "Namespace: $NAMESPACE | Pod: $PG_POD"
    echo ""

    local dbs
    dbs=$(_pg_exec "psql -U $PG_USER -t -A -c \"SELECT datname FROM pg_database WHERE datistemplate = false AND datname != 'postgres' ORDER BY datname;\"")

    echo "=== DATABASE SIZES ==="
    for db in $dbs; do
      local size
      size=$(_pg_exec "psql -U $PG_USER -d postgres -t -A -c \"SELECT pg_database_size('$db');\"")
      echo "${db}=${size}"
    done
    echo ""

    for db in $dbs; do
      echo "=== DATABASE: $db ==="
      _pg_exec "psql -U $PG_USER -d '$db' -t -A -c \"SELECT '${db}:' || schemaname || '.' || relname || '|' || n_live_tup FROM pg_stat_user_tables ORDER BY schemaname, relname;\""
      echo ""
    done

    echo "=== DONE ==="
  } > "$report_file"

  log "=== VERIFY COMPLETE ==="
  log "Report: $report_file"
  log ""
  log "Compare with a prior report:"
  log "  diff <previous-report>.txt $report_file"
}

# --- Main ---
log "Log: $LOG_FILE"
case "$ACTION" in
  backup)  do_backup ;;
  restore) do_restore ;;
  verify)  do_verify ;;
esac
