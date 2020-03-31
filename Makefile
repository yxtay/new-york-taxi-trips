IMAGE_REGISTRY:=docker.io/yxtay
APP_NAME=$(shell python -m src.config APP_NAME)

ME:=Makefile
DOCKER_FILE:=Dockerfile

GCP_PROJECT=$(shell python -m src.config GCP_PROJECT)
GCS_BUCKET=$(shell python -m src.config GCS_BUCKET)

DATA_DIR=$(shell python -m src.config DATA_DIR)


.PHONY: dbt-run
dbt-run:
	dbt run

.PHONY: bq-extract-raw
bq-extract-raw:
	bq \
	  --headless true \
	  --project_id $(GCP_PROJECT) \
	  extract \
	  --destination_format CSV \
	  --compression GZIP \
	  bigquery-public-data:new_york_taxi_trips.tlc_yellow_trips_2015 \
	  gs://$(GCS_BUCKET)/$(APP_NAME)/$(DATA_DIR)/tlc_yellow_trips_2015/tlc_yellow_trips_2015_*.csv.gz

.PHONY: dl-data
dl-data:
	mkdir -p $(DATA_DIR)
	gsutil -m rsync -r gs://$(GCS_BUCKET)/$(APP_NAME)/$(DATA_DIR) $(DATA_DIR)

.PHONY: update-requirements
update-requirements:
	pip install --upgrade pip setuptools pip-tools
	pip-compile --upgrade --build-isolation --output-file requirements/main.txt requirements/main.in
	pip-compile --upgrade --build-isolation --output-file requirements/dev.txt requirements/dev.in

.PHONY: install-requirements
install-requirements:
	pip install -r requirements/main.txt -r requirements/dev.txt

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
