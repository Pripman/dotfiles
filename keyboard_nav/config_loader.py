"""
config_loader.py

Reads and validates ~/.config/keyboard_nav/config.json.

Expected format:
{
  "mappings": [
    { "shortcut": "command+1", "bundleId": "com.mitchellh.ghostty" },
    { "shortcut": "command+2", "bundleId": "com.apple.Safari" }
  ]
}
"""

import json
import os
from dataclasses import dataclass
from typing import List

CONFIG_PATH = os.path.expanduser("~/.config/keyboard_nav/config.json")


@dataclass
class Mapping:
    shortcut: str
    bundle_id: str
    url: str | None = None


class ConfigError(Exception):
    pass


def load_config() -> List[Mapping]:
    """Load and validate the config file. Returns a list of Mapping objects."""
    if not os.path.exists(CONFIG_PATH):
        raise ConfigError(
            f"Config file not found at {CONFIG_PATH}\n"
            f"Create it or copy config.example.json to get started."
        )

    with open(CONFIG_PATH, "r") as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            raise ConfigError(f"Invalid JSON in config file: {e}")

    if not isinstance(data, dict):
        raise ConfigError("Config must be a JSON object at the top level.")

    raw_mappings = data.get("mappings")
    if raw_mappings is None:
        raise ConfigError('Config must have a "mappings" key.')
    if not isinstance(raw_mappings, list):
        raise ConfigError('"mappings" must be a JSON array.')

    mappings: List[Mapping] = []
    for i, entry in enumerate(raw_mappings):
        if not isinstance(entry, dict):
            raise ConfigError(f'mappings[{i}] must be a JSON object.')

        shortcut = entry.get("shortcut")
        bundle_id = entry.get("bundleId")

        if not shortcut or not isinstance(shortcut, str):
            raise ConfigError(
                f'mappings[{i}] is missing a valid "shortcut" string.'
            )
        if not bundle_id or not isinstance(bundle_id, str):
            raise ConfigError(
                f'mappings[{i}] is missing a valid "bundleId" string.'
            )

        url = entry.get("url")
        if url is not None and not isinstance(url, str):
            raise ConfigError(
                f'mappings[{i}] "url" must be a string.'
            )

        mappings.append(Mapping(shortcut=shortcut.lower(), bundle_id=bundle_id, url=url))

    if not mappings:
        raise ConfigError('"mappings" array is empty — nothing to register.')

    return mappings


def ensure_config_dir() -> None:
    """Create the config directory if it doesn't exist."""
