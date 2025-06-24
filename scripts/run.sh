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

validate_pbf() {
  echo "🔍 Validating downloaded PBF file..."

  # Step 1: MIME type check (must be binary)
  local mime_type
  mime_type=$(file -b --mime-type "$OSM_PATH")
  if [[ "$mime_type" != "application/octet-stream" ]]; then
    echo "❌ Invalid MIME type: $mime_type — this is likely not a real PBF file"
    return 1
  fi

  # Step 2: Referential integrity check using osmium
  echo "🔍 Running 'osmium check-refs'..."
  if ! osmium check-refs "$OSM_PATH"; then
    echo "❌ Referential integrity check failed — file might be corrupt or incomplete"
    return 1
  fi

  echo "✅ PBF file passed all validation checks"
  return 0
}

download_pbf() {
  echo "📥 Downloading PBF..."
  curl -fL --retry 10 --retry-delay 60 \
      --connect-timeout 30 \
      -o "$OSM_PATH" "$OSM_URL"
  if ! validate_pbf; then
    echo "❌ File invalid after download. Aborting."
    exit 1
  fi
}

if [ -f "$OSM_PATH" ]; then
  if ! validate_pbf; then
    echo "❌ Corrupt file detected. Re-downloading..."
    rm -f "$OSM_PATH"
    download_pbf
  elif find "$OSM_PATH" -mtime +"$PBF_EXPIRY_DAYS" -print -quit | grep -q .; then
    echo "🔁 File is valid but old. Re-downloading..."
    download_pbf
  else
    echo "✅ File is fresh and valid. Skipping download."
  fi
else
  echo "📥 No existing file. Downloading..."
  download_pbf
fi

echo "🧱 Running Planetiler..."
exec java ${JAVA_OPTS:-$(detect-java-heap.sh)} -jar /app/planetiler.jar \
  --download \
  --osm_path="$OSM_PATH" \
  --output="$MBTILES_PATH"
