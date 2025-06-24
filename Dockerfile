FROM eclipse-temurin:21-jre-alpine

ENV OSM_FILE=europe-latest
ENV OSM_URL=
ENV OSM_FILENAME=
ENV MBTILES_FILENAME=
ENV JAVA_OPTS=
ENV PLANETILER_VERSION=0.6.0

WORKDIR /app

RUN apk add --no-cache curl bash coreutils && \
    curl -L -o planetiler.jar https://github.com/onthegomap/planetiler/releases/download/v${PLANETILER_VERSION}/planetiler.jar

WORKDIR /data

COPY download_and_build.sh /usr/local/bin/download_and_build.sh
COPY detect-java-heap.sh /usr/local/bin/detect-java-heap.sh
RUN chmod +x /usr/local/bin/*.sh

ENTRYPOINT ["/usr/local/bin/download_and_build.sh"]
