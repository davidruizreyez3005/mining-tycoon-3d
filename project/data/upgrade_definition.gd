extends RefCounted
class_name UpgradeDefinition

## Data-driven upgrade definition
## Defines upgrades for machines, workers, and global systems

@export var id: String
@export var name: String
@export var description: String
@export var upgrade_type: String = "machine"  # machine, worker, global, technology
@export var tier: int = 1
@export var cost: int = 100
@export var prerequisites: Array[String] = []  # IDs of required upgrades
@export var target_type: String = ""  # Specific machine/worker type this applies to
@export var effects: Dictionary = {}  # {stat_name: value or multiplier}
@export var visual_changes: Dictionary = {}  # Model changes, color changes, etc.
@export var unlock_depth: int = 0  # Minimum depth required
@export var is_permanent: bool = true  # false for temporary buffs

func get_cost() -> int:
    return cost

func get_effects() -> Dictionary:
    return effects.duplicate()

func has_prerequisite(upgrade_id: String) -> bool:
    return upgrade_id in prerequisites

func can_apply_to(target_type_check: String) -> bool:
    if target_type.is_empty():
        return true
return target_type == target_type_check

func get_display_name() -> String:
    return name if not name.is_empty() else id.capitalize()

func get_description() -> String:
    return description

func get_rarity_color() -> Color:
    match tier:
        1:
        return Color.GRAY
2:
    return Color.GREEN
3:
    return Color.BLUE
4:
    return Color.PURPLE
5:
    return Color.ORANGE
_:
    return Color.WHITE