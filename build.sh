#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# Builds and pushes both platforms by default. Optionally pass rpi or nano.
exec deploy/build-controller-images.sh "${1:-all}"
