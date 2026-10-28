#!/usr/bin/env bash
set -euo pipefail

# Override these values in /etc/default/ultimatealpr-storage-cleanup.
IMAGE_DIR="${IMAGE_DIR:-/home/parksmart/anpr/images}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
PRESSURE_RETENTION_DAYS="${PRESSURE_RETENTION_DAYS:-1}"
MIN_FREE_MB="${MIN_FREE_MB:-1024}"
JOURNAL_MAX_AGE="${JOURNAL_MAX_AGE:-7d}"
JOURNAL_MAX_SIZE="${JOURNAL_MAX_SIZE:-100M}"
DOCKER_PRUNE_AGE="${DOCKER_PRUNE_AGE:-168h}"
DRY_RUN="${DRY_RUN:-false}"

log() {
  printf '%s ultimateALPR cleanup: %s\n' "$(date --iso-8601=seconds)" "$*"
}

for value in RETENTION_DAYS PRESSURE_RETENTION_DAYS MIN_FREE_MB; do
  if [[ ! "${!value}" =~ ^[0-9]+$ ]]; then
    log "${value} must be a non-negative integer"
    exit 64
  fi
done

if [[ "${IMAGE_DIR}" != /home/parksmart/anpr/images || -L "${IMAGE_DIR}" ]]; then
  log "refusing unsafe IMAGE_DIR: ${IMAGE_DIR}"
  exit 64
fi

exec 9>/run/lock/ultimatealpr-storage-cleanup.lock
if ! flock -n 9; then
  log "another cleanup is already running"
  exit 0
fi

free_mb() {
  df -Pm / | awk 'NR == 2 { print $4 }'
}

delete_old_images() {
  local days="$1"
  [[ -d "${IMAGE_DIR}" ]] || return 0
  if [[ "${DRY_RUN}" == "true" ]]; then
    find "${IMAGE_DIR}" -xdev -type f -mtime "+${days}" -print
  else
    find "${IMAGE_DIR}" -xdev -type f -mtime "+${days}" -print -delete
    find "${IMAGE_DIR}" -xdev -depth -mindepth 1 -type d -empty -delete
  fi
}

log "starting; free=$(free_mb)MB threshold=${MIN_FREE_MB}MB dry_run=${DRY_RUN}"
delete_old_images "${RETENTION_DAYS}"

if [[ "${DRY_RUN}" == "true" ]]; then
  log "would vacuum journal to age=${JOURNAL_MAX_AGE}, size=${JOURNAL_MAX_SIZE}"
else
  journalctl --vacuum-time="${JOURNAL_MAX_AGE}" --vacuum-size="${JOURNAL_MAX_SIZE}"
fi

if (( $(free_mb) < MIN_FREE_MB )); then
  log "storage pressure detected; applying safe cache and Docker cleanup"
  if [[ "${DRY_RUN}" == "true" ]]; then
    docker system df || true
    log "would clean apt cache and prune stopped containers, unused images, and old build cache"
  else
    apt-get clean
    docker container prune -f --filter "until=${DOCKER_PRUNE_AGE}" || true
    # -a still preserves every image referenced by a container. The age filter
    # keeps recent rollback images while removing stale tagged releases.
    docker image prune -a -f --filter "until=${DOCKER_PRUNE_AGE}" || true
    docker builder prune -f --filter "until=${DOCKER_PRUNE_AGE}" || true
  fi
fi

if (( $(free_mb) < MIN_FREE_MB )); then
  log "free space remains below threshold; applying pressure retention"
  delete_old_images "${PRESSURE_RETENTION_DAYS}"
fi

log "finished; free=$(free_mb)MB"
