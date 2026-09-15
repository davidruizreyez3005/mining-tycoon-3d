extends Node

signal money_changed(new_amount: float)
signal resource_changed(resource_id: String, amount: int)
signal production_calculated(amount: float)

const RESOURCE_DEFINITIONS: Dictionary = {
	"stone": {"name": "Stone", "rarity": "common", "base_value": 1.0, "depth": 0},
	"coal": {"name": "Coal", "rarity": "common", "base_value": 2.0, "depth": 1},
	"copper": {"name": "Copper", "rarity": "common", "base_value": 5.0, "depth": 1},
	"iron": {"name": "Iron", "rarity": "common", "base_value": 8.0, "depth": 2},
	"silver": {"name": "Silver", "rarity": "uncommon", "base_value": 15.0, "depth": 3},
	"gold": {"name": "Gold", "rarity": "uncommon", "base_value": 25.0, "depth": 4},
	"platinum": {"name": "Platinum", "rarity": "rare", "base_value": 50.0, "depth": 5},
	"emerald": {"name": "Emerald", "rarity": "rare", "base_value": 75.0, "depth": 6},
	"ruby": {"name": "Ruby", "rarity": "rare", "base_value": 100.0, "depth": 7},
	"sapphire": {"name": "Sapphire", "rarity": "rare", "base_value": 125.0, "depth": 8},
	"diamond": {"name": "Diamond", "rarity": "very_rare", "base_value": 250.0, "depth": 9},
	"exotic": {"name": "Exotic Matter", "rarity": "very_rare", "base_value": 500.0, "depth": 10}
}

var resources: Dictionary = {}
var production_rate: float = 0.0
var last_production_time: int = 0

func _ready() -> void:
	_initialize_resources()
	last_production_time = Time.get_unix_time_from_system() as int

func _initialize_resources() -> void:
	for resource_id in RESOURCE_DEFINITIONS.keys():
		resources[resource_id] = 0

func get_resource_definition(resource_id: String) -> Dictionary:
	return RESOURCE_DEFINITIONS.get(resource_id, {})

func get_resource_name(resource_id: String) -> String:
	var def = get_resource_definition(resource_id)
	return def.get("name", resource_id)

func get_resource_value(resource_id: String) -> float:
	var def = get_resource_definition(resource_id)
	return def.get("base_value", 1.0)

func add_resource(resource_id: String, amount: int) -> void:
	if not resources.has(resource_id):
		resources[resource_id] = 0
	resources[resource_id] += amount
	resource_changed.emit(resource_id, resources[resource_id])

func remove_resource(resource_id: String, amount: int) -> bool:
	if not resources.has(resource_id):
		return false
	if resources[resource_id] < amount:
		return false
	resources[resource_id] -= amount
	resource_changed.emit(resource_id, resources[resource_id])
	return true

func get_resource_amount(resource_id: String) -> int:
	return resources.get(resource_id, 0)

func has_resource(resource_id: String, amount: int) -> bool:
	return get_resource_amount(resource_id) >= amount

func get_all_resources() -> Dictionary:
	return resources.duplicate()

func calculate_production(delta_time: float) -> float:
	# Base production rate (can be modified by upgrades, workers, machines)
	var base_rate = 10.0
	var worker_bonus = 1.0
	var machine_bonus = 1.0
	var upgrade_bonus = 1.0
	
	production_rate = base_rate * worker_bonus * machine_bonus * upgrade_bonus
	var produced = production_rate * delta_time
	
	production_calculated.emit(produced)
	return produced

func simulate_offline_production(seconds: int) -> Dictionary:
	var result = {
		"resources_mined": {},
		"money_earned": 0.0,
		"production_time": seconds
	}
	
	# Simple offline simulation
	var production_per_second = 5.0
	var total_produced = production_per_second * min(seconds, 86400) # Cap at 24 hours
	
	# Distribute among common resources
	var common_resources = ["stone", "coal", "copper", "iron"]
	var per_resource = total_produced / common_resources.size()
	
	for resource_id in common_resources:
		var amount = int(per_resource)
		add_resource(resource_id, amount)
		result["resources_mined"][resource_id] = amount
		
		# Simulate selling a portion
		var sell_amount = int(amount * 0.8)
		var value = sell_amount * get_resource_value(resource_id)
		result["money_earned"] += value
	
	return result

func get_total_inventory_value() -> float:
	var total = 0.0
	for resource_id in resources:
		total += resources[resource_id] * get_resource_value(resource_id)
	return total

func sell_resource(resource_id: String, amount: int) -> float:
	if not remove_resource(resource_id, amount):
		return 0.0
	
	var value = amount * get_resource_value(resource_id)
	return value

func get_rarity_color(rarity: String) -> String:
	match rarity:
		"common": return "#ffffff"
		"uncommon": return "#00ff00"
		"rare": return "#0088ff"
		"very_rare": return "#ff8800"
		_: return "#ffffff"
