extends Node
class_name WorkerManager

## Manages all workers in the game
## Handles hiring, assignment, and AI coordination

signal worker_hired(worker: Worker)
signal worker_fired(worker_id: int)
signal task_assigned(worker: Worker, task: Dictionary)

var workers: Array[Worker] = []
var worker_catalog: WorkerCatalog
var available_workers: Array[Worker] = []
var busy_workers: Array[Worker] = []

# Configuration
@export var max_workers: int = 50
@export var worker_spawn_point: Node3D

var _worker_id_counter: int = 0

func _ready() -> void:
    worker_catalog = WorkerCatalog.new()

func _process(_delta: float) -> void:
    _update_worker_assignments()

func hire_worker(definition_id: String) -> Worker:
    if workers.size() >= max_workers:
        push_warning("Max workers reached")
        return null
    
    var definition = worker_catalog.get_worker(definition_id)
    if not definition:
        push_warning("Worker definition not found: %s" % definition_id)
        return null
    
    # Create worker instance
    var worker_scene = load("res://scripts/gameplay/worker.gd")
    var worker = worker_scene.new() as Worker
    
    _worker_id_counter += 1
    worker.worker_id = "worker_%d" % _worker_id_counter
    worker.definition = definition
    
    # Position at spawn point
    if worker_spawn_point:
        worker.global_position = worker_spawn_point.global_position
    else:
        worker.global_position = Vector3(0, 2, 0)
    
    add_child(worker)
    workers.append(worker)
    available_workers.append(worker)
    
    # Connect signals
    worker.task_completed.connect(_on_worker_task_completed)
    worker.state_changed.connect(_on_worker_state_changed)
    
    worker_hired.emit(worker)
    print("Hired worker: %s (%s)" % [worker.worker_id, definition.name])
    
    return worker

func fire_worker(worker: Worker) -> bool:
    if not worker in workers:
        return false
    
    worker.cancel_task()
    workers.erase(worker)
    available_workers.erase(worker)
    busy_workers.erase(worker)
    
    worker.queue_free()
    worker_fired.emit(workers.find(worker))
    
    return true

func get_available_worker() -> Worker:
    if available_workers.is_empty():
        return null
    return available_workers.front()

func get_all_workers() -> Array[Worker]:
    return workers

func get_workers_by_type(type: String) -> Array[Worker]:
    var result = []
    for worker in workers:
        if worker.definition and worker.definition.worker_type == type:
            result.append(worker)
    return result

func assign_task_to_worker(task: Dictionary) -> bool:
    var worker = get_available_worker()
    if not worker:
        return false
    
    worker.assign_task(task)
    available_workers.erase(worker)
    busy_workers.append(worker)
    
    task_assigned.emit(worker, task)
    return true

func assign_task_to_specific_worker(worker: Worker, task: Dictionary) -> bool:
    if not worker or not worker.is_available():
        return false
    
    worker.assign_task(task)
    available_workers.erase(worker)
    busy_workers.append(worker)
    
    task_assigned.emit(worker, task)
    return true

func _update_worker_assignments() -> void:
    # Move workers back to available if they're idle
    for worker in busy_workers:
        if worker.state == Worker.WorkerState.IDLE or worker.state == Worker.WorkerState.RESTING:
            busy_workers.erase(worker)
            if worker not in available_workers:
                available_workers.append(worker)

func _on_worker_task_completed(worker: Worker) -> void:
    # Worker completed a task, make available for new tasks
    busy_workers.erase(worker)
    if worker not in available_workers:
        available_workers.append(worker)

func _on_worker_state_changed(worker: Worker, new_state: String) -> void:
    if new_state == "idle":
        if worker in busy_workers:
            busy_workers.erase(worker)
        if worker not in available_workers:
            available_workers.append(worker)
    elif new_state in ["working", "moving_to_task", "carrying"]:
        if worker in available_workers:
            available_workers.erase(worker)
        if worker not in busy_workers:
            busy_workers.append(worker)

func get_total_efficiency() -> float:
    var total = 0.0
    for worker in workers:
        if worker.definition:
            total += worker.definition.base_efficiency
    return total

func get_active_worker_count() -> int:
    return busy_workers.size()

func get_idle_worker_count() -> int:
    return available_workers.size()

func get_total_worker_count() -> int:
    return workers.size()

func calculate_total_wages(minutes: int) -> int:
    var total = 0
    for worker in workers:
        if worker.definition:
            total += worker.definition.get_total_wage(minutes)
    return total

func save_state() -> Array:
    var data = []
    for worker in workers:
        data.append({
            "worker_id": worker.worker_id,
            "definition_id": worker.definition.id if worker.definition else "",
            "current_depth": worker.current_depth,
            "stamina": worker.stamina,
            "state": worker.get_current_state()
        })
    return data

func load_state(data: Array) -> void:
    for entry in data:
        var def_id = entry.get("definition_id", "basic_miner")
        var worker = hire_worker(def_id)
        if worker:
            worker.worker_id = entry.get("worker_id", worker.worker_id)
            worker.current_depth = entry.get("current_depth", 0)
            worker.stamina = entry.get("stamina", 100.0)
