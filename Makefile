IMAGE_REGISTRY:=docker.io/yxtay
APP_NAME:=new-york-taxi-trips

ME=Makefile
DOCKER_FILE=Dockerfile

.PHONY: pip-compile
pip-compile:
	pip install --upgrade pip setuptools pip-tools
	pip-compile --upgrade --build-isolation --output-file requirements/main.txt requirements/main.in
	pip-compile --upgrade --build-isolation --output-file requirements/dev.txt requirements/dev.in

.PHONY: pip-sync
pip-sync:
	pip-sync

.PHONY: dbt-run
dbt-run:
	dbt run

.PHONY: docker-build
docker-build:
	docker pull $(IMAGE_REGISTRY)/$(APP_NAME) || exit 0
	docker build \
	  --cache-from $(IMAGE_REGISTRY)/$(APP_NAME) \
	  --tag $(IMAGE_REGISTRY)/$(APP_NAME):latest \
	  --file $(DOCKER_FILE) .

.PHONY: docker-push
docker-push:
	docker push $(IMAGE_REGISTRY)/$(APP_NAME):latest

.PHONY: docker-run
docker-run:
	docker run --rm -it \
	$(IMAGE_REGISTRY)/$(APP_NAME) \
	$(ARGS)

.PHONY: docker-exec
docker-exec:
	docker exec -it \
	$(shell docker ps -q  --filter ancestor=$(IMAGE_REGISTRY)/$(APP_NAME)) \
	/bin/bash

.PHONY: docker-stop
docker-stop:
	docker stop \
	$(shell docker ps -q  --filter ancestor=$(IMAGE_REGISTRY)/$(APP_NAME))
