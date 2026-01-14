import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Optional

from abstractions import Task, TaskRepository

class TaskDatabase(TaskRepository):
    """SQLite implementation of TaskRepository for task management."""

    def __init__(self, db_path: str = "tasks.db") -> None:
        self.db_path = db_path
        Path(self.db_path).parent.mkdir(parents=True, exist_ok=True)
        self._con = sqlite3.connect(self.db_path, check_same_thread=False)
        self._con.row_factory = sqlite3.Row
        self._init_table()

    def close(self) -> None:
        """Close database connection."""
        try:
            self._con.close()
        finally:
            self._con = None
    
    def _init_table(self) -> None:
        """Initialize tasks table."""
        self._con.execute(
            """
            CREATE TABLE IF NOT EXISTS tasks (
                task_id     INTEGER PRIMARY KEY AUTOINCREMENT,
                title       TEXT    NOT NULL,
                description TEXT,
                status      TEXT    NOT NULL DEFAULT 'Pending',
                created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """
        )
        self._con.commit()

    def _row_to_task(self, row: sqlite3.Row) -> Task:
        """Convert database row to Task object."""
        return Task(
            id=row["task_id"],
            title=row["title"],
            description=row["description"],
            status=row["status"],
            created_at=datetime.fromisoformat(row["created_at"]) if row["created_at"] else None,
        )

    def create(self, title: str, description: str = "") -> Task:
        if not title.strip():
            raise ValueError("Title cannot be empty")
        
        row = self._con.execute(
            """
            INSERT INTO tasks(title, description, status) 
            VALUES (?,?,?)
            RETURNING task_id, title, description, status, created_at
            """,
            (title, description, "Pending"),
        ).fetchone()
        
        self._con.commit()
        return self._row_to_task(row)

    def get(self, task_id: int) -> Optional[Task]:
        """Retrieve a single task by ID."""
        row = self._con.execute(
            "SELECT task_id, title, description, status, created_at FROM tasks WHERE task_id = ?",
            (task_id,)
        ).fetchone()
        return self._row_to_task(row) if row else None
    
    def get_all(self) -> list[Task]:
        """Retrieve all tasks from the database."""
        rows = self._con.execute(
            "SELECT task_id, title, description, status, created_at FROM tasks ORDER BY task_id ASC"
        ).fetchall()
        return [self._row_to_task(row) for row in rows]

    def delete(self, task_id: int) -> bool:
        """
        Delete a task by ID.
        
        Args:
            task_id: id of task to delete.

        Returns:
            bool: whether delete was successful.
        """
        cur = self._con.execute("DELETE FROM tasks WHERE task_id = ?", (task_id,))
        self._con.commit()
        return cur.rowcount > 0