extends Node3D
class_name Worker

@export var worker_id: String
@export var worker_type: String = "miner"

var current_task: Dictionary = {}
var state: String = "idle"

func assign_task(task: Dictionary) -> void:
    current_task = task
    state = "working"

func complete_task() -> void:
    current_task = {}
    state = "idle"
