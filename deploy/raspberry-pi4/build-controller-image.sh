#!/usr/bin/env bash
set -euo pipefail

ORG="${ORG:-parksmart-tech}"
VERSION="${VERSION:-$(date +%Y%m%d)}"
IMAGE="ghcr.io/${ORG}/parksmart-anpr:rpi-v${VERSION}"
LATEST_IMAGE="ghcr.io/${ORG}/parksmart-anpr:rpi-latest"

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

echo "Building and pushing ${IMAGE}"

docker buildx build \
  --platform linux/arm/v7 \
  --file deploy/raspberry-pi4/Dockerfile \
  --push \
  --tag "${IMAGE}" \
  --tag "${LATEST_IMAGE}" \
  .

echo "Published ${IMAGE}"
echo "Published ${LATEST_IMAGE}"
