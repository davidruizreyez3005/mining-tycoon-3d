extends RefCounted
class_name EconomySystem

## Deterministic economy simulation engine
## Handles production, consumption, selling, upgrades, and offline progression

signal money_changed(new_amount: int)
signal resource_changed(resource_id: String, amount: int)
signal production_completed(data: Dictionary)

# Resource definitions - matches data/resource_definitions.tres
const RESOURCE_DEFINITIONS := {
"stone": {"base_value": 1, "rarity": "common", "unlock_depth": 0},
"coal": {"base_value": 3, "rarity": "common", "unlock_depth": 5},
"copper": {"base_value": 8, "rarity": "common", "unlock_depth": 10},
"iron": {"base_value": 12, "rarity": "common", "unlock_depth": 15},
"silver": {"base_value": 25, "rarity": "uncommon", "unlock_depth": 25},
"gold": {"base_value": 50, "rarity": "uncommon", "unlock_depth": 35},
"quartz": {"base_value": 35, "rarity": "uncommon", "unlock_depth": 30},
"platinum": {"base_value": 100, "rarity": "rare", "unlock_depth": 50},
"emerald": {"base_value": 150, "rarity": "rare", "unlock_depth": 55},
"ruby": {"base_value": 175, "rarity": "rare", "unlock_depth": 60},
"sapphire": {"base_value": 180, "rarity": "rare", "unlock_depth": 65},
"diamond": {"base_value": 500, "rarity": "very_rare", "unlock_depth": 80}
}

var player_data: Dictionary
var world_data: Dictionary
var resources: Dictionary = {}
var production_rate: float = 1.0
var value_multiplier: float = 1.0
var worker_efficiency: float = 1.0

func initialize(player: Dictionary, world: Dictionary) -> void:
    player_data = player
    world_data = world
    _initialize_resources()

func _initialize_resources() -> void:
    for resource_id in RESOURCE_DEFINITIONS.keys():
        if not resources.has(resource_id):
            resources[resource_id] = 0

func get_resource(resource_id: String) -> int:
    return resources.get(resource_id, 0)

func add_resource(resource_id: String, amount: int) -> void:
    if amount <= 0:
        return
        if not resources.has(resource_id):
            resources[resource_id] = 0
            resources[resource_id] += amount
            resource_changed.emit(resource_id, amount)

func remove_resource(resource_id: String, amount: int) -> bool:
var current = get_resource(resource_id)
    if current >= amount:
        resources[resource_id] -= amount
        resource_changed.emit(resource_id, -amount)
        return true
        return false

func sell_resource(resource_id: String, amount: int) -> int:
    if not RESOURCE_DEFINITIONS.has(resource_id):
        return 0
        if not remove_resource(resource_id, amount):
            return 0

var base_value = RESOURCE_DEFINITIONS[resource_id]["base_value"]
var value = int(base_value * amount * value_multiplier)

            if player_data.has("money"):
                player_data["money"] += value
                player_data["total_earned"] += value
                money_changed.emit(player_data["money"])

                return value

func sell_all_resources() -> int:
var total = 0
    for resource_id in resources.keys():
        if resources[resource_id] > 0:
            total += sell_resource(resource_id, resources[resource_id])
            return total

func calculate_production(machines: Array, workers: int, delta_seconds: float) -> Dictionary:
var production = {}

    for machine in machines:
var machine_id = machine.get("id", "")
var resource_output = machine.get("output_resource", "stone")
var base_rate = machine.get("base_rate", 1.0)
var efficiency = machine.get("efficiency", 1.0)

var effective_workers = min(workers, machine.get("worker_slots", 1))
var worker_bonus = 1.0 + (effective_workers * 0.2)  # 20% per worker

var rate = base_rate * efficiency * worker_bonus * worker_efficiency * production_rate
var produced = int(rate * delta_seconds)

        if produced > 0:
            if not production.has(resource_output):
                production[resource_output] = 0
                production[resource_output] += produced

                return production

func apply_production(production: Dictionary) -> void:
    for resource_id in production.keys():
        add_resource(resource_id, production[resource_id])

func calculate_offline_earnings(offline_seconds: float) -> Dictionary:
var result = {
    "resources_mined": {},
    "resources_processed": {},
    "resources_sold": 0,
    "money_earned": 0,
    "discoveries": []
    }

# Cap offline time to prevent exploitation (max 24 hours)
var capped_time = min(offline_seconds, 86400.0)

# Get current machines and workers from world data
var machines = world_data.get("machines", [])
var worker_count = world_data.get("workers", []).size()

# Calculate offline production
var offline_production = calculate_production(machines, worker_count, capped_time)
    result["resources_mined"] = offline_production

# Auto-sell produced resources (simplified offline model)
    for resource_id in offline_production.keys():
var amount = offline_production[resource_id]
var def = RESOURCE_DEFINITIONS.get(resource_id, {})
var value = def.get("base_value", 1) * amount
        result["money_earned"] += int(value * value_multiplier)

# Apply prestige multiplier if applicable
var prestige_mult = 1.0 + (player_data.get("prestige_count", 0) * 0.1)
        result["money_earned"] = int(result["money_earned"] * prestige_mult)

        return result

func validate_offline_time(timestamp: int) -> int:
var current_time = Time.get_unix_time_from_system()
var elapsed = current_time - timestamp

# Reject negative or impossibly large values
    if elapsed < 0:
        return 0
        if elapsed > 604800:  # Max 1 week
            return 604800

            return int(elapsed)

func get_money() -> int:
    return player_data.get("money", 0)

func can_afford(cost: int) -> bool:
    return get_money() >= cost

func spend(cost: int) -> bool:
    if can_afford(cost):
        player_data["money"] -= cost
        money_changed.emit(player_data["money"])
        return true
        return false

func save_state() -> Dictionary:
    return {
    "resources": resources.duplicate(),
    "production_rate": production_rate,
    "value_multiplier": value_multiplier,
    "worker_efficiency": worker_efficiency,
    "last_save_time": Time.get_unix_time_from_system()
    }

func load_state(data: Dictionary) -> void:
    if data.has("resources"):
        resources = data["resources"].duplicate()
        if data.has("production_rate"):
            production_rate = data["production_rate"]
            if data.has("value_multiplier"):
                value_multiplier = data["value_multiplier"]
                if data.has("worker_efficiency"):
                    worker_efficiency = data["worker_efficiency"]