extends RefCounted
class_name TaskManager

## Centralized task assignment and management system
## Coordinates tasks between workers, machines, and storage

signal task_created(task_id: String)
signal task_completed(task_id: String)
signal task_failed(task_id: String, reason: String)
signal task_assigned(task_id: String, worker_id: String)

enum TaskType {
MINE_RESOURCE,
TRANSPORT_RESOURCE,
OPERATE_MACHINE,
REPAIR_MACHINE,
PROCESS_RESOURCE,
STORE_RESOURCE,
EXPLORE_DEPTH
}

enum TaskPriority {
LOW = 0,
NORMAL = 1,
HIGH = 2,
CRITICAL = 3
}

enum TaskState {
PENDING,
ASSIGNED,
IN_PROGRESS,
COMPLETED,
FAILED,
CANCELLED
}

var _tasks: Dictionary = {}
var _task_queue: Array[String] = []
var _task_id_counter: int = 0

func _init() -> void:
	pass

func create_task(task_type: TaskType, data: Dictionary, priority: TaskPriority = TaskPriority.NORMAL) -> String:
	_task_id_counter += 1
var task_id = "task_%d" % _task_id_counter

var task = {
"id": task_id,
"type": task_type,
"priority": priority,
"state": TaskState.PENDING,
"data": data,
"assigned_worker": null,
"created_at": Time.get_unix_time_from_system(),
"started_at": 0,
"completed_at": 0,
"progress": 0.0,
"retry_count": 0,
"max_retries": 3
}

_tasks[task_id] = task

# Insert into queue based on priority
_insert_into_queue(task_id, priority)

task_created.emit(task_id)
return task_id

func _insert_into_queue(task_id: String, priority: TaskPriority) -> void:
	# Find insertion point based on priority (higher priority first)
var insert_idx = 0
for i in range(_task_queue.size()):
	var other_id = _task_queue[i]
var other_task = _tasks.get(other_id)
if other_task and other_task["priority"] < priority:
	break
insert_idx = i + 1
_task_queue.insert(insert_idx, task_id)

func get_next_task(exclude_types: Array = []) -> Dictionary:
	for task_id in _task_queue:
	var task = _tasks.get(task_id)
if task and task["state"] == TaskState.PENDING:
	var task_type = task["type"] as TaskType
if TaskType.keys()[task_type] not in exclude_types:
	return task
return {}

func assign_task(task_id: String, worker_id: String) -> bool:
	var task = _tasks.get(task_id)
if not task or task["state"] != TaskState.PENDING:
	return false

task["state"] = TaskState.ASSIGNED
task["assigned_worker"] = worker_id
task["started_at"] = Time.get_unix_time_from_system()

task_assigned.emit(task_id, worker_id)
return true

func start_task(task_id: String) -> bool:
	var task = _tasks.get(task_id)
if not task or task["state"] != TaskState.ASSIGNED:
	return false

task["state"] = TaskState.IN_PROGRESS
return true

func update_task_progress(task_id: String, progress: float) -> void:
	var task = _tasks.get(task_id)
if task:
	task["progress"] = clamp(progress, 0.0, 1.0)
if task["progress"] >= 1.0:
	complete_task(task_id)

func complete_task(task_id: String, result: Dictionary = {}) -> void:
	var task = _tasks.get(task_id)
if not task:
	return

task["state"] = TaskState.COMPLETED
task["completed_at"] = Time.get_unix_time_from_system()
task["result"] = result

task_completed.emit(task_id)
_cleanup_task(task_id)

func fail_task(task_id: String, reason: String) -> void:
	var task = _tasks.get(task_id)
if not task:
	return

task["retry_count"] += 1
if task["retry_count"] >= task["max_retries"]:
	task["state"] = TaskState.FAILED
task["failure_reason"] = reason
task_failed.emit(task_id, reason)
_cleanup_task(task_id)
else:
	# Retry - reset to pending
task["state"] = TaskState.PENDING
task["assigned_worker"] = null

func cancel_task(task_id: String) -> bool:
	var task = _tasks.get(task_id)
if not task or task["state"] in [TaskState.COMPLETED, TaskState.FAILED]:
	return false

task["state"] = TaskState.CANCELLED
_cleanup_task(task_id)
return true

func _cleanup_task(task_id: String) -> void:
	_task_queue.erase(task_id)
# Keep completed/failed tasks in memory for a while for debugging
# In production, might want to archive them

func get_task(task_id: String) -> Dictionary:
	return _tasks.get(task_id, {})

func get_tasks_by_state(state: TaskState) -> Array:
	var result = []
for task in _tasks.values():
	if task["state"] == state:
	result.append(task)
return result

func get_pending_tasks() -> Array:
	return get_tasks_by_state(TaskState.PENDING)

func get_active_tasks() -> Array:
	return get_tasks_by_state(TaskState.IN_PROGRESS)

func get_tasks_for_worker(worker_id: String) -> Array:
	var result = []
for task in _tasks.values():
	if task["assigned_worker"] == worker_id:
	result.append(task)
return result

func cancel_all_tasks_for_worker(worker_id: String) -> void:
	for task in _tasks.values():
	if task["assigned_worker"] == worker_id and task["state"] in [TaskState.PENDING, TaskState.ASSIGNED, TaskState.IN_PROGRESS]:
	task["state"] = TaskState.CANCELLED
task["assigned_worker"] = null
_task_queue.erase(task["id"])

func clear_all_tasks() -> void:
	_tasks.clear()
_task_queue.clear()

func get_queue_size() -> int:
	return _task_queue.size()

func get_stats() -> Dictionary:
	var stats = {
"total": _tasks.size(),
"pending": 0,
"assigned": 0,
"in_progress": 0,
"completed": 0,
"failed": 0,
"cancelled": 0
}

for task in _tasks.values():
	match task["state"]:
	TaskState.PENDING:
	stats["pending"] += 1
TaskState.ASSIGNED:
	stats["assigned"] += 1
TaskState.IN_PROGRESS:
	stats["in_progress"] += 1
TaskState.COMPLETED:
	stats["completed"] += 1
TaskState.FAILED:
	stats["failed"] += 1
TaskState.CANCELLED:
	stats["cancelled"] += 1

return stats

func save_state() -> Array:
	var data = []
for task in _tasks.values():
	if task["state"] not in [TaskState.COMPLETED, TaskState.FAILED, TaskState.CANCELLED]:
	data.append(task.duplicate(true))
return data

func load_state(data: Array) -> void:
	for task_data in data:
	var task_id = task_data.get("id", "")
if task_id:
	_tasks[task_id] = task_data.duplicate(true)
_task_queue.append(task_id)