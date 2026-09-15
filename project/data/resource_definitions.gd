extends RefCounted
class_name ResourceDefinition

@export var id: String
@export var name: String
@export var rarity: String = "common"
@export var value: int = 1
@export var extraction_difficulty: float = 1.0

func get_display_name() -> String:
    return name if not name.is_empty() else id.capitalize()
