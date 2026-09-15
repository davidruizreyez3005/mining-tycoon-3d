extends Node
class_name AudioManager

## Central audio management system
## Handles SFX, music, and ambient sounds

signal music_changed(track_name: String)
signal sfx_played(sfx_name: String)

# Audio buses
const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const AMBIENCE_BUS := "Ambience"

# Configuration
@export var master_volume: float = 1.0
@export var music_volume: float = 0.7
@export var sfx_volume: float = 0.8
@export var ambience_volume: float = 0.5

# Audio players
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var ambience_players: Array[AudioStreamPlayer] = []

# Pool for SFX (reuse players)
const MAX_SFX_PLAYERS := 16
var _sfx_pool_index: int = 0

# Current state
var current_music_track: String = ""
var is_muted: bool = false

func _ready() -> void:
	_setup_audio_players()
	_setup_audio_buses()

func _setup_audio_players() -> void:
	# Music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = MUSIC_BUS
	add_child(music_player)
	
	# SFX pool
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		sfx_players.append(player)
	
	# Ambience players (for layering)
	for i in range(4):
		var player = AudioStreamPlayer.new()
		player.bus = AMBIENCE_BUS
		player.autoplay = false
		add_child(player)
		ambience_players.append(player)

func _setup_audio_buses() -> void:
	# Set initial volumes
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS), linear_to_db(sfx_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(AMBIENCE_BUS), linear_to_db(ambience_volume))

func play_music(track_path: String, fade_in: float = 1.0) -> void:
	if track_path.is_empty():
		stop_music()
		return
	
	current_music_track = track_path
	
	# In production, load actual music tracks
	# var stream = load(track_path) as AudioStream
	# music_player.stream = stream
	
	if not music_player.playing:
		music_player.play()
	
	music_changed.emit(track_path)
	print("Playing music: %s" % track_path)

func stop_music(fade_out: float = 1.0) -> void:
	if music_player.playing:
		music_player.stop()
	
	current_music_track = ""
	music_changed.emit("")

func play_sfx(sfx_path: String, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	# Get next available SFX player from pool
	var player = sfx_players[_sfx_pool_index]
	_sfx_pool_index = (_sfx_pool_index + 1) % MAX_SFX_PLAYERS
	
	# Stop any currently playing sound on this player
	if player.playing:
		player.stop()
	
	# In production, load actual SFX
	# var stream = load(sfx_path) as AudioStream
	# player.stream = stream
	
	player.volume_db = volume_db
	player.pitch_scale = pitch
	
	if not player.playing:
		player.play()
	
	sfx_played.emit(sfx_path)

func play_ambience(ambience_path: String, slot: int = 0, fade_in: float = 2.0) -> void:
	if slot < 0 or slot >= ambience_players.size():
		return
	
	var player = ambience_players[slot]
	
	# In production, load actual ambience
	# var stream = load(ambience_path) as AudioStream
	# player.stream = stream
	
	if not player.playing:
		player.play()
	
	print("Playing ambience slot %d: %s" % [slot, ambience_path])

func stop_ambience(slot: int = -1, fade_out: float = 2.0) -> void:
	if slot < 0:
		# Stop all ambience
		for player in ambience_players:
			if player.playing:
				player.stop()
	else:
		var player = ambience_players[slot]
		if player.playing:
			player.stop()

func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))

func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), linear_to_db(music_volume))

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS), linear_to_db(sfx_volume))

func set_ambience_volume(volume: float) -> void:
	ambience_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(AMBIENCE_BUS), linear_to_db(ambience_volume))

func mute_all(mute: bool) -> void:
	is_muted = mute
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), mute)

func toggle_mute() -> void:
	mute_all(not is_muted)

# Predefined SFX helpers
func play_mining_sound() -> void:
	play_sfx("res://assets/audio/sfx/mining_hit.wav", -5.0, 0.9 + randf() * 0.2)

func play_drill_sound() -> void:
	play_sfx("res://assets/audio/sfx/drill_loop.wav", -8.0, 1.0)

func play_conveyor_sound() -> void:
	play_ambience("res://assets/audio/ambience/conveyor_hum.wav", 0)

func play_discovery_sound() -> void:
	play_sfx("res://assets/audio/sfx/discovery_chime.wav", -3.0, 1.0)

func play_upgrade_sound() -> void:
	play_sfx("res://assets/audio/sfx/upgrade_complete.wav", -5.0, 1.0)

func play_ui_click() -> void:
	play_sfx("res://assets/audio/sfx/ui_click.wav", -10.0, 1.0)

func get_current_music() -> String:
	return current_music_track

func is_playing_music() -> bool:
	return music_player.playing

func save_state() -> Dictionary:
	return {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"ambience_volume": ambience_volume,
		"is_muted": is_muted,
		"current_music": current_music_track
	}

func load_state(data: Dictionary) -> void:
	if data.has("master_volume"):
		set_master_volume(data["master_volume"])
	if data.has("music_volume"):
		set_music_volume(data["music_volume"])
	if data.has("sfx_volume"):
		set_sfx_volume(data["sfx_volume"])
	if data.has("ambience_volume"):
		set_ambience_volume(data["ambience_volume"])
	if data.has("is_muted"):
		mute_all(data["is_muted"])
