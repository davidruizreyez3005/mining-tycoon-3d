extends Node

signal touch_started(position: Vector2)
signal touch_ended(position: Vector2)
signal touch_dragged(delta: Vector2)
signal pinch_zoomed(factor: float)

var is_mobile: bool = false
var camera_sensitivity: float = 0.5
var zoom_sensitivity: float = 0.1

func _ready() -> void:
_detect_platform()

func _detect_platform() -> void:
is_mobile = OS.get_name() in ["Android", "iOS"]
print("Platform: %s, Mobile: %s" % [OS.get_name(), is_mobile])

func _input(event: InputEvent) -> void:
if event is InputEventScreenTouch:
_handle_touch(event)
elif event is InputEventScreenDrag:
_handle_drag(event)
elif event is InputEventMouseButton:
_handle_mouse_button(event)
elif event is InputEventMouseMotion:
_handle_mouse_motion(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
if event.pressed:
touch_started.emit(event.position)
else:
touch_ended.emit(event.position)

func _handle_drag(event: InputEventScreenDrag) -> void:
touch_dragged.emit(event.relative)

func _handle_mouse_button(event: InputEventMouseButton) -> void:
if event.button_index == MOUSE_BUTTON_WHEEL_UP:
pinch_zoomed.emit(1.0 + zoom_sensitivity)
elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
pinch_zoomed.emit(1.0 - zoom_sensitivity)

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
if event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
touch_dragged.emit(event.relative * camera_sensitivity)

func get_camera_rotation_speed() -> float:
return camera_sensitivity

func set_camera_rotation_speed(speed: float) -> void:
camera_sensitivity = clamp(speed, 0.1, 2.0)

func get_zoom_speed() -> float:
return zoom_sensitivity

func set_zoom_speed(speed: float) -> void:
zoom_sensitivity = clamp(speed, 0.01, 0.5)
