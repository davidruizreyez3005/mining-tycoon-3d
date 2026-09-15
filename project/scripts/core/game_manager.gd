extends Node
class_name GameManager

## Central game manager - coordinates all major systems
## Singleton accessible via GameManager instance

signal game_initialized
signal save_completed(success: bool)
signal load_completed(success: bool)

# Core systems
var game_state: GameState
var economy: RefCounted
var player_data: Dictionary
var world_data: Dictionary

# Configuration
const SAVE_FILE_PATH := "user://savegame.dat"
const SAVE_VERSION := 1

# Timing
var _last_save_time: int = 0
const AUTO_SAVE_INTERVAL := 30.0  # seconds
var _auto_save_timer: float = 0.0

func _ready() -> void:
    _initialize_core_systems()
    game_initialized.emit()

func _initialize_core_systems() -> void:
    game_state = GameState.new()
    economy = load_script("res://scripts/systems/economy_system.gd").new()
    player_data = _create_default_player_data()
    world_data = _create_default_world_data()
    _last_save_time = Time.get_unix_time_from_system()

func _create_default_player_data() -> Dictionary:
    return {
    "money": 100,
    "total_earned": 0,
    "total_mined": 0,
    "prestige_count": 0,
    "prestige_currency": 0,
    "unlock_progress": {},
    "achievements": [],
    "quest_progress": {},
    "settings": {
    "music_volume": 0.7,
    "sfx_volume": 0.8,
    "camera_speed": 1.0,
    "touch_sensitivity": 1.0
    }
    }

func _create_default_world_data() -> Dictionary:
    return {
    "current_depth": 0,
    "max_depth_unlocked": 0,
    "discovered_resources": ["stone"],
    "machines": [],
    "workers": [],
    "buildings": [],
    "expansion_zones": []
    }

func _process(delta: float) -> void:
    _auto_save_timer += delta
    if _auto_save_timer >= AUTO_SAVE_INTERVAL:
        _auto_save_timer = 0.0
        if game_state.is_in_gameplay():
            await save_game()

func start_new_game() -> void:
    print("Starting new game...")
    player_data = _create_default_player_data()
    world_data = _create_default_world_data()
    economy.initialize(player_data, world_data)
    game_state.transition_to(GameState.State.LOADING)
# Simulate loading then start playing
    await get_tree().create_timer(0.5).timeout
    game_state.transition_to(GameState.State.PLAYING)

func save_game() -> Error:
var save_data = _compile_save_data()
var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
    if not file:
        push_error("Failed to open save file for writing")
        save_completed.emit(false)
        return ERR_CANT_CREATE

var json_string = JSON.stringify(save_data, "\t")
        file.store_string(json_string)
        file.close()

        _last_save_time = Time.get_unix_time_from_system()
        print("Game saved successfully")
        save_completed.emit(true)
        return OK

func load_game() -> Error:
    if not FileAccess.file_exists(SAVE_FILE_PATH):
        print("No save file found")
        return ERR_FILE_NOT_FOUND

var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
        if not file:
            push_error("Failed to open save file for reading")
            load_completed.emit(false)
            return ERR_CANT_OPEN

var json_string = file.get_as_text()
            file.close()

var json = JSON.new()
var error = json.parse(json_string)
            if error != OK:
                push_error("Failed to parse save data: %s" % json.get_error_message())
                load_completed.emit(false)
                return error

var save_data = json.data
var migration_result = _migrate_save_data(save_data)
                if migration_result != OK:
                    return migration_result

                    _apply_save_data(save_data)
                    print("Game loaded successfully")
                    load_completed.emit(true)
                    return OK

func _compile_save_data() -> Dictionary:
    return {
    "version": SAVE_VERSION,
    "timestamp": Time.get_unix_time_from_system(),
    "player": player_data.duplicate(true),
    "world": world_data.duplicate(true),
    "economy": economy.save_state(),
    "game_state": game_state.save_state()
    }

func _apply_save_data(data: Dictionary) -> void:
    if data.has("player"):
        player_data.merge(data["player"], true)
        if data.has("world"):
            world_data.merge(data["world"], true)
            if data.has("economy"):
                economy.load_state(data["economy"])
                if data.has("game_state"):
                    game_state.load_state(data["game_state"])

func _migrate_save_data(data: Dictionary) -> Error:
var version = data.get("version", 0)
    if version > SAVE_VERSION:
        push_error("Save version %d is newer than current version %d" % [version, SAVE_VERSION])
        return ERR_INVALID_DATA

# Migration logic for older versions would go here
# For now, just ensure version is set correctly
        data["version"] = SAVE_VERSION
        return OK

func has_save() -> bool:
    return FileAccess.file_exists(SAVE_FILE_PATH)

func delete_save() -> bool:
    if has_save():
var dir = DirAccess.open("user://")
        if dir:
            dir.remove(SAVE_FILE_PATH)
            print("Save file deleted")
            return true
            return false

func get_player_data() -> Dictionary:
    return player_data

func get_world_data() -> Dictionary:
    return world_data

func add_money(amount: int) -> void:
    player_data["money"] += amount
    player_data["total_earned"] += amount

func spend_money(amount: int) -> bool:
    if player_data["money"] >= amount:
        player_data["money"] -= amount
        return true
        return false

func add_prestige_currency(amount: int) -> void:
    player_data["prestige_currency"] += amount