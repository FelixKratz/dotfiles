from datetime import datetime
from dooit.api import manager
import os

def colored(text, color):
    return f"[{color}]{text}[/{color}]"

def tag(icon, text, color):
    return colored(f" {icon} ", "r " + color) + colored(f" {text} ", color)

def get_time() -> str:
    return f"{datetime.now().time().strftime('%H:%M')}"


def get_username():
    return os.getlogin()

def get_all_todos():
    def fill(model):
        for workspace in model.workspaces:
            fill(workspace)

        for todo in model.todos:
            todos.append(todo)

    todos = []
    fill(manager)
    return todos


def get_total_completed():
    todos = get_all_todos()
    return sum(1 for t in todos if t.status == "COMPLETED")


def get_total_completed_today():
    todos = get_all_todos()
    return sum(
        1
        for t in todos
        if t.status == "COMPLETED" and (t.due != "none" and t._due._value.date() == datetime.now().date())
    )


def get_total_overdue():
    todos = get_all_todos()
    return sum(1 for t in todos if t.status == "OVERDUE")


def get_total_pending():
    todos = get_all_todos()
    pending = 0
    for t in todos:
        if t.status == "PENDING":
            pending += 1

    return pending


def get_pending_today():
    todos = get_all_todos()
    pending = 0
    for t in todos:
        if t.status == "PENDING":
            pending += t.due != "none" and t._due._value.date() == datetime.now().date()

    return pending
