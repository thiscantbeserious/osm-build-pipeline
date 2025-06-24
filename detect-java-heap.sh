#!/bin/bash
set -euo pipefail

# Get total memory (kB) from /proc/meminfo
mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')

# Convert memory to GB
mem_gb=$((mem_kb / 1024 / 1024))

# Allocate 80% of total memory to heap
heap_gb=$((mem_gb * 80 / 100))

# Enforce minimum of 2 GB heap
if (( heap_gb < 2 )); then
  heap_gb=2
fi

# Echo allocated heap size to stderr (so it always appears in logs)
echo "✅ Allocating Java heap memory: ${heap_gb} GB" >&2

# Output JVM flag for heap size
echo "-Xmx${heap_gb}g"
