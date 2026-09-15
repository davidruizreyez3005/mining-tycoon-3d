extends RefCounted
class_name PrestigeSystem

## Prestige system - allows players to reset progress for permanent bonuses
## Core prestige mechanics with meaningful progression

signal prestige_performed(currency_earned: int)
signal prestige_bonus_updated(bonus: float)
signal milestone_unlocked(milestone_id: String)

# Prestige currencies
var prestige_points: int = 0
var total_prestige_count: int = 0

# Permanent bonuses (multiplicative)
var global_production_bonus: float = 0.0  # +10% per prestige
var worker_efficiency_bonus: float = 0.0  # +5% per prestige
var resource_value_bonus: float = 0.0     # +5% per prestige
var unlock_speed_bonus: float = 0.0       # +2% per prestige

# Milestones (one-time unlocks)
var unlocked_milestones: Array[String] = []

# Prestige requirements
const BASE_PRESTIGE_REQUIREMENT := 10000  # $10,000 to first prestige
const PRESTIGE_MULTIPLIER := 2.0           # Each prestige requires 2x more
const PRESTIGE_CURRENCY_BASE := 1          # Base currency per prestige

# Milestone definitions
const MILESTONES := {
"auto_sell": {"name": "Auto-Sell", "description": "Automatically sell resources", "cost": 1},
"double_workers": {"name": "Double Workers", "description": "+10 max workers", "cost": 2},
"start_cash": {"name": "Starting Capital", "description": "Start with $500", "cost": 3},
"depth_unlock": {"name": "Deep Access", "description": "Start with depth 10 unlocked", "cost": 4},
"machine_discount": {"name": "Machine Discount", "description": "-20% machine costs", "cost": 5},
"worker_discount": {"name": "Worker Discount", "description": "-20% worker hire costs", "cost": 5},
"rare_start": {"name": "Rare Discovery", "description": "Start with rare resource node", "cost": 7},
"automation_t1": {"name": "Basic Automation", "description": "Start with conveyor belt", "cost": 8},
"automation_t2": {"name": "Advanced Automation", "description": "Start with processor", "cost": 10},
"legendary_node": {"name": "Legendary Node", "description": "Start with very rare resource", "cost": 15}
}

func _init() -> void:
    pass

func can_prestige(current_money: int, current_depth: int) -> bool:
var requirement = get_prestige_requirement()
    return current_money >= requirement or current_depth >= 50

func get_prestige_requirement() -> int:
    if total_prestige_count == 0:
        return BASE_PRESTIGE_REQUIREMENT
        return int(BASE_PRESTIGE_REQUIREMENT * pow(PRESTIGE_MULTIPLIER, total_prestige_count))

func calculate_prestige_currency(total_earned: int, max_depth: int, achievements_completed: int) -> int:
    # Calculate currency based on multiple factors
var money_factor = float(total_earned) / float(get_prestige_requirement())
var depth_factor = float(max_depth) / 50.0
var achievement_factor = float(achievements_completed) / 10.0

var base_currency = PRESTIGE_CURRENCY_BASE
var earned = int(base_currency + (money_factor * 1) + (depth_factor * 2) + (achievement_factor * 1))

    return max(1, earned)

func perform_prestige(total_earned: int, max_depth: int, achievements_completed: int) -> int:
var currency = calculate_prestige_currency(total_earned, max_depth, achievements_completed)

    prestige_points += currency
    total_prestige_count += 1

    _update_bonuses()

    prestige_performed.emit(currency)
    print("Prestige performed! Earned %d points (Total: %d)" % [currency, prestige_points])

    return currency

func _update_bonuses() -> void:
    # Update multiplicative bonuses based on prestige count
    global_production_bonus = float(total_prestige_count) * 0.10    # 10% per prestige
    worker_efficiency_bonus = float(total_prestige_count) * 0.05    # 5% per prestige
    resource_value_bonus = float(total_prestige_count) * 0.05       # 5% per prestige
    unlock_speed_bonus = float(total_prestige_count) * 0.02         # 2% per prestige

func get_total_production_multiplier() -> float:
    return 1.0 + global_production_bonus

func get_worker_efficiency_multiplier() -> float:
    return 1.0 + worker_efficiency_bonus

func get_resource_value_multiplier() -> float:
    return 1.0 + resource_value_bonus

func get_unlock_speed_multiplier() -> float:
    return 1.0 + unlock_speed_bonus

func can_unlock_milestone(milestone_id: String) -> bool:
    if milestone_id not in MILESTONES:
        return false
        if milestone_id in unlocked_milestones:
            return false

var cost = MILESTONES[milestone_id]["cost"]
            return prestige_points >= cost

func unlock_milestone(milestone_id: String) -> bool:
    if not can_unlock_milestone(milestone_id):
        return false

var cost = MILESTONES[milestone_id]["cost"]
        prestige_points -= cost
        unlocked_milestones.append(milestone_id)

        milestone_unlocked.emit(milestone_id)
        print("Milestone unlocked: %s" % MILESTONES[milestone_id]["name"])

        return true

func get_milestone(milestone_id: String) -> Dictionary:
    return MILESTONES.get(milestone_id, {})

func get_all_milestones() -> Array:
var result = []
    for id in MILESTONES.keys():
var milestone = MILESTONES[id].duplicate()
        milestone["id"] = id
        milestone["unlocked"] = id in unlocked_milestones
        milestone["can_afford"] = prestige_points >= milestone["cost"]
        result.append(milestone)
        return result

func has_milestone(milestone_id: String) -> bool:
    return milestone_id in unlocked_milestones

func get_starting_bonus() -> Dictionary:
var bonus = {
    "money": 100,
    "max_depth": 0,
    "machines": [],
    "workers": [],
    "resources": {}
    }

# Apply milestone bonuses
    if has_milestone("start_cash"):
        bonus["money"] = 600  # Base 100 + 500 bonus

        if has_milestone("depth_unlock"):
            bonus["max_depth"] = 10

            if has_milestone("double_workers"):
                bonus["max_workers_bonus"] = 10

                if has_milestone("rare_start"):
                    bonus["resources"]["gold"] = 5

                    if has_milestone("automation_t1"):
                        bonus["machines"].append({"type": "conveyor", "tier": 1})

                        if has_milestone("automation_t2"):
                            bonus["machines"].append({"type": "processor", "tier": 1})

                            if has_milestone("legendary_node"):
                                bonus["resources"]["diamond"] = 1

                                return bonus

func get_prestige_info() -> Dictionary:
    return {
    "prestige_points": prestige_points,
    "total_prestige_count": total_prestige_count,
    "production_bonus": global_production_bonus,
    "worker_bonus": worker_efficiency_bonus,
    "value_bonus": resource_value_bonus,
    "milestones_unlocked": unlocked_milestones.size(),
    "next_requirement": get_prestige_requirement()
    }

func save_state() -> Dictionary:
    return {
    "prestige_points": prestige_points,
    "total_prestige_count": total_prestige_count,
    "unlocked_milestones": unlocked_milestones
    }

func load_state(data: Dictionary) -> void:
    if data.has("prestige_points"):
        prestige_points = data["prestige_points"]
        if data.has("total_prestige_count"):
            total_prestige_count = data["total_prestige_count"]
            if data.has("unlocked_milestones"):
                unlocked_milestones = data["unlocked_milestones"]

                _update_bonuses()