#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# Builds and pushes all controller platforms by default. A single platform can
# be selected with rpi, nano, or rockchip.
exec deploy/build-controller-images.sh "${1:-all}"
