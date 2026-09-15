extends RefCounted
class_name WorkerCatalog

## Central catalog of all worker definitions

var _workers: Dictionary = {}

func _init() -> void:
	_initialize_default_workers()

func _initialize_default_workers() -> void:
	# Basic Worker - starter worker
var basic = WorkerDefinition.new()
basic.id = "basic_miner"
basic.name = "Miner"
basic.worker_type = "basic"
basic.base_efficiency = 1.0
basic.max_stamina = 100.0
basic.stamina_drain_rate = 0.5
basic.stamina_regen_rate = 0.3
basic.movement_speed = 3.0
basic.carry_capacity = 10
basic.unlock_cost = 50
basic.wage_per_minute = 1
basic.required_unlock_depth = 0
basic.animations = {
"idle": "idle",
"walk": "walk",
"run": "run",
"mine": "mine",
"carry": "carry_idle",
"load": "load",
"repair": "repair"
}
_register_worker(basic)

# Skilled Miner - faster mining
var skilled = WorkerDefinition.new()
skilled.id = "skilled_miner"
skilled.name = "Skilled Miner"
skilled.worker_type = "skilled"
skilled.base_efficiency = 1.5
skilled.max_stamina = 120.0
skilled.stamina_drain_rate = 0.6
skilled.stamina_regen_rate = 0.35
skilled.movement_speed = 3.5
skilled.carry_capacity = 15
skilled.unlock_cost = 200
skilled.wage_per_minute = 3
skilled.required_unlock_depth = 10
skilled.special_abilities = ["mining_speed"]
skilled.animations = basic.animations
_register_worker(skilled)

# Engineer - operates advanced machinery
var engineer = WorkerDefinition.new()
engineer.id = "engineer"
engineer.name = "Engineer"
engineer.worker_type = "engineer"
engineer.base_efficiency = 1.8
engineer.max_stamina = 100.0
engineer.stamina_drain_rate = 0.4
engineer.stamina_regen_rate = 0.4
engineer.movement_speed = 3.2
engineer.carry_capacity = 12
engineer.unlock_cost = 500
engineer.wage_per_minute = 5
engineer.required_unlock_depth = 25
engineer.special_abilities = ["machine_bonus", "repair_bonus"]
engineer.animations = basic.animations
_register_worker(engineer)

# Supervisor - boosts nearby workers
var supervisor = WorkerDefinition.new()
supervisor.id = "supervisor"
supervisor.name = "Supervisor"
supervisor.worker_type = "supervisor"
supervisor.base_efficiency = 1.2
supervisor.max_stamina = 150.0
supervisor.stamina_drain_rate = 0.3
supervisor.stamina_regen_rate = 0.5
supervisor.movement_speed = 4.0
supervisor.carry_capacity = 8
supervisor.unlock_cost = 1000
supervisor.wage_per_minute = 8
supervisor.required_unlock_depth = 40
supervisor.special_abilities = ["team_boost", "morale_bonus"]
supervisor.animations = basic.animations
_register_worker(supervisor)

func _register_worker(worker: WorkerDefinition) -> void:
	_workers[worker.id] = worker

func get_worker(id: String) -> WorkerDefinition:
	return _workers.get(id)

func get_all_workers() -> Array:
	return _workers.values()

func get_workers_by_type(type: String) -> Array:
	var result = []
for worker in _workers.values():
	if worker.worker_type == type:
	result.append(worker)
return result

func get_available_at_depth(depth: int) -> Array:
	var result = []
for worker in _workers.values():
	if worker.can_work_at_depth(depth):
	result.append(worker)
return result

func has_worker(id: String) -> bool:
	return _workers.has(id)

func get_worker_count() -> int:
	return _workers.size()