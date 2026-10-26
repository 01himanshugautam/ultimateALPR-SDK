#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
jetson_bin="${repo_root}/binaries/jetson/aarch64"

if ! grep -q '^# R32 ' /etc/nv_tegra_release 2>/dev/null; then
  echo "This setup supports JetPack 4.x (L4T R32) only." >&2
  exit 1
fi

cd "${jetson_bin}"
ln -sfn libultimatePluginTensorRT.so.4.4.1 libultimatePluginTensorRT.so
chmod +x trt_optimizer
./trt_optimizer --assets "${repo_root}/assets"
