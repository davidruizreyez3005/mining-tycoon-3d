extends RefCounted
class_name WorkerDefinition

## Data-driven worker definition
## Defines worker types, capabilities, and visual appearance

@export var id: String
@export var name: String
@export var worker_type: String = "basic"  # basic, skilled, engineer, supervisor
@export var base_efficiency: float = 1.0  # 0-2, affects work speed
@export var max_stamina: float = 100.0
@export var stamina_drain_rate: float = 0.5  # per second while working
@export var stamina_regen_rate: float = 0.3  # per second while idle
@export var movement_speed: float = 3.0
@export var carry_capacity: int = 10
@export var unlock_cost: int = 100
@export var wage_per_minute: int = 1
@export var required_unlock_depth: int = 0
@export var special_abilities: Array[String] = []  # e.g., "repair_bonus", "mining_speed"
@export var model_path: String = ""  # Path to 3D model
@export var animations: Dictionary = {}  # Animation names

func get_hire_cost() -> int:
return unlock_cost

func get_total_wage(minutes_worked: int) -> int:
return wage_per_minute * minutes_worked

func can_work_at_depth(depth: int) -> bool:
return depth >= required_unlock_depth

func has_ability(ability_id: String) -> bool:
return ability_id in special_abilities

func get_efficiency_with_bonuses(bonuses: Dictionary) -> float:
var eff = base_efficiency
if bonuses.has("efficiency_multiplier"):
eff *= bonuses["efficiency_multiplier"]
if bonuses.has("prestige_bonus"):
eff *= (1.0 + bonuses["prestige_bonus"])
return clamp(eff, 0.1, 5.0)
