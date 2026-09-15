extends Node

enum WorkerState { IDLE, MOVING, WORKING, TRANSPORTING, REPAIRING }
enum WorkerType { MINER, SKILLED_MINER, ENGINEER, SUPERVISOR }

signal worker_hired(worker_id: String)
signal worker_assigned(worker_id: String, task: String)
signal worker_state_changed(worker_id: String, old_state: WorkerState, new_state: WorkerState)

const WORKER_TYPES = {
WorkerType.MINER: {"name": "Miner", "efficiency": 1.0, "wage": 10.0, "skills": ["mining"]},
WorkerType.SKILLED_MINER: {"name": "Skilled Miner", "efficiency": 1.5, "wage": 20.0, "skills": ["mining", "operating"]},
WorkerType.ENGINEER: {"name": "Engineer", "efficiency": 1.2, "wage": 30.0, "skills": ["repair", "operating"]},
WorkerType.SUPERVISOR: {"name": "Supervisor", "efficiency": 1.0, "wage": 40.0, "skills": ["supervise"]}
}

var workers: Dictionary = {}
var worker_counter: int = 0

func _ready() -> void:
workers = {}

func hire_worker(type: WorkerType) -> String:
var worker_id = "worker_%d" % worker_counter
worker_counter += 1

var type_data = WORKER_TYPES[type]
workers[worker_id] = {
"id": worker_id,
"type": type,
"name": type_data["name"],
"state": WorkerState.IDLE,
"current_task": null,
"efficiency": type_data["efficiency"],
"wage": type_data["wage"],
"skills": type_data["skills"],
"position": Vector3.ZERO
}

worker_hired.emit(worker_id)
return worker_id

func assign_task(worker_id: String, task: String) -> bool:
if not workers.has(worker_id):
return false

var worker = workers[worker_id]
var old_state = worker["state"]

worker["current_task"] = task
worker["state"] = WorkerState.WORKING if task else WorkerState.IDLE

worker_assigned.emit(worker_id, task)
worker_state_changed.emit(worker_id, old_state, worker["state"])
return true

func get_worker(worker_id: String) -> Dictionary:
return workers.get(worker_id, {})

func get_all_workers() -> Array:
return workers.values()

func get_idle_workers() -> Array:
var idle = []
for worker in workers.values():
if worker["state"] == WorkerState.IDLE:
idle.append(worker)
return idle

func fire_worker(worker_id: String) -> bool:
if not workers.has(worker_id):
return false
workers.erase(worker_id)
return true

func calculate_total_wages() -> float:
var total = 0.0
for worker in workers.values():
total += worker["wage"]
return total

func get_worker_count() -> int:
return workers.size()

func get_worker_count_by_type(type: WorkerType) -> int:
var count = 0
for worker in workers.values():
if worker["type"] == type:
count += 1
return count
