extends Node

signal volume_changed(bus: String, volume: float)

var sfx_enabled: bool = true
var music_enabled: bool = true
var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0

func _ready() -> void:
_configure_audio_buses()

func _configure_audio_buses() -> void:
var master_bus = AudioServer.get_bus_index("Master")
if master_bus >= 0:
AudioServer.set_bus_mute(master_bus, false)
AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))

func play_sfx(sound_name: String, position: Vector3 = Vector3.ZERO) -> void:
if not sfx_enabled:
return

print("AudioManager: Playing SFX: %s" % sound_name)

func play_music(track_name: String, fade_in: float = 1.0) -> void:
if not music_enabled:
return

print("AudioManager: Playing music: %s" % track_name)

func stop_music(fade_out: float = 1.0) -> void:
print("AudioManager: Stopping music")

func set_master_volume(volume: float) -> void:
master_volume = clamp(volume, 0.0, 1.0)
var master_bus = AudioServer.get_bus_index("Master")
if master_bus >= 0:
AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))
volume_changed.emit("master", master_volume)

func set_music_volume(volume: float) -> void:
music_volume = clamp(volume, 0.0, 1.0)
volume_changed.emit("music", music_volume)

func set_sfx_volume(volume: float) -> void:
sfx_volume = clamp(volume, 0.0, 1.0)
volume_changed.emit("sfx", sfx_volume)

func toggle_sfx(enabled: bool) -> void:
sfx_enabled = enabled

func toggle_music(enabled: bool) -> void:
music_enabled = enabled

func get_master_volume() -> float:
return master_volume

func get_music_volume() -> float:
return music_volume

func get_sfx_volume() -> float:
return sfx_volume
