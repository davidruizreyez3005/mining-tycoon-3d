extends Node

enum MachineType { EXTRACTOR, PROCESSOR, CONVEYOR, STORAGE, ELEVATOR }
enum MachineState { IDLE, OPERATING, MAINTENANCE, OFFLINE }

signal machine_purchased(machine_id: String)
signal machine_state_changed(machine_id: String, state: MachineState)
signal machine_production(machine_id: String, resource_id: String, amount: int)

const MACHINE_TYPES = {
MachineType.EXTRACTOR: {"name": "Extractor", "cost": 100.0, "power": 5.0, "capacity": 10},
MachineType.PROCESSOR: {"name": "Processor", "cost": 250.0, "power": 10.0, "capacity": 20},
MachineType.CONVEYOR: {"name": "Conveyor", "cost": 50.0, "power": 2.0, "capacity": 50},
MachineType.STORAGE: {"name": "Storage", "cost": 150.0, "power": 1.0, "capacity": 100},
MachineType.ELEVATOR: {"name": "Elevator", "cost": 300.0, "power": 15.0, "capacity": 30}
}

var machines: Dictionary = {}
var machine_counter: int = 0

func _ready() -> void:
machines = {}

func purchase_machine(type: MachineType, position: Vector3 = Vector3.ZERO) -> String:
var type_data = MACHINE_TYPES[type]
if not GameManager.can_afford(type_data["cost"]):
return ""

GameManager.spend_money(type_data["cost"])

var machine_id = "machine_%d" % machine_counter
machine_counter += 1

machines[machine_id] = {
"id": machine_id,
"type": type,
"name": type_data["name"],
"state": MachineState.IDLE,
"position": position,
"power_consumption": type_data["power"],
"capacity": type_data["capacity"],
"current_load": 0,
"efficiency": 1.0,
"upgrade_level": 0
}

machine_purchased.emit(machine_id)
return machine_id

func operate_machine(machine_id: String, duration: float) -> bool:
if not machines.has(machine_id):
return false

var machine = machines[machine_id]
if machine["state"] == MachineState.OFFLINE or machine["state"] == MachineState.MAINTENANCE:
return false

var old_state = machine["state"]
machine["state"] = MachineState.OPERATING

var base_output = int(machine["capacity"] * machine["efficiency"])
var output = max(1, base_output)

machine_production.emit(machine_id, "processed_material", output)
machine["current_load"] = min(machine["capacity"], machine["current_load"] + output)

machine["state"] = old_state
return true

func upgrade_machine(machine_id: String) -> bool:
if not machines.has(machine_id):
return false

var machine = machines[machine_id]
var upgrade_cost = 50.0 * (machine["upgrade_level"] + 1)

if not GameManager.can_afford(upgrade_cost):
return false

GameManager.spend_money(upgrade_cost)
machine["upgrade_level"] += 1
machine["efficiency"] += 0.1
machine["capacity"] = int(machine["capacity"] * 1.2)

return true

func get_machine(machine_id: String) -> Dictionary:
return machines.get(machine_id, {})

func get_all_machines() -> Array:
return machines.values()

func get_machines_by_type(type: MachineType) -> Array:
var result = []
for machine in machines.values():
if machine["type"] == type:
result.append(machine)
return result

func remove_machine(machine_id: String) -> bool:
if not machines.has(machine_id):
return false
machines.erase(machine_id)
return true

func get_total_power_consumption() -> float:
var total = 0.0
for machine in machines.values():
if machine["state"] != MachineState.OFFLINE:
total += machine["power_consumption"]
return total

func get_machine_count() -> int:
return machines.size()
