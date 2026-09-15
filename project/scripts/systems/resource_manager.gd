extends Node

signal resource_mined(resource_id: String, amount: int)
signal resource_collected(resource_id: String, amount: int)

var mined_resources: Dictionary = {}

func _ready() -> void:
mined_resources = {}

func mine_resource(resource_id: String, base_amount: int, modifiers: Dictionary = {}) -> int:
var multiplier = 1.0

if modifiers.has("tool_bonus"):
multiplier += modifiers["tool_bonus"]
if modifiers.has("worker_bonus"):
multiplier += modifiers["worker_bonus"]
if modifiers.has("machine_bonus"):
multiplier += modifiers["machine_bonus"]

var final_amount = int(base_amount * multiplier)
final_amount = max(1, final_amount)

if not mined_resources.has(resource_id):
mined_resources[resource_id] = 0
mined_resources[resource_id] += final_amount

resource_mined.emit(resource_id, final_amount)
return final_amount

func collect_resource(resource_id: String, amount: int) -> bool:
if not mined_resources.has(resource_id):
return false
if mined_resources[resource_id] < amount:
return false

mined_resources[resource_id] -= amount
EconomySystem.add_resource(resource_id, amount)
resource_collected.emit(resource_id, amount)
return true

func get_mined_amount(resource_id: String) -> int:
return mined_resources.get(resource_id, 0)

func clear_mined_resources() -> void:
mined_resources.clear()
