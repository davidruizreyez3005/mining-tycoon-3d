extends Node
class_name UIManager

## Main UI controller - manages all UI screens and HUD elements
## Handles mobile-friendly touch interface

signal pause_toggled(is_paused: bool)
signal speed_changed(new_speed: float)
signal upgrade_requested(upgrade_id: String)
signal machine_selected(machine: Node3D)
signal resource_view_requested()
signal worker_view_requested()
signal settings_requested()
signal prestige_requested()

enum UIScreen {
	HUD,
	UPGRADES,
	WORKERS,
	RESOURCES,
	SETTINGS,
	PRESTIGE,
	QUESTS,
	DISCOVERY,
	OFFLINE_REWARD,
	PAUSE_MENU
}

var current_screen: UIScreen = UIScreen.HUD
var is_ui_active: bool = true

# Reference to GameState enum via GameManager
var GameStateEnum: Script = load("res://scripts/core/game_state.gd")

# HUD elements
@onready var cash_label: Label = $HUD/CashLabel if $HUD else null
@onready var resources_panel: Control = $HUD/ResourcesPanel if $HUD else null
@onready var production_label: Label = $HUD/ProductionLabel if $HUD else null
@onready var depth_label: Label = $HUD/DepthLabel if $HUD else null
@onready var workers_label: Label = $HUD/WorkersLabel if $HUD else null
@onready var pause_button: Button = $HUD/PauseButton if $HUD else null
@onready var speed_button: Button = $HUD/SpeedButton if $HUD else null

# Screen containers
@onready var upgrades_screen: Control = $UpgradeScreen if has_node("$UpgradeScreen") else null
@onready var workers_screen: Control = $WorkersScreen if has_node("$WorkersScreen") else null
@onready var resources_screen: Control = $ResourcesScreen if has_node("$ResourcesScreen") else null
@onready var settings_screen: Control = $SettingsScreen if has_node("$SettingsScreen") else null
@onready var prestige_screen: Control = $PrestigeScreen if has_node("$PrestigeScreen") else null
@onready var quests_screen: Control = $QuestsScreen if has_node("$QuestsScreen") else null
@onready var pause_screen: Control = $PauseScreen if has_node("$PauseScreen") else null
@onready var offline_screen: Control = $OfflineRewardScreen if has_node("$OfflineRewardScreen") else null

# Game manager reference
var game_manager: GameManager
var economy: EconomySystem
var quest_manager: QuestManager

# Resource catalog for display
var resource_catalog: ResourceCatalog
var worker_catalog: WorkerCatalog
var upgrade_catalog: UpgradeCatalog

func _ready() -> void:
	resource_catalog = ResourceCatalog.new()
	worker_catalog = WorkerCatalog.new()
	upgrade_catalog = UpgradeCatalog.new()
	quest_manager = QuestManager.new()
	
	_connect_signals()
	_initialize_screens()
	print("UI Manager initialized")

func _connect_signals() -> void:
	if pause_button:
		pause_button.pressed.connect(_on_pause_pressed)
	if speed_button:
		speed_button.pressed.connect(_on_speed_pressed)

func _initialize_screens() -> void:
	# Hide all non-HUD screens initially
	var screens = [upgrades_screen, workers_screen, resources_screen, 
				   settings_screen, prestige_screen, quests_screen, pause_screen, offline_screen]
	for screen in screens:
		if screen:
			screen.visible = false
	
	# Show HUD
	if has_node("$HUD"):
		$HUD.visible = true

func initialize_with_game_manager(gm: GameManager) -> void:
	game_manager = gm
	if game_manager:
		game_manager.economy.money_changed.connect(_update_cash_display)
		game_manager.game_state.state_changed.connect(_on_state_changed)

func _process(_delta: float) -> void:
	if is_ui_active and game_manager:
		_update_hud()

func _update_hud() -> void:
	if not game_manager or not game_manager.economy:
		return
	
	# Update cash
	if cash_label:
		cash_label.text = "$%d" % game_manager.player_data.get("money", 0)
	
	# Update production rate
	if production_label:
		var rate = _calculate_production_rate()
		production_label.text = "Production: $%d/min" % rate
	
	# Update depth
	if depth_label:
		var depth = game_manager.world_data.get("current_depth", 0)
		depth_label.text = "Depth: %dm" % depth
	
	# Update workers
	if workers_label:
		var worker_count = game_manager.world_data.get("workers", []).size()
		workers_label.text = "Workers: %d" % worker_count
	
	# Update resources panel
	if resources_panel:
		_update_resources_panel()

func _update_cash_display(new_amount: int) -> void:
	if cash_label:
		cash_label.text = "$%d" % new_amount

func _update_resources_panel() -> void:
	if not resources_panel or not game_manager.economy:
		return
	
	# Clear existing resource labels
	for child in resources_panel.get_children():
		if child is Label:
			child.queue_free()
	
	# Add labels for each resource with amount > 0
	for resource_id in game_manager.economy.resources:
		var amount = game_manager.economy.resources[resource_id]
		if amount > 0:
			var label = Label.new()
			var def = resource_catalog.get_resource(resource_id)
			var name = def.name.capitalize() if def else resource_id.capitalize()
			label.text = "%s: %d" % [name, amount]
			label.add_theme_color_override("font_color", _get_rarity_color(def.rarity if def else "common"))
			resources_panel.add_child(label)

func _get_rarity_color(rarity: String) -> Color:
	match rarity:
		"common": return Color.GRAY
		"uncommon": return Color.GREEN
		"rare": return Color.BLUE
		"very_rare": return Color.PURPLE
		"legendary": return Color.ORANGE
		_: return Color.WHITE

func _calculate_production_rate() -> int:
	if not game_manager or not game_manager.economy:
		return 0
	
	var machines = game_manager.world_data.get("machines", [])
	var workers = game_manager.world_data.get("workers", []).size()
	
	var rate = 0
	for machine in machines:
		var base_rate = machine.get("base_rate", 1.0)
		var output = machine.get("output_per_operation", 1)
		var resource = machine.get("output_resource", "stone")
		
		var def = resource_catalog.get_resource(resource)
		var value = def.base_value if def else 1
		
		rate += int(base_rate * output * value * 60)  # Per minute
	
	return rate

func _on_state_changed(from_state, to_state) -> void:
	# Use GameState.State enum values directly
	match to_state:
		5:  # PAUSED
			_show_screen(UIScreen.PAUSE_MENU)
		3:  # PLAYING
			_show_screen(UIScreen.HUD)
		6:  # UPGRADING
			_show_screen(UIScreen.UPGRADES)
		8:  # OFFLINE_REWARD
			_show_screen(UIScreen.OFFLINE_REWARD)
		9:  # PRESTIGE
			_show_screen(UIScreen.PRESTIGE)

func _show_screen(screen: UIScreen) -> void:
	current_screen = screen
	
	# Hide all screens first
	var all_screens = [upgrades_screen, workers_screen, resources_screen, 
					   settings_screen, prestige_screen, quests_screen, pause_screen, offline_screen]
	for s in all_screens:
		if s:
			s.visible = false
	
	# Show requested screen
	match screen:
		UIScreen.HUD:
			if has_node("$HUD"):
				$HUD.visible = true
		UIScreen.UPGRADES:
			if upgrades_screen:
				upgrades_screen.visible = true
				_populate_upgrades_screen()
		UIScreen.WORKERS:
			if workers_screen:
				workers_screen.visible = true
				_populate_workers_screen()
		UIScreen.RESOURCES:
			if resources_screen:
				resources_screen.visible = true
				_populate_resources_screen()
		UIScreen.SETTINGS:
			if settings_screen:
				settings_screen.visible = true
		UIScreen.PRESTIGE:
			if prestige_screen:
				prestige_screen.visible = true
				_populate_prestige_screen()
		UIScreen.QUESTS:
			if quests_screen:
				quests_screen.visible = true
				_populate_quests_screen()
		UIScreen.PAUSE_MENU:
			if pause_screen:
				pause_screen.visible = true
		UIScreen.OFFLINE_REWARD:
			if offline_screen:
				offline_screen.visible = true

func _populate_upgrades_screen() -> void:
	if not upgrades_screen:
		return
	# Populate with available upgrades from catalog
	print("Populating upgrades screen...")

func _populate_workers_screen() -> void:
	if not workers_screen:
		return
	print("Populating workers screen...")

func _populate_resources_screen() -> void:
	if not resources_screen:
		return
	print("Populating resources screen...")

func _populate_prestige_screen() -> void:
	if not prestige_screen:
		return
	print("Populating prestige screen...")

func _populate_quests_screen() -> void:
	if not quests_screen:
		return
	print("Populating quests screen...")

func _on_pause_pressed() -> void:
	pause_toggled.emit(true)
	if game_manager and game_manager.game_state.is_pauseable():
		game_manager.game_state.transition_to(5)  # GameState.State.PAUSED

func _on_speed_pressed() -> void:
	var speeds = [1.0, 2.0, 3.0]
	var current_idx = speeds.find(Engine.time_scale)
	var next_idx = (current_idx + 1) % speeds.size()
	Engine.time_scale = speeds[next_idx]
	speed_changed.emit(Engine.time_scale)
	
	if speed_button:
		speed_button.text = "%dx" % int(Engine.time_scale)

func show_offline_rewards(rewards: Dictionary) -> void:
	if offline_screen:
		offline_screen.visible = true
		# Populate reward labels
		var container = offline_screen.get_node("RewardsContainer") as VBoxContainer
		if container:
			for child in container.get_children():
				child.queue_free()
			
			var label = Label.new()
			label.text = "While You Were Away:"
			label.add_theme_font_size_override("font_size", 24)
			container.add_child(label)
			
			if rewards.has("money_earned"):
				label = Label.new()
				label.text = "Money Earned: $%d" % rewards["money_earned"]
				container.add_child(label)
			
			if rewards.has("resources_mined"):
				label = Label.new()
				label.text = "Resources Mined: %d" % rewards["resources_mined"]
				container.add_child(label)
			
			if rewards.has("time_elapsed"):
				var hours = int(rewards["time_elapsed"] / 3600)
				var minutes = int((rewards["time_elapsed"] % 3600) / 60)
				label = Label.new()
				label.text = "Time Elapsed: %dh %dm" % [hours, minutes]
				container.add_child(label)

func hide_offline_rewards() -> void:
	if offline_screen:
		offline_screen.visible = false

func confirm_action(title: String, message: String, on_confirm: Callable) -> void:
	# Show confirmation dialog
	print("Confirm: %s - %s" % [title, message])
	on_confirm.call()

func show_notification(message: String, duration: float = 3.0) -> void:
	print("Notification: %s" % message)
	# In production, show toast/snackbar

func get_rarity_color(rarity: String) -> Color:
	return _get_rarity_color(rarity)
