#!/bin/bash
set -euo pipefail

if [ ! -d /data ] || [ ! -w /data ]; then
  echo "❌ ERROR: /data is not writable or not mounted"
  exit 1
fi

OSM_FILE="${OSM_FILE:-europe-latest}"
OSM_URL="${OSM_URL:-https://download.geofabrik.de/${OSM_FILE}.osm.pbf}"
OSM_FILENAME="${OSM_FILENAME:-${OSM_FILE}.osm.pbf}"
MBTILES_FILENAME="${MBTILES_FILENAME:-${OSM_FILE}.mbtiles}"
PBF_EXPIRY_DAYS="${PBF_EXPIRY_DAYS:-90}"

OSM_PATH="/data/${OSM_FILENAME}"
MBTILES_PATH="/data/${MBTILES_FILENAME}"

echo "📦 OSM Build Pipeline"
echo "  OSM_FILE=$OSM_FILE"
echo "  OSM_URL=$OSM_URL"
echo "  OSM_FILENAME=$OSM_FILENAME"
echo "  MBTILES_FILENAME=$MBTILES_FILENAME"
echo "  PBF_EXPIRY_DAYS=$PBF_EXPIRY_DAYS"

if [ -f "$OSM_PATH" ]; then
    if find "$OSM_PATH" -mtime -"$PBF_EXPIRY_DAYS" -print -quit | grep -q .; then
        echo "✅ PBF file is fresh, skipping download."
    else
        echo "🔁 PBF file is old, re-downloading..."
        curl -L -o "$OSM_PATH" "$OSM_URL"
    fi
else
    echo "📥 Downloading PBF..."
    curl -L -o "$OSM_PATH" "$OSM_URL"
fi

echo "🧱 Running Planetiler..."
exec java ${JAVA_OPTS:-$(detect-java-heap.sh)} -cp /app/planetiler.jar com.onthegomap.planetiler.Planetiler   --osm_path="$OSM_PATH"   --output="$MBTILES_PATH"
