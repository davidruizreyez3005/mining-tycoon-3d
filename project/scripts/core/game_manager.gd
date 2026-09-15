extends Node

signal game_initialized
signal save_loaded
signal save_failed(reason: String)

const SAVE_VERSION: int = 1
const SAVE_FILE_PATH: String = "user://savegame.dat"

var player_data: Dictionary = {}
var economy_data: Dictionary = {}
var world_data: Dictionary = {}
var unlock_data: Dictionary = {}
var settings_data: Dictionary = {}
var statistics_data: Dictionary = {}

func _ready() -> void:
	_initialize_default_data()

func _initialize_default_data() -> void:
	player_data = {
		"name": "Miner",
		"money": 100.0,
		"prestige_currency": 0.0,
		"prestige_count": 0,
		"unlock_depth": 0,
		"tutorial_completed": false
	}
	
	economy_data = {
		"total_earned": 0.0,
		"total_spent": 0.0,
		"resources_mined": {},
		"resources_processed": {},
		"resources_sold": {}
	}
	
	world_data = {
		"active_machines": [],
		"active_workers": [],
		"built_structures": [],
		"discovered_resources": []
	}
	
	unlock_data = {
		"technologies": [],
		"upgrades": [],
		"quests_completed": [],
		"achievements_unlocked": []
	}
	
	settings_data = {
		"master_volume": 1.0,
		"music_volume": 1.0,
		"sfx_volume": 1.0,
		"graphics_quality": 1
	}
	
	statistics_data = {
		"play_time": 0,
		"total_mining_operations": 0,
		"total_resources_collected": 0,
		"peak_production": 0.0
	}

func save_game() -> bool:
	var save_dict = {
		"version": SAVE_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"player": player_data.duplicate(true),
		"economy": economy_data.duplicate(true),
		"world": world_data.duplicate(true),
		"unlocks": unlock_data.duplicate(true),
		"settings": settings_data.duplicate(true),
		"statistics": statistics_data.duplicate(true)
	}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if not file:
		save_failed.emit("Failed to open save file for writing")
		return false
	
	file.store_var(save_dict)
	file.close()
	
	print("Game saved successfully")
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file found, starting new game")
		_initialize_default_data()
		return true
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		save_failed.emit("Failed to open save file for reading")
		return false
	
	var save_dict = file.get_var()
	file.close()
	
	if not save_dict is Dictionary:
		save_failed.emit("Invalid save file format")
		return false
	
	if not save_dict.has("version"):
		save_failed.emit("Save file missing version")
		return false
	
	var save_version = save_dict["version"]
	if save_version > SAVE_VERSION:
		save_failed.emit("Save file version %d is newer than supported version %d" % [save_version, SAVE_VERSION])
		return false
	
	# Migrate older save versions if needed
	if save_version < SAVE_VERSION:
		save_dict = _migrate_save(save_dict, save_version)
	
	player_data = save_dict.get("player", player_data)
	economy_data = save_dict.get("economy", economy_data)
	world_data = save_dict.get("world", world_data)
	unlock_data = save_dict.get("unlocks", unlock_data)
	settings_data = save_dict.get("settings", settings_data)
	statistics_data = save_dict.get("statistics", statistics_data)
	
	save_loaded.emit()
	print("Game loaded successfully from version %d" % [save_version])
	return true

func _migrate_save(save_dict: Dictionary, old_version: int) -> Dictionary:
	# Add migration logic here for future versions
	print("Migrating save from version %d to %d" % [old_version, SAVE_VERSION])
	return save_dict

func get_player_data() -> Dictionary:
	return player_data

func get_economy_data() -> Dictionary:
	return economy_data

func get_world_data() -> Dictionary:
	return world_data

func get_unlock_data() -> Dictionary:
	return unlock_data

func get_settings_data() -> Dictionary:
	return settings_data

func add_money(amount: float) -> void:
	player_data["money"] = max(0.0, player_data["money"] + amount)
	if amount > 0:
		economy_data["total_earned"] += amount
	else:
		economy_data["total_spent"] += abs(amount)

func get_money() -> float:
	return player_data["money"]

func can_afford(cost: float) -> bool:
	return player_data["money"] >= cost

func spend_money(cost: float) -> bool:
	if can_afford(cost):
		add_money(-cost)
		return true
	return false

func add_prestige_currency(amount: float) -> void:
	player_data["prestige_currency"] += amount

func get_prestige_currency() -> float:
	return player_data["prestige_currency"]
