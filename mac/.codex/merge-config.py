#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "tomlkit>=0.13.2",
# ]
# ///

from __future__ import annotations

import argparse
import copy
import logging
import os
import shutil
import tempfile
from pathlib import Path
from typing import Any

import tomlkit
from tomlkit.items import Table
from tomlkit.toml_document import TOMLDocument


LOGGER = logging.getLogger("codex_config_merge")


def env_flag(name: str) -> bool:
    return os.environ.get(name, "0") == "1"


def default_path(env_name: str, fallback: Path) -> Path:
    return Path(os.environ.get(env_name, str(fallback))).expanduser()


def display_path(path: Path) -> str:
    try:
        return f"~/{path.resolve().relative_to(Path.home()).as_posix()}"
    except ValueError:
        return str(path)


def parse_args() -> argparse.Namespace:
    script_path = Path(__file__).expanduser().resolve()
    parser = argparse.ArgumentParser(
        description="Merge tracked Codex base config with machine-local config."
    )
    parser.add_argument(
        "--base",
        type=Path,
        default=default_path("CODEX_BASE_CONFIG", script_path.parent / "config.base.toml"),
        help="Base config path.",
    )
    parser.add_argument(
        "--local",
        type=Path,
        default=default_path("CODEX_LOCAL_CONFIG", Path.home() / ".codex/config.local.toml"),
        help="Local config path.",
    )
    parser.add_argument(
        "--target",
        type=Path,
        default=default_path("CODEX_TARGET_CONFIG", Path.home() / ".codex/config.toml"),
        help="Generated config path.",
    )
    parser.add_argument(
        "--log-file",
        type=Path,
        default=default_path(
            "CODEX_CONFIG_MERGE_LOG_FILE",
            Path.home() / ".codex/config-merge.log",
        ),
        help="Log file path.",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        default=env_flag("CODEX_CONFIG_MERGE_VERBOSE"),
        help="Also write info logs to stderr.",
    )
    parser.add_argument(
        "--debug",
        action="store_true",
        default=env_flag("CODEX_CONFIG_MERGE_DEBUG"),
        help="Write detailed merge logs to the log file.",
    )
    parser.add_argument(
        "--script-path",
        type=Path,
        default=script_path,
        help=argparse.SUPPRESS,
    )
    return parser.parse_args()


def configure_logging(log_file: Path, *, verbose: bool, debug: bool) -> None:
    LOGGER.setLevel(logging.DEBUG if debug else logging.INFO)
    LOGGER.handlers.clear()

    log_file.parent.mkdir(parents=True, exist_ok=True)

    file_handler = logging.FileHandler(log_file, encoding="utf-8")
    file_handler.setLevel(logging.DEBUG if debug else logging.INFO)
    file_handler.setFormatter(
        logging.Formatter("%(asctime)s %(levelname)s %(name)s: %(message)s")
    )
    LOGGER.addHandler(file_handler)

    if verbose:
        stream_handler = logging.StreamHandler()
        stream_handler.setLevel(logging.INFO)
        stream_handler.setFormatter(logging.Formatter("%(levelname)s: %(message)s"))
        LOGGER.addHandler(stream_handler)


def read_toml(path: Path, *, required: bool) -> TOMLDocument:
    path = path.expanduser()
    if not path.exists():
        if required:
            LOGGER.error("Required TOML file is missing: %s", display_path(path))
            raise FileNotFoundError(path)

        LOGGER.debug(
            "Local TOML file is missing; generating config from base only: %s",
            display_path(path),
        )
        return tomlkit.document()

    LOGGER.debug("Reading TOML file: %s", display_path(path))
    try:
        return tomlkit.parse(path.read_text(encoding="utf-8"))
    except Exception:
        LOGGER.exception("Failed to parse TOML file: %s", display_path(path))
        raise


def is_mergeable_table(value: Any) -> bool:
    return isinstance(value, (TOMLDocument, Table))


def merge_toml(
    base: TOMLDocument | Table,
    local: TOMLDocument | Table,
    prefix: str = "",
    source_label: str = "local config",
) -> None:
    for key, local_value in local.items():
        key_path = f"{prefix}.{key}" if prefix else str(key)

        if (
            key in base
            and is_mergeable_table(base[key])
            and is_mergeable_table(local_value)
        ):
            LOGGER.debug("Merging TOML table: %s", key_path)
            merge_toml(base[key], local_value, key_path, source_label)
            continue

        if key in base:
            LOGGER.debug("Overriding TOML key from %s: %s", source_label, key_path)
        else:
            LOGGER.debug("Adding TOML key from %s: %s", source_label, key_path)

        base[key] = copy.deepcopy(local_value)


def extract_target_only_toml(
    base: TOMLDocument | Table,
    target: TOMLDocument | Table,
    *,
    root: bool = True,
) -> TOMLDocument | Table:
    additions = tomlkit.document() if root else tomlkit.table()

    for key, target_value in target.items():
        if key not in base:
            additions[key] = copy.deepcopy(target_value)
            continue

        if is_mergeable_table(base[key]) and is_mergeable_table(target_value):
            nested_additions = extract_target_only_toml(
                base[key],
                target_value,
                root=False,
            )
            if len(nested_additions) > 0:
                additions[key] = nested_additions

    return additions


def count_toml_items(document: TOMLDocument | Table) -> int:
    count = 0
    for _, value in document.items():
        count += 1
        if is_mergeable_table(value):
            count += count_toml_items(value)
    return count


def build_header(script_path: Path, base_config: Path, local_config: Path) -> str:
    return (
        "# Generated by Codex config merge.\n"
        f"# Script: {display_path(script_path)}\n"
        f"# Base: {display_path(base_config)}\n"
        f"# Local: {display_path(local_config)}\n"
        "# Do not edit this file directly; edit the base or local config instead.\n\n"
    )


def write_atomic(path: Path, rendered: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    mode = path.stat().st_mode & 0o777 if path.exists() else 0o600

    fd, temp_name = tempfile.mkstemp(
        prefix=f".{path.name}.",
        suffix=".tmp",
        dir=path.parent,
        text=True,
    )
    temp_path = Path(temp_name)

    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(rendered)
            handle.flush()
            os.fsync(handle.fileno())

        os.chmod(temp_path, mode)
        os.replace(temp_path, path)
        LOGGER.debug("Wrote TOML file: %s", display_path(path))
    except Exception:
        LOGGER.exception("Failed while writing TOML file: %s", display_path(path))
        try:
            temp_path.unlink(missing_ok=True)
        finally:
            raise


def absorb_target_only_local_config(
    base_document: TOMLDocument,
    local_document: TOMLDocument,
    *,
    target_config: Path,
    local_config: Path,
) -> int:
    if not target_config.exists():
        LOGGER.debug(
            "Target config does not exist; no target-only settings to absorb: %s",
            display_path(target_config),
        )
        return 0

    target_document = read_toml(target_config, required=False)
    target_only_document = extract_target_only_toml(base_document, target_document)
    target_only_count = count_toml_items(target_only_document)
    if target_only_count == 0:
        LOGGER.debug("No target-only Codex settings found to absorb")
        return 0

    before = tomlkit.dumps(local_document)
    merge_toml(
        local_document,
        target_only_document,
        source_label="current target config",
    )
    rendered = tomlkit.dumps(local_document)
    tomlkit.parse(rendered)

    if rendered == before:
        LOGGER.debug("Target-only Codex settings are already present in local config")
        return 0

    write_atomic(local_config, rendered)
    LOGGER.debug(
        "Absorbed %d target-only TOML item(s) into local config: %s",
        target_only_count,
        display_path(local_config),
    )
    return target_only_count


def backup_existing_target(target_config: Path, rendered: str) -> Path | None:
    if not target_config.exists():
        LOGGER.debug("Target config does not exist yet: %s", display_path(target_config))
        return None

    current = target_config.read_text(encoding="utf-8")
    if current == rendered:
        LOGGER.debug(
            "Target config already matches merged output: %s",
            display_path(target_config),
        )
        return None

    backup_path = target_config.with_name(f"{target_config.name}.backup")
    shutil.copy2(target_config, backup_path)
    LOGGER.debug("Updated rolling backup before replacement: %s", display_path(backup_path))
    return backup_path


def merge_config(args: argparse.Namespace) -> int:
    base_config = args.base.expanduser()
    local_config = args.local.expanduser()
    target_config = args.target.expanduser()
    script_path = args.script_path.expanduser()

    LOGGER.debug("Starting Codex config merge")
    LOGGER.debug("Base config path: %s", base_config)
    LOGGER.debug("Local config path: %s", local_config)
    LOGGER.debug("Target config path: %s", target_config)

    base_document = read_toml(base_config, required=True)
    local_document = read_toml(local_config, required=False)
    absorbed_count = absorb_target_only_local_config(
        base_document,
        local_document,
        target_config=target_config,
        local_config=local_config,
    )

    LOGGER.debug(
        "Merging Codex config with %d base top-level key(s) and %d local top-level key(s)",
        len(base_document),
        len(local_document),
    )
    merge_toml(base_document, local_document)

    rendered = build_header(script_path, base_config, local_config) + tomlkit.dumps(
        base_document
    )
    tomlkit.parse(rendered)

    if target_config.exists() and target_config.read_text(encoding="utf-8") == rendered:
        LOGGER.info(
            "Codex config unchanged: base=%s local=%s target=%s absorbed=%d",
            display_path(base_config),
            display_path(local_config),
            display_path(target_config),
            absorbed_count,
        )
        return 0

    backup_path = backup_existing_target(target_config, rendered)
    write_atomic(target_config, rendered)
    if backup_path is None:
        LOGGER.info(
            "Codex config written: base=%s local=%s target=%s absorbed=%d",
            display_path(base_config),
            display_path(local_config),
            display_path(target_config),
            absorbed_count,
        )
    else:
        LOGGER.info(
            "Codex config written: base=%s local=%s target=%s backup=%s absorbed=%d",
            display_path(base_config),
            display_path(local_config),
            display_path(target_config),
            display_path(backup_path),
            absorbed_count,
        )
    return 0


def main() -> int:
    args = parse_args()
    configure_logging(args.log_file.expanduser(), verbose=args.verbose, debug=args.debug)
    try:
        return merge_config(args)
    except Exception:
        LOGGER.exception("Codex config merge failed")
        raise


if __name__ == "__main__":
    raise SystemExit(main())
