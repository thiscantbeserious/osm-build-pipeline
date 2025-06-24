#!/bin/bash
set -euo pipefail

if [[ -f /sys/fs/cgroup/memory.max ]]; then
  limit_bytes=$(cat /sys/fs/cgroup/memory.max)
elif [[ -f /sys/fs/cgroup/memory/memory.limit_in_bytes ]]; then
  limit_bytes=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
else
  echo "⚠️ Unable to detect memory limit. Defaulting to -Xmx2g" >&2
  echo "-Xmx2g"
  exit 0
fi

if [[ "$limit_bytes" == "max" ]] || [[ "$limit_bytes" -ge 9223372036854771712 ]]; then
  echo "⚠️ No memory limit set (or max). Defaulting to -Xmx2g" >&2
  echo "-Xmx2g"
  exit 0
fi

heap_gb=$((limit_bytes / 1024 / 1024 / 1024))
heap_gb=$((heap_gb * 80 / 100))
if (( heap_gb < 2 )); then
  heap_gb=2
fi

echo "-Xmx${heap_gb}g"
