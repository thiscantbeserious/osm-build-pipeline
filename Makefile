IMAGE_NAME = youcantbeserious/osm-build-pipeline
TAG        = latest
PLATFORMS  = linux/amd64,linux/arm64

.PHONY: prepare build push run stop

prepare:
	docker run --rm --privileged tonistiigi/binfmt --install all

build:
	@echo "🛠 Attempting multi-arch build with buildx..."
	@if docker buildx version >/dev/null 2>&1; then \
	  docker buildx build --platform $(PLATFORMS) \
	    -t $(IMAGE_NAME):$(TAG) --push . || \
	  (echo "⚠️ Multi-arch build failed, falling back to single-arch build..."; \
	   docker build -t $(IMAGE_NAME):$(TAG) .); \
	else \
	  echo "⚠️ buildx not installed, performing local docker build..."; \
	  docker build -t $(IMAGE_NAME):$(TAG) .; \
	fi

push:
	docker push $(IMAGE_NAME):$(TAG)

run:
	docker run --rm -v $(PWD)/data:/data $(IMAGE_NAME):$(TAG)

stop:
	docker ps -q --filter "ancestor=$(IMAGE_NAME):$(TAG)" | xargs -r docker stop
