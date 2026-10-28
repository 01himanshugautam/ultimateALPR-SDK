#!/usr/bin/env bash
set -euo pipefail

ORG="${ORG:-himanshu-parksmart}"
VERSION="${VERSION:-$(date +%Y%m%d)}"
IMAGE="ghcr.io/${ORG}/parksmart-anpr:jetson-nano-jp441-v${VERSION}"
LATEST_IMAGE="ghcr.io/${ORG}/parksmart-anpr:jetson-nano-jp441-latest"

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

echo "Building and pushing ${IMAGE}"

docker buildx build \
  --platform linux/arm64 \
  --file deploy/jetson-nano/Dockerfile \
  --push \
  --tag "${IMAGE}" \
  --tag "${LATEST_IMAGE}" \
  .

echo "Published ${IMAGE}"
echo "Published ${LATEST_IMAGE}"
