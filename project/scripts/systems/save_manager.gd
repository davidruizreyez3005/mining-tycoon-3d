extends Node

signal save_completed(success: bool)
signal load_completed(success: bool)

const SAVE_FILE_PATH: String = "user://mining_tycoon_save.dat"
const BACKUP_FILE_PATH: String = "user://mining_tycoon_save_backup.dat"
const MAX_BACKUPS: int = 3

func _ready() -> void:
pass

func save_game() -> bool:
var save_data = {
"version": 1,
"timestamp": Time.get_unix_time_from_system(),
"player": GameManager.get_player_data(),
"economy": EconomySystem.get_all_resources(),
"workers": WorkerManager.get_all_workers(),
"machines": MachineManager.get_all_machines()
}

if not _write_save_file(SAVE_FILE_PATH, save_data):
return false

_create_backup()
save_completed.emit(true)
return true

func _write_save_file(path: String, data: Dictionary) -> bool:
var file = FileAccess.open(path, FileAccess.WRITE)
if not file:
print("SaveManager: Failed to open file for writing: %s" % path)
return false

file.store_var(data)
file.close()
return true

func _create_backup() -> void:
if FileAccess.file_exists(SAVE_FILE_PATH):
DirAccess.remove_absolute(BACKUP_FILE_PATH)
DirAccess.copy_absolute(SAVE_FILE_PATH, BACKUP_FILE_PATH)

func load_game() -> bool:
if not FileAccess.file_exists(SAVE_FILE_PATH):
print("SaveManager: No save file found")
load_completed.emit(false)
return false

var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
if not file:
print("SaveManager: Failed to open save file")
load_completed.emit(false)
return false

var save_data = file.get_var()
file.close()

if not save_data is Dictionary:
print("SaveManager: Invalid save data format")
load_completed.emit(false)
return false

if not save_data.has("version"):
print("SaveManager: Save missing version")
load_completed.emit(false)
return false

_apply_save_data(save_data)
load_completed.emit(true)
return true

func _apply_save_data(data: Dictionary) -> void:
if data.has("player"):
var player_data = data["player"]
for key in player_data:
GameManager.player_data[key] = player_data[key]

if data.has("economy"):
var econ_data = data["economy"]
for resource_id in econ_data:
EconomySystem.resources[resource_id] = econ_data[resource_id]

print("SaveManager: Game loaded successfully")

func has_save() -> bool:
return FileAccess.file_exists(SAVE_FILE_PATH)

func delete_save() -> bool:
if FileAccess.file_exists(SAVE_FILE_PATH):
DirAccess.remove_absolute(SAVE_FILE_PATH)
if FileAccess.file_exists(BACKUP_FILE_PATH):
DirAccess.remove_absolute(BACKUP_FILE_PATH)
return true

func get_save_timestamp() -> int:
if not FileAccess.file_exists(SAVE_FILE_PATH):
return 0

var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
if not file:
return 0

var data = file.get_var()
file.close()

return data.get("timestamp", 0)
