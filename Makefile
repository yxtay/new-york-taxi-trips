.PHONY: pip-compile
pip-compile:
	pip-compile --output-file requirements.txt requirements.in
	pip-compile --output-file=requirements-dev.txt requirements-dev.in

.PHONY: pip-sync
pip-sync:
	pip-sync

.PHONY: dbt-run
dbt-run:
	dbt run
