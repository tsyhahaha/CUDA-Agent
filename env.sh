#!/usr/bin/env bash

export CUDA_AGENT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CUDA_AGENT_WORKDIR="$CUDA_AGENT_ROOT/agent_workdir"
export PYTHONPATH="$CUDA_AGENT_WORKDIR:${PYTHONPATH:-}"

export CUDA_HOME="${CUDA_HOME:-/usr/local/cuda}"
export TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-9.0}"

_torch_lib_dirs="$(python3 - <<'PY'
from pathlib import Path
import torch

site_packages = Path(torch.__file__).resolve().parents[1]
paths = [Path(torch.__file__).resolve().parent / "lib"]
paths.extend(sorted(site_packages.glob("nvidia/*/lib")))
print(":".join(str(path) for path in paths if path.is_dir()))
PY
)"

if [ -n "$_torch_lib_dirs" ]; then
    export LD_LIBRARY_PATH="$_torch_lib_dirs:${LD_LIBRARY_PATH:-}"
fi

if [ -d "$CUDA_HOME/lib64" ]; then
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:$CUDA_HOME/lib64"
fi

unset _torch_lib_dirs
