#!/usr/bin/env python3
import contextlib
import json
import pathlib
import shlex
import sqlite3
import subprocess
import typing


def _get_internet_archive_data(_url):
    _cmd = [
        *shlex.split("curl --silent --get --data"),
        f"url={_url}",
        "https://archive.org/wayback/available",
    ]
    _subprocess = subprocess.run(
        _cmd,
        capture_output=True,
    )
    if _subprocess.stderr or _subprocess.returncode != 0:
        print({"err": _subprocess.stderr, "returncode": _subprocess.returncode})
    try:
        _stdout = _subprocess.stdout.decode("utf8")
        return json.loads(_stdout)
    except:
        return ""


def main():
    with sqlite3_autocommit_connection(pathlib.Path("pocket.db")) as con:
        con.execute("PRAGMA journal_mode=WAL")
        con.execute("PRAGMA synchronous=NORMAL")
        _read_cursor = con.cursor()
        _write_cursor = con.cursor()
        _read_cursor.execute(
            "CREATE TABLE IF NOT EXISTS items_internet_archive(item_id, data)"
        )
        for _item in _read_cursor.execute(
            "SELECT item_id, given_url FROM items WHERE item_id NOT IN (SELECT item_id FROM items_internet_archive)"
        ):
            _item_id, _given_url = _item
            _data = _get_internet_archive_data(_given_url)
            print({"_item_id": _item_id, "_given_url": _given_url, "_data": _data})
            _write_cursor.execute(
                "INSERT INTO items_internet_archive(item_id, data) VALUES (?, ?)",
                [_item_id, json.dumps(_data, ensure_ascii=False)],
            )


@contextlib.contextmanager
def sqlite3_autocommit_connection(
    database,
) -> typing.ContextManager[sqlite3.Connection]:
    """
    open sqlite3 connection in autocommit mode, with explicit sqlite3 transaction handling

    @see https://docs.python.org/3/library/sqlite3.html#transaction-control

    > The sqlite3 module does not adhere to the transaction handling recommended by PEP 249.
    >
    > If isolation_level is set to None, no transactions are implicitly opened at all.
    > This leaves the underlying SQLite library in autocommit mode,
    > but also allows the user to perform their own transaction handling using explicit SQL statements.
    """
    _connection = sqlite3.connect(database, isolation_level=None)
    with contextlib.closing(_connection):
        yield _connection


@contextlib.contextmanager
def sqlite3_transaction(
    _connection: sqlite3.Connection,
) -> typing.ContextManager[sqlite3.Connection]:
    """
    begin a transaction
    """
    _connection.execute("BEGIN")
    try:
        yield _connection
    except:
        _connection.rollback()
        raise
    else:
        _connection.commit()


if __name__ == "__main__":
    main()
