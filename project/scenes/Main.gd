extends Node3D

@onready var game_manager = $GameManager
@onready var input_system = $InputSystem

func _ready() -> void:
    print("Mining Tycoon 3D loaded!")

func _input(event: InputEvent) -> void:
    if input_system:
        input_system.handle_input(event)
