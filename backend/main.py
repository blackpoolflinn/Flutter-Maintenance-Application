from __future__ import annotations

import sqlite3
from datetime import datetime
from pathlib import Path
from typing import List, Optional

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DB_PATH = Path(__file__).parent / "sync.db"


def _get_connection() -> sqlite3.Connection:
    con = sqlite3.connect(DB_PATH, check_same_thread=False)
    con.row_factory = sqlite3.Row
    return con


def _init_db() -> None:
    con = _get_connection()
    try:
        con.execute(
            """
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY,
                title TEXT NOT NULL,
                description TEXT,
                status TEXT NOT NULL,
                aircraft_id INTEGER,
                created_at TEXT NOT NULL,
                synced_at TEXT NOT NULL
            )
            """
        )
        con.execute(
            """
            CREATE TABLE IF NOT EXISTS aircraft (
                id INTEGER PRIMARY KEY,
                registration_number TEXT NOT NULL,
                model TEXT NOT NULL,
                manufacturer TEXT NOT NULL,
                year_of_manufacture INTEGER NOT NULL,
                status TEXT NOT NULL,
                created_at TEXT NOT NULL,
                synced_at TEXT NOT NULL
            )
            """
        )
        con.commit()
    finally:
        con.close()


class TaskPayload(BaseModel):
    id: Optional[int]
    title: str
    description: Optional[str] = None
    status: str
    aircraftId: Optional[int] = None
    createdAt: str


class AircraftPayload(BaseModel):
    id: Optional[int]
    registrationNumber: str
    model: str
    manufacturer: str
    yearOfManufacture: int
    status: str
    createdAt: str


class SyncRequest(BaseModel):
    tasks: List[TaskPayload] = []
    aircraft: List[AircraftPayload] = []


@app.get("/health")
def health_check() -> dict:
    return {"status": "ok"}


@app.post("/sync")
def sync(payload: SyncRequest) -> dict:
    _init_db()
    con = _get_connection()
    synced_at = datetime.utcnow().isoformat()

    task_ids: list[int] = []
    aircraft_ids: list[int] = []

    try:
        for task in payload.tasks:
            if task.id is None:
                continue
            con.execute(
                """
                INSERT INTO tasks (
                    id, title, description, status, aircraft_id, created_at, synced_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT(id) DO UPDATE SET
                    title = excluded.title,
                    description = excluded.description,
                    status = excluded.status,
                    aircraft_id = excluded.aircraft_id,
                    created_at = excluded.created_at,
                    synced_at = excluded.synced_at
                """,
                (
                    task.id,
                    task.title,
                    task.description,
                    task.status,
                    task.aircraftId,
                    task.createdAt,
                    synced_at,
                ),
            )
            task_ids.append(task.id)

        for aircraft in payload.aircraft:
            if aircraft.id is None:
                continue
            con.execute(
                """
                INSERT INTO aircraft (
                    id, registration_number, model, manufacturer, year_of_manufacture, status, created_at, synced_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT(id) DO UPDATE SET
                    registration_number = excluded.registration_number,
                    model = excluded.model,
                    manufacturer = excluded.manufacturer,
                    year_of_manufacture = excluded.year_of_manufacture,
                    status = excluded.status,
                    created_at = excluded.created_at,
                    synced_at = excluded.synced_at
                """,
                (
                    aircraft.id,
                    aircraft.registrationNumber,
                    aircraft.model,
                    aircraft.manufacturer,
                    aircraft.yearOfManufacture,
                    aircraft.status,
                    aircraft.createdAt,
                    synced_at,
                ),
            )
            aircraft_ids.append(aircraft.id)

        con.commit()
    finally:
        con.close()

    return {
        "taskIds": task_ids,
        "aircraftIds": aircraft_ids,
    }