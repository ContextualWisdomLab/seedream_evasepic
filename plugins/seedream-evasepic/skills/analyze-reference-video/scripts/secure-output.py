#!/usr/bin/env python3
"""Publish a downloaded reference without following caller-controlled links."""

from __future__ import annotations

import errno
import os
import shutil
import stat
import sys
import uuid
CACHE_HIT = 10
DIRECTORY_SYMLINK_MESSAGE = "Output path contains a symbolic-link directory. Aborting."
DESTINATION_CHANGED_MESSAGE = "Output destination changed before publication. Aborting."
OUTPUT_SYMLINK_MESSAGE = "Output path is a symlink. Aborting to prevent arbitrary file overwrite."


class SecureOutputError(RuntimeError):
    """Describe one fail-closed output-path rejection without echoing the path."""


def _open_directory(parent_path: str, *, create: bool) -> int | None:
    """Open every parent component with ``O_NOFOLLOW`` and return the final fd."""
    absolute = os.path.isabs(parent_path)
    components = [part for part in parent_path.split(os.sep) if part not in ("", ".")]
    directory_fd = os.open(os.sep if absolute else ".", os.O_RDONLY | os.O_DIRECTORY)
    try:
        for component in components:
            try:
                next_fd = os.open(
                    component,
                    os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW,
                    dir_fd=directory_fd,
                )
            except FileNotFoundError:
                if not create:
                    os.close(directory_fd)
                    return None
                try:
                    os.mkdir(component, mode=0o755, dir_fd=directory_fd)
                except FileExistsError:
                    pass
                next_fd = os.open(
                    component,
                    os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW,
                    dir_fd=directory_fd,
                )
            except OSError as error:
                if error.errno in (errno.ELOOP, errno.ENOTDIR):
                    raise SecureOutputError(DIRECTORY_SYMLINK_MESSAGE) from None
                raise
            os.close(directory_fd)
            directory_fd = next_fd
        return directory_fd
    except BaseException:
        os.close(directory_fd)
        raise


def _split_output(output_path: str) -> tuple[str, str]:
    """Return the parent path and final file name for one caller output path."""
    parent_path, file_name = os.path.split(output_path)
    if not file_name or file_name in (".", ".."):
        raise SecureOutputError(DESTINATION_CHANGED_MESSAGE)
    return parent_path or ".", file_name


def _lstat_at(directory_fd: int, file_name: str) -> os.stat_result | None:
    """Read final-entry metadata without following a symbolic link."""
    try:
        return os.stat(file_name, dir_fd=directory_fd, follow_symlinks=False)
    except FileNotFoundError:
        return None


def check_output(output_path: str) -> int:
    """Return ``CACHE_HIT`` only for a non-empty regular caller-owned output."""
    parent_path, file_name = _split_output(output_path)
    directory_fd = _open_directory(parent_path, create=False)
    if directory_fd is None:
        return 0
    try:
        metadata = _lstat_at(directory_fd, file_name)
        if metadata is None:
            return 0
        if stat.S_ISLNK(metadata.st_mode):
            raise SecureOutputError(OUTPUT_SYMLINK_MESSAGE)
        if not stat.S_ISREG(metadata.st_mode):
            raise SecureOutputError(DESTINATION_CHANGED_MESSAGE)
        return CACHE_HIT if metadata.st_size > 0 else 0
    finally:
        os.close(directory_fd)


def _same_directory(parent_path: str, expected: os.stat_result) -> bool:
    """Confirm the caller-visible path still names the opened destination directory."""
    current_fd = _open_directory(parent_path, create=False)
    if current_fd is None:
        return False
    try:
        current = os.fstat(current_fd)
        return (current.st_dev, current.st_ino) == (expected.st_dev, expected.st_ino)
    finally:
        os.close(current_fd)


def publish_output(source_path: str, output_path: str) -> None:
    """Copy and atomically link a private download into the verified destination."""
    source_metadata = os.lstat(source_path)
    if not stat.S_ISREG(source_metadata.st_mode):
        raise SecureOutputError(DESTINATION_CHANGED_MESSAGE)

    parent_path, file_name = _split_output(output_path)
    directory_fd = _open_directory(parent_path, create=True)
    if directory_fd is None:
        raise SecureOutputError(DESTINATION_CHANGED_MESSAGE)
    temporary_name = f".seedream-download-{uuid.uuid4().hex}.tmp"
    try:
        existing = _lstat_at(directory_fd, file_name)
        if existing is not None:
            if stat.S_ISLNK(existing.st_mode):
                raise SecureOutputError(DESTINATION_CHANGED_MESSAGE)
            if not stat.S_ISREG(existing.st_mode) or existing.st_size > 0:
                raise SecureOutputError(DESTINATION_CHANGED_MESSAGE)
            os.unlink(file_name, dir_fd=directory_fd)

        temporary_fd = os.open(
            temporary_name,
            os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW,
            0o600,
            dir_fd=directory_fd,
        )
        try:
            with open(source_path, "rb") as source, os.fdopen(temporary_fd, "wb") as target:
                shutil.copyfileobj(source, target)
                target.flush()
                os.fsync(target.fileno())
        except BaseException:
            try:
                os.close(temporary_fd)
            except OSError:
                pass
            raise

        if not _same_directory(parent_path, os.fstat(directory_fd)):
            raise SecureOutputError(DESTINATION_CHANGED_MESSAGE)
        if _lstat_at(directory_fd, file_name) is not None:
            raise SecureOutputError(DESTINATION_CHANGED_MESSAGE)
        try:
            os.link(
                temporary_name,
                file_name,
                src_dir_fd=directory_fd,
                dst_dir_fd=directory_fd,
                follow_symlinks=False,
            )
        except FileExistsError:
            raise SecureOutputError(DESTINATION_CHANGED_MESSAGE) from None
        os.unlink(temporary_name, dir_fd=directory_fd)
        os.fsync(directory_fd)
    finally:
        try:
            os.unlink(temporary_name, dir_fd=directory_fd)
        except FileNotFoundError:
            pass
        os.close(directory_fd)


def main(arguments: list[str]) -> int:
    """Run the cache-check or publication command used by the shell entrypoint."""
    try:
        if len(arguments) == 2 and arguments[0] == "check":
            return check_output(arguments[1])
        if len(arguments) == 3 and arguments[0] == "publish":
            publish_output(arguments[1], arguments[2])
            return 0
        raise SecureOutputError("Invalid secure-output invocation.")
    except (OSError, SecureOutputError) as error:
        print(str(error) if isinstance(error, SecureOutputError) else DESTINATION_CHANGED_MESSAGE, file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
