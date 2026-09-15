extends Node
class_name TaskManager

var _tasks: Array = []

func add_task(task: Dictionary) -> void:
    _tasks.append(task)

func get_next_task() -> Dictionary:
    if _tasks.size() > 0:
        return _tasks[0]
    return {}

func complete_task(task_id: String) -> void:
    for i in range(_tasks.size()):
        if _tasks[i].get("id") == task_id:
            _tasks.remove_at(i)
            break
