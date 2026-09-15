extends Node3D
class_name Machine

@export var machine_id: String
@export var is_active: bool = false

var processing_progress: float = 0.0

func start_processing() -> void:
    is_active = true

func stop_processing() -> void:
    is_active = false

func get_status() -> String:
    return "active" if is_active else "idle"
