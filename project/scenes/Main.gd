extends Node3D

## Main scene controller - initializes and coordinates all game systems

@onready var game_manager: GameManager = $GameManager
@onready var input_system: InputSystem = $InputSystem
@onready var camera_rig: Node3D = $CameraRig
@onready var world: Node3D = $World
@onready var ui_layer: CanvasLayer = $UILayer

var resource_catalog: ResourceCatalog
var is_initialized := false

func _ready() -> void:
    print("Mining Tycoon 3D - Initializing...")

# Initialize resource catalog
resource_catalog = ResourceCatalog.new()
print("Resource catalog initialized with %d resources" % resource_catalog.get_resource_count())

# Setup input system
input_system.set_camera_target(camera_rig)

# Connect signals
_connect_signals()

# Initialize game manager
if game_manager:
    game_manager.game_initialized.connect(_on_game_initialized)

is_initialized = true
print("Main scene ready")

func _connect_signals() -> void:
    input_system.ui_tapped.connect(_on_ui_tapped)
input_system.object_selected.connect(_on_object_selected)

func _on_game_initialized() -> void:
    print("Game manager initialized")
# Check for existing save
if game_manager.has_save():
    var error = game_manager.load_game()
if error == OK:
    print("Save loaded successfully")
else:
    print("No save found or load failed, starting new game")
game_manager.start_new_game()
else:
    game_manager.start_new_game()

func _on_ui_tapped(ui_element: String) -> void:
    match ui_element:
        "pause":
    _toggle_pause()
"speed_toggle":
    _toggle_speed()

func _on_object_selected(object: Node3D) -> void:
    if object:
        print("Selected: %s" % object.name)
# Show object info UI
if ui_layer:
    ui_layer.show_object_info(object)

func _toggle_pause() -> void:
    if game_manager.game_state.is_pauseable():
        game_manager.game_state.transition_to(GameState.State.PAUSED)
get_tree().paused = true
elif game_manager.game_state.current_state == GameState.State.PAUSED:
    game_manager.game_state.transition_to(GameState.State.PLAYING)
get_tree().paused = false

func _toggle_speed() -> void:
    # Toggle between 1x, 2x, 3x simulation speed
var current_engine_scale = Engine.time_scale
if current_engine_scale >= 2.9:
    Engine.time_scale = 1.0
elif current_engine_scale >= 1.9:
    Engine.time_scale = 3.0
else:
    Engine.time_scale = 2.0
print("Simulation speed: %dx" % int(Engine.time_scale))

func _process(_delta: float) -> void:
    # Update any per-frame logic here
pass

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
    # Auto-save on exit
if game_manager and game_manager.game_state.is_in_gameplay():
    await game_manager.save_game()
get_tree().quit()