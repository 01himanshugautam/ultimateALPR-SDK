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
  --rectify "${RECTIFY:-false}"
  --showframe "${SHOW_FRAME:-false}"
  --pipeline "${USE_PIPELINE:-false}"
  --trt_enabled "${TENSORRT_ENABLED:-true}"
  --npu_enabled "${NPU_ENABLED:-false}"
  --openvino_enabled "${OPENVINO_ENABLED:-false}"
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
[[ -n "${TOKEN_FILE:-}" ]] && args+=(--tokenfile "${TOKEN_FILE}")
[[ -n "${TOKEN_DATA:-}" ]] && args+=(--tokendata "${TOKEN_DATA}")
[[ -n "${GPIO_PIN:-}" ]] && args+=(--gpio "${GPIO_PIN}")
[[ -n "${DEFAULT_GPIO_LEVEL:-}" ]] && args+=(--default_gpio_level "${DEFAULT_GPIO_LEVEL}")

exec /opt/ultimatealpr/bin/recognizer "${args[@]}"
