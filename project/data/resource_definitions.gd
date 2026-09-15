extends Resource
class_name ResourceDefinition

## Data-driven resource definition
## All resources are defined through Resource files

@export var id: String
@export var name: String
@export var rarity: String = "common"  # common, uncommon, rare, very_rare, legendary
@export var base_value: int = 1
@export var extraction_difficulty: float = 0.1  # 0-1, higher = slower extraction
@export var processing_requirement: String = ""  # Required machine upgrade ID
@export var unlock_depth: int = 0  # Minimum depth to find this resource
@export var visual_material: String = ""  # Material reference for rendering
@export var production_modifiers: Dictionary = {}  # worker_efficiency, machine_speed, value_multiplier
@export var stack_size: int = 999
@export var icon_texture: Texture2D

func get_display_name() -> String:
    return name if not name.is_empty() else id.capitalize()

func get_base_value() -> int:
    return base_value

func get_calculated_value(modifiers: Dictionary = {}) -> int:
var value = float(base_value)

    if production_modifiers.has("value_multiplier"):
        value *= production_modifiers["value_multiplier"]

        if modifiers.has("value_multiplier"):
            value *= modifiers["value_multiplier"]

            if modifiers.has("prestige_bonus"):
                value *= (1.0 + modifiers["prestige_bonus"])

                return int(value)

func can_be_mined_at_depth(depth: int) -> bool:
    return depth >= unlock_depth

func requires_processing() -> bool:
    return not processing_requirement.is_empty()

func get_rarity_color() -> Color:
    match rarity:
        "common":
        return Color.GRAY
        "uncommon":
        return Color.GREEN
        "rare":
        return Color.BLUE
        "very_rare":
        return Color.PURPLE
        "legendary":
        return Color.ORANGE
        _:
        return Color.WHITE