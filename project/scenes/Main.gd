extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var world: Node3D = $World
@onready var player: CharacterBody3D = $Player

var game_active: bool = false

func _ready() -> void:
ui_manager.gd print("Main: Game initializing...")
ui_manager.gd _initialize_game()

func _initialize_game() -> void:
ui_manager.gd GameState.transition_to(GameState.GameState.LOADING)
ui_manager.gd 
ui_manager.gd await get_tree().create_timer(0.5).timeout
ui_manager.gd 
ui_manager.gd _setup_camera()
ui_manager.gd _create_world()
ui_manager.gd 
ui_manager.gd GameState.transition_to(GameState.GameState.PLAYING)
ui_manager.gd game_active = true
ui_manager.gd 
ui_manager.gd print("Main: Game ready!")

func _setup_camera() -> void:
ui_manager.gd if camera:
ui_manager.gd ui_manager.gd camera.position = Vector3(10, 10, 10)
ui_manager.gd ui_manager.gd camera.look_at(Vector3.ZERO)

func _create_world() -> void:
ui_manager.gd if not world:
ui_manager.gd ui_manager.gd world = Node3D.new()
ui_manager.gd ui_manager.gd world.name = "World"
ui_manager.gd ui_manager.gd add_child(world)

func _input(event: InputEvent) -> void:
ui_manager.gd if event.is_action_pressed("pause"):
ui_manager.gd ui_manager.gd UIManager.toggle_pause()

func _process(delta: float) -> void:
ui_manager.gd if not game_active:
ui_manager.gd ui_manager.gd return
ui_manager.gd 
ui_manager.gd _update_camera(delta)

func _update_camera(delta: float) -> void:
ui_manager.gd if not camera:
ui_manager.gd ui_manager.gd return

func save_and_quit() -> void:
ui_manager.gd SaveManager.save_game()
ui_manager.gd get_tree().quit()

func load_game_or_start_new() -> void:
ui_manager.gd if SaveManager.has_save():
ui_manager.gd ui_manager.gd SaveManager.load_game()
ui_manager.gd else:
ui_manager.gd ui_manager.gd _start_new_game()

func _start_new_game() -> void:
ui_manager.gd print("Main: Starting new game")
ui_manager.gd GameManager.add_money(100.0)
ui_manager.gd EconomySystem.add_resource("stone", 10)
