from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import datetime
from typing import Optional

@dataclass(frozen=True)
class Task:
    """Immutable Task data model."""
    id: int
    title: str
    description: Optional[str] = None
    status: str = "Pending"
    created_at: Optional[datetime] = None

    def to_dict(self) -> dict:
        """Convert task to dictionary."""
        return {
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "status": self.status,
            "created_at": self.created_at,
        }

class TaskRepository(ABC):
    """Abstract base class for task data access."""

    @abstractmethod
    def create(self, title: str, description: str = "") -> Task:
        """Create a new task."""
        pass

    @abstractmethod
    def get(self, task_id: int) -> Optional[Task]:
        """Retrieve a single task by ID."""
        pass

    @abstractmethod
    def get_all(self) -> list[Task]:
        """Retrieve all tasks."""
        pass

    @abstractmethod
    def update(
        self,
        task_id: int,
        title: str = None,
        description: str = None,
        status: str = None,
    ) -> bool:
        """Update a task by ID."""
        pass

    @abstractmethod
    def delete(self, task_id: int) -> bool:
        """Delete a task by ID."""
        pass

    @abstractmethod
    def close(self) -> None:
        """Close any resources held by the repository."""
        pass