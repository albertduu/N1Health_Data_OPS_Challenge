"""Run a directory of SQLite query files in deterministic filename order."""

from __future__ import annotations

import sqlite3
from collections.abc import Mapping
from pathlib import Path
from typing import Any


class SQLiteQueryRunner:
    """Load, run, and return results from an ordered directory of SQL files."""

    def __init__(self, database_path: Path, query_directory: Path) -> None:
        self.database_path = Path(database_path)
        self.query_directory = Path(query_directory)

        if not self.database_path.is_file():
            raise FileNotFoundError(f"Database not found: {self.database_path}")
        if not self.query_directory.is_dir():
            raise NotADirectoryError(
                f"SQL query directory not found: {self.query_directory}"
            )

    def query_files(self) -> tuple[Path, ...]:
        """Return all SQL files sorted case-insensitively by filename."""
        return tuple(
            sorted(
                self.query_directory.glob("*.sql"),
                key=lambda path: path.name.casefold(),
            )
        )

    @staticmethod
    def _statements(sql: str) -> list[str]:
        """Split a SQL file into complete SQLite statements."""
        statements: list[str] = []
        pending = ""

        for line in sql.splitlines(keepends=True):
            pending += line
            if sqlite3.complete_statement(pending):
                if pending.strip():
                    statements.append(pending.strip())
                pending = ""

        if pending.strip():
            statements.append(pending.strip())
        return statements

    def run_all(
        self,
        parameters: Mapping[str, Any] | None = None,
    ) -> dict[str, list[sqlite3.Row]]:
        """Run every SQL file by filename order and return each result set."""
        results: dict[str, list[sqlite3.Row]] = {}
        bound_parameters = dict(parameters or {})

        with sqlite3.connect(self.database_path) as connection:
            connection.row_factory = sqlite3.Row

            for query_path in self.query_files():
                rows: list[sqlite3.Row] = []
                sql = query_path.read_text(encoding="utf-8")

                for statement in self._statements(sql):
                    cursor = connection.execute(statement, bound_parameters)
                    if cursor.description is not None:
                        rows = cursor.fetchall()

                results[query_path.stem] = rows

        return results
