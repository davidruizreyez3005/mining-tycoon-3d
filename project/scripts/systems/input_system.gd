extends Node
class_name InputSystem

var camera_enabled: bool = true

func handle_input(event: InputEvent) -> void:
    if not camera_enabled:
        return
    
    if event is InputEventScreenTouch:
        _handle_touch(event)
    elif event is InputEventMouse:
        _handle_mouse(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
    pass

func _handle_mouse(event: InputEventMouse) -> void:
    pass

func set_camera_enabled(enabled: bool) -> void:
    camera_enabled = enabled
