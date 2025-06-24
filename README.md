# OSM Build Pipeline

A minimal, two-stage Docker pipeline for:

1. Downloading `.osm.pbf` files from Geofabrik using Alpine
2. Generating `.mbtiles` tiles using [Planetiler](https://github.com/onthegomap/planetiler)

## ✅ Features

- Full Download & Build pipeline without manual steps
- Configuratable timeframe which enforces re-download (defaults to > 90 days)
- Only re-downloads if `.osm.pbf` file is older than a configurable threshold
- Verifies validity of PBF, and redownloads if corrupted / incomplete PBF
- Automatically detects Java-Heap-Size for Planetiler

## 🧪 Usage

### Run locally

```bash
docker build -t youcantbeserious/osm-build-pipeline .
docker run --rm -v $(pwd)/data:/data youcantbeserious/osm-build-pipeline
```

## ⚙️ Environment Variables

| Variable           | Description                                | Default                      |
|--------------------|--------------------------------------------|------------------------------|
| `OSM_FILE`         | Region name for Geofabrik (e.g. `europe-latest`) | `europe-latest`        |
| `OSM_URL`          | Full override for download URL             | built from `OSM_FILE`        |
| `OSM_FILENAME`     | Override `.pbf` file name                  | `${OSM_FILE}.osm.pbf`        |
| `MBTILES_FILENAME` | Output tiles filename                      | `${OSM_FILE}.mbtiles`        |
| `PBF_EXPIRY_DAYS`  | Days before `.pbf` is considered stale     | `90`                         |

## 🧰 Makefile Shortcuts

Use the Makefile to simplify builds and runs:

| Command        | Description                         |
|----------------|-------------------------------------|
| `make prepare` | Prepare your env for buildx         |
| `make build`   | Build the Docker image              |
| `make run`     | Run the image with local volume     |
| `make push`    | Push the image to Docker Hub        |

## 📦 Docker Hub

Image will be published as:

```
youcantbeserious/osm-build-pipeline
```

MIT Licensed. Fork and use freely.
