extends Node
class_name GameManager

signal state_changed(old_state: String, new_state: String)

var current_state: String = "BOOT"
var game_data: Dictionary = {}

func _ready() -> void:
    _transition_to("MAIN_MENU")

func _transition_to(new_state: String) -> void:
    var old = current_state
    current_state = new_state
    state_changed.emit(old, new_state)

func save_game() -> Error:
    return OK

func load_game() -> Error:
    return OK
