extends RefCounted
class_name WorkerDefinition

@export var id: String
@export var name: String
@export var efficiency: float = 1.0

func get_display_name() -> String:
    return name if not name.is_empty() else id.capitalize()
