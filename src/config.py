import os
from configparser import ConfigParser
from functools import lru_cache
from typing import Any

import typer
from pydantic import BaseSettings


class AppConfig(BaseSettings):
    app_name: str
    environment: str = "dev"

    gcp_project: str
    gcs_bucket: str
    bq_dataset: str

    data_dir: str

    class Config:
        env_file = ".env"


@lru_cache()
def get_config(
        ini_path: str = "configs/main.ini",
        environment: str = os.environ.get("ENVIRONMENT", "dev"),
        **kwargs: Any,
) -> AppConfig:
    # read configs
    parser = ConfigParser()
    parser.read(ini_path)
    # environment config
    config = dict(parser[environment].items())
    config.update(kwargs)
    app_config = AppConfig(**config)
    return app_config


config = get_config()


def main(key: str) -> None:
    """
    Print config value of specified key.
    """
    typer.echo(config.dict().get(key))


if __name__ == "__main__":
    typer.run(main)
