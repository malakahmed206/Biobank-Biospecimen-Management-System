"""
db.py -- thin database access layer.

By default the app runs against a local SQLite file (schema_sqlite.sql),
so it works immediately with zero setup for the demo/defense.

To point it at the real PostgreSQL database from the main project instead,
set the DATABASE_URL environment variable, e.g.:

    export DATABASE_URL="postgresql://user:password@localhost:5432/biobank_db"

When DATABASE_URL is set, psycopg2 is used and the production schema
(/sql/create_tables.sql, load_data.sql, views.sql, triggers_procedures.sql
from the repository root) is expected to already be loaded into that
database -- this app does not re-create the PostgreSQL schema for you.
"""

import os
import sqlite3

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SQLITE_PATH = os.path.join(BASE_DIR, "biobank.db")
SQLITE_SCHEMA = os.path.join(BASE_DIR, "schema_sqlite.sql")
SQLITE_SEED = os.path.join(BASE_DIR, "seed_sqlite.sql")

DATABASE_URL = os.environ.get("DATABASE_URL", "").strip()
USE_POSTGRES = bool(DATABASE_URL)

if USE_POSTGRES:
    import psycopg2
    import psycopg2.extras

    def get_conn():
        conn = psycopg2.connect(DATABASE_URL, cursor_factory=psycopg2.extras.RealDictCursor)
        return conn

    PLACEHOLDER = "%s"
else:
    def _init_sqlite_if_needed():
        first_time = not os.path.exists(SQLITE_PATH)
        conn = sqlite3.connect(SQLITE_PATH)
        conn.execute("PRAGMA foreign_keys = ON")
        if first_time:
            with open(SQLITE_SCHEMA) as f:
                conn.executescript(f.read())
            if os.path.exists(SQLITE_SEED):
                with open(SQLITE_SEED) as f:
                    conn.executescript(f.read())
            conn.commit()
        conn.close()

    def get_conn():
        _init_sqlite_if_needed()
        conn = sqlite3.connect(SQLITE_PATH)
        conn.execute("PRAGMA foreign_keys = ON")
        conn.row_factory = sqlite3.Row
        return conn

    PLACEHOLDER = "?"


def q(sql):
    """Rewrite a query written with '?' placeholders for the active backend."""
    return sql.replace("?", PLACEHOLDER) if USE_POSTGRES else sql


def fetchall(sql, params=()):
    conn = get_conn()
    try:
        cur = conn.cursor()
        cur.execute(q(sql), params)
        rows = cur.fetchall()
        return [dict(r) for r in rows]
    finally:
        conn.close()


def fetchone(sql, params=()):
    rows = fetchall(sql, params)
    return rows[0] if rows else None


def execute(sql, params=(), return_id=False):
    """Run an INSERT/UPDATE/DELETE. Returns the new row id when return_id=True."""
    conn = get_conn()
    try:
        cur = conn.cursor()
        cur.execute(q(sql), params)
        new_id = None
        if return_id:
            if USE_POSTGRES:
                # caller's SQL must include "RETURNING id_column" for this path
                row = cur.fetchone()
                new_id = row[list(row.keys())[0]] if row else None
            else:
                new_id = cur.lastrowid
        conn.commit()
        return new_id
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()
