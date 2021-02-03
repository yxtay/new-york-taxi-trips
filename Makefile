MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

ENVIRONMENT ?= dev
ARGS =
GOOGLE_APPLICATION_CREDENTIALS ?=
APP_NAME = $(shell python -m src.config app_name)

GCP_PROJECT = $(shell python -m src.config gcp_project)
GCS_BUCKET = $(shell python -m src.config gcs_bucket)
BQ_DATASET = $(shell python -m src.config bq_dataset)

DATA_DIR = $(shell python -m src.config data_dir)

DBT_ARGS = --target $(ENVIRONMENT) --project-dir dbt --profiles-dir .


.PHONY: help
help:  ## print help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

## dependencies

.PHONY: deps-install
deps-install:  ## install dependencies
	pip install poetry
	poetry install --no-root

.PHONY: deps-install-ci
deps-install-ci:
	pip install poetry
	poetry config virtualenvs.create false
	poetry install --no-root
	poetry show

.PHONY: deps-update
deps-update:
	poetry update
	poetry export --format requirements.txt --output requirements.txt --without-hashes

requirements.txt: poetry.lock
	poetry export --format requirements.txt --output requirements.txt --without-hashes

requirements-dev.txt: poetry.lock
	poetry export --dev --format requirements.txt --output requirements-dev.txt --without-hashes

## app

.PHONY: dbt-run
dbt-run:  ## run dbt
	dbt run $(DBT_ARGS)

.PHONY: dbt-docs-generate
dbt-docs-generate:  ## generate dbt docs
	dbt docs generate $(DBT_ARGS)

.PHONY: dbt-docs-serve
dbt-docs-serve:  ## serve dbt docs
	dbt docs serve $(DBT_ARGS)

.PHONY: bq-extract-raw
bq-extract-raw:  ## extract bq table to gcs
	bq \
	  --headless \
	  --project_id $(GCP_PROJECT) \
	  extract \
	  --destination_format CSV \
	  --compression GZIP \
	  bigquery-public-data:new_york_taxi_trips.tlc_yellow_trips_2015 \
	  gs://$(GCS_BUCKET)/$(APP_NAME)/$(DATA_DIR)/tlc_yellow_trips_2015/tlc_yellow_trips_2015_*.csv.gz

.PHONY: dl-data
dl-data:  ## download data from gcs
	mkdir -p $(DATA_DIR)
	gsutil -m rsync -r gs://$(GCS_BUCKET)/$(APP_NAME)/$(DATA_DIR) $(DATA_DIR)
