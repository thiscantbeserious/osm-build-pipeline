# OSM Build Pipeline

A minimal, two-stage Docker pipeline for:

1. Downloading `.osm.pbf` files from Geofabrik using Alpine
2. Generating `.mbtiles` tiles using [Planetiler](https://github.com/onthegomap/planetiler)

## ✅ Features

- Only re-downloads if `.osm.pbf` file is older than a configurable threshold
- Multi-stage Dockerfile keeps final image clean
- Easy to deploy on Unraid, CI, or manually

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

## 🧰 run.sh

Use the Shellscript to simplify builds and runs:

| Command        | Description                         |
|----------------|-------------------------------------|
| `make build`   | Build the Docker image              |
| `make run`     | Run the image with local volume     |
| `make push`    | Push the image to Docker Hub        |

## 📦 Docker Hub

Image will be published as:

```
youcantbeserious/osm-build-pipeline
```

MIT Licensed. Fork and use freely.
