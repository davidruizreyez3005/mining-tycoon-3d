extends RefCounted
class_name UpgradeDefinition

@export var id: String
@export var name: String
@export var cost: int = 100

func get_display_name() -> String:
    return name if not name.is_empty() else id.capitalize()
