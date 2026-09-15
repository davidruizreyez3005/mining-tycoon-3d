extends Node
class_name InputSystem

## Mobile-first input system for touch controls
## Handles camera pan, zoom, rotation, and object selection

signal touch_started(position: Vector2)
signal touch_ended(position: Vector2)
signal touch_dragged(delta: Vector2)
signal pinch_zoomed(factor: float)
signal object_selected(object: Node3D)
signal ui_tapped(ui_element: String)

var camera_target: Node3D
var is_dragging := false
var last_touch_position := Vector2.ZERO
var pinch_start_distance := 0.0
var selected_object: Node3D = null

# Configuration
var pan_speed := 0.5
var zoom_speed := 0.8
var rotate_speed := 0.3
var touch_threshold := 10.0  # pixels to consider as drag start
var pinch_threshold := 5.0   # pixels change to consider as pinch

func _ready() -> void:
    _setup_input_actions()

func _setup_input_actions() -> void:
    if not InputMap.has_action("ui_touch_interaction"):
        InputMap.add_action("ui_touch_interaction")
var event := InputEventScreenTouch.new()
event.pressed = true
InputMap.action_add_event("ui_touch_interaction", event)

if not InputMap.has_action("ui_pan_camera"):
    InputMap.add_action("ui_pan_camera")

if not InputMap.has_action("ui_zoom"):
    InputMap.add_action("ui_zoom")

if not InputMap.has_action("ui_select"):
    InputMap.add_action("ui_select")
var event := InputEventMouseButton.new()
event.button_index = MOUSE_BUTTON_LEFT
event.pressed = true
InputMap.action_add_event("ui_select", event)

func set_camera_target(target: Node3D) -> void:
    camera_target = target

func _input(event: InputEvent) -> void:
    _handle_touch_events(event)
_handle_mouse_events(event)
_handle_keyboard_events(event)

func _handle_touch_events(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var touch_event := event as InputEventScreenTouch
var position = touch_event.position

if touch_event.pressed:
    is_dragging = true
last_touch_position = position
touch_started.emit(position)
else:
    is_dragging = false
if last_touch_position.distance_to(position) < touch_threshold:
    # Considered as tap
_handle_tap(position)
touch_ended.emit(position)

elif event is InputEventScreenDrag:
    if is_dragging:
        var delta = event.position - last_touch_position
if delta.length() > touch_threshold:
    touch_dragged.emit(delta)
_pan_camera(delta)
last_touch_position = event.position

elif event is InputEventMagnifyGesture:
    var factor = event.factor
if abs(factor - 1.0) * 100 > pinch_threshold:
    pinch_zoomed.emit(factor)
_zoom_camera(factor)

func _handle_mouse_events(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var mouse_event := event as InputEventMouseButton
if mouse_event.button_index == MOUSE_BUTTON_LEFT:
    if mouse_event.pressed:
        is_dragging = true
last_touch_position = get_viewport().get_mouse_position()
else:
    is_dragging = false
elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
    _zoom_camera(1.0 + zoom_speed * 0.1)
elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
    _zoom_camera(1.0 - zoom_speed * 0.1)

elif event is InputEventMouseMotion:
    if is_dragging and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        var current_pos = get_viewport().get_mouse_position()
var delta = current_pos - last_touch_position
if delta.length() > touch_threshold:
    touch_dragged.emit(delta)
_pan_camera(delta)
last_touch_position = current_pos

func _handle_keyboard_events(event: InputEvent) -> void:
    if event is InputEventKey:
        if not event.pressed:
            return

match event.keycode:
    KEY_ESCAPE:
        ui_tapped.emit("pause")
KEY_SPACE:
    ui_tapped.emit("speed_toggle")

func _handle_tap(position: Vector2) -> void:
    var viewport = get_viewport()
if viewport:
    var camera = viewport.get_camera_3d()
if camera:
    var from = camera.project_ray_origin(position)
var to = from + camera.project_ray_normal(position) * 1000.0

var space_state = camera.get_world_3d().direct_space_state
if space_state:
    var query = PhysicsRayQueryParameters3D.create(from, to)
query.exclude = [camera]
var result = space_state.intersect_ray(query)

if result and result.collider:
    selected_object = result.collider
object_selected.emit(selected_object)
else:
    selected_object = null

func _pan_camera(delta: Vector2) -> void:
    if camera_target:
        camera_target.translate_x(-delta.x * pan_speed * 0.01)
camera_target.translate_z(-delta.y * pan_speed * 0.01)

func _zoom_camera(factor: float) -> void:
    if camera_target:
        var zoom_amount = (factor - 1.0) * zoom_speed
camera_target.scale = Vector3.ONE * max(0.5, min(2.0, camera_target.scale.x - zoom_amount))

func clear_selection() -> void:
    selected_object = null

func get_selected_object() -> Node3D:
    return selected_object