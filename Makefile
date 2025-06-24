IMAGE_NAME=youcantbeserious/osm-build-pipeline
TAG=latest

.PHONY: build push run

build:
	docker build -t $(IMAGE_NAME):$(TAG) .

push:
	docker push $(IMAGE_NAME):$(TAG)

run:
	docker run --rm -v $(PWD)/data:/data $(IMAGE_NAME):$(TAG)
