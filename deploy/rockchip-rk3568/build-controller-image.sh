#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
registry="${REGISTRY:-ghcr.io}"
org="${ORG:-himanshu-parksmart}"
image="${IMAGE:-parksmart-anpr}"
version="${VERSION:-v$(date +%Y%m%d)}"
version_tag="${registry}/${org}/${image}:rockchip-rk3568-${version}"
latest_tag="${registry}/${org}/${image}:rockchip-rk3568-latest"

output=(--load)
if [[ "${PUSH:-false}" == "true" ]]; then
  output=(--push)
fi

docker buildx build \
  --platform linux/arm64 \
  --file "${repo_root}/deploy/rockchip-rk3568/Dockerfile" \
  --tag "${version_tag}" \
  --tag "${latest_tag}" \
  "${output[@]}" \
  "${repo_root}"

printf 'Built %s\nBuilt %s\n' "${version_tag}" "${latest_tag}"
