FROM eclipse-temurin:21-jre

ARG PLANETILER_VERSION=0.9.1

ENV OSM_FILE=europe-latest
ENV OSM_URL=
ENV OSM_FILENAME=
ENV MBTILES_FILENAME=
ENV JAVA_OPTS=

WORKDIR /app

# Install system dependencies and osmium
RUN apt-get update && apt-get install -y \
    curl \
    file \
    gnupg \
    software-properties-common \
    osmium-tool \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Download Planetiler JAR in a separate step to improve caching
RUN curl -fL --retry 3 \
      -o /app/planetiler.jar \
      https://github.com/onthegomap/planetiler/releases/download/v${PLANETILER_VERSION}/planetiler.jar

# Print osmium version
RUN osmium --version

# Copy scripts into container
COPY scripts/ /app/scripts/
RUN chmod +x /app/scripts/*.sh

# Runtime working dir (host-mounted)
WORKDIR /data

ENTRYPOINT ["/app/scripts/download_and_build.sh"]
