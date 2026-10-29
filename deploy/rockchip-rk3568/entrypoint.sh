#!/usr/bin/env bash
set -euo pipefail

required=(RTSP_URLS SERVER_URLS PORTS LOG_TYPES DESCRIPTIONS RELAYS)
for name in "${required[@]}"; do
  if [[ -z "${!name:-}" ]]; then
    echo "Missing required environment variable: ${name}" >&2
    exit 64
  fi
done

args=(
  --assets /opt/ultimatealpr/assets
  --charset "${CHARSET:-latin}"
  --parallel "${PARALLEL:-false}"
  --rectify "${RECTIFY:-true}"
  --showframe false
  --pipeline "${USE_PIPELINE:-false}"
  --trt_enabled false
  --npu_enabled false
  --openvino_enabled false
  --rtsp "${RTSP_URLS}"
  --server "${SERVER_URLS}"
  --port "${PORTS}"
  --logtype "${LOG_TYPES}"
  --description "${DESCRIPTIONS}"
  --relay "${RELAYS}"
)

[[ -n "${WINDOW_PREFIX:-}" ]] && args+=(--prefix "${WINDOW_PREFIX}")
[[ -n "${ENCODING:-}" ]] && args+=(--encoding "${ENCODING}")
[[ -n "${MIN_CONFIDENCE:-}" ]] && args+=(--min "${MIN_CONFIDENCE}")
[[ -n "${ROIS:-}" ]] && args+=(--rois "${ROIS}")
[[ -n "${TOKEN_FILE:-}" ]] && args+=(--tokenfile "${TOKEN_FILE}")
[[ -n "${TOKEN_DATA:-}" ]] && args+=(--tokendata "${TOKEN_DATA}")

exec /opt/ultimatealpr/bin/recognizer "${args[@]}"
