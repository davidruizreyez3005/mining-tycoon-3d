extends Node

enum GameState {
	BOOT,
	MAIN_MENU,
	LOADING,
	PLAYING,
	PAUSED,
	SHOP,
	INVENTORY,
	PRODUCTION,
	QUESTS,
	TECHNOLOGY,
	SETTINGS,
	OFFLINE_SUMMARY,
	PRESTIGE,
	SAVE,
	ERROR
}

var current_state: GameState = GameState.BOOT
var previous_state: GameState = GameState.BOOT

signal state_changed(from_state: GameState, to_state: GameState)

func _ready() -> void:
	transition_to(GameState.BOOT)

func transition_to(new_state: GameState) -> void:
	if current_state == new_state:
		return
	
	previous_state = current_state
	current_state = new_state
	state_changed.emit(previous_state, current_state)
	
	print("GameState: %s -> %s" % [GameState.keys()[previous_state], GameState.keys()[current_state]])

func get_current_state() -> GameState:
	return current_state

func is_playing() -> bool:
	return current_state == GameState.PLAYING

func is_paused() -> bool:
	return current_state == GameState.PAUSED

func is_in_menu() -> bool:
	return current_state in [GameState.MAIN_MENU, GameState.SHOP, GameState.INVENTORY, 
		GameState.PRODUCTION, GameState.QUESTS, GameState.TECHNOLOGY, GameState.SETTINGS]
