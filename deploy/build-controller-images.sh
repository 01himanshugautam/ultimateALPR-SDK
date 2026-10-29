#!/usr/bin/env bash
set -euo pipefail

target="${1:-all}"

case "${target}" in
  rpi)
    deploy/raspberry-pi4/build-controller-image.sh
    ;;
  nano)
    deploy/jetson-nano/build-controller-image.sh
    ;;
  rockchip|rk3568)
    PUSH=true deploy/rockchip-rk3568/build-controller-image.sh
    ;;
  all)
    deploy/raspberry-pi4/build-controller-image.sh
    deploy/jetson-nano/build-controller-image.sh
    PUSH=true deploy/rockchip-rk3568/build-controller-image.sh
    ;;
  *)
    echo "Usage: $0 [rpi|nano|rockchip|rk3568|all]" >&2
    exit 64
    ;;
esac
