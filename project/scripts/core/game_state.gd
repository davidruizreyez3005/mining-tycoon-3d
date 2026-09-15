extends RefCounted
class_name GameState

## Centralized game state management system
## Controls all major state transitions with validation

enum State {
BOOT,
MENU,
LOADING,
PLAYING,
PAUSED,
UPGRADING,
PROCESSING,
OFFLINE_REWARD,
PRESTIGE,
SETTINGS,
TUTORIAL,
DISCOVERY,
QUEST,
ERROR
}

var current_state: State = State.BOOT
var previous_state: State = State.BOOT
var state_history: Array[State] = []

# Valid transitions from each state
const VALID_TRANSITIONS := {
State.BOOT: [State.LOADING, State.ERROR],
State.MENU: [State.LOADING, State.ERROR],
State.LOADING: [State.PLAYING, State.MENU, State.ERROR],
State.PLAYING: [State.PAUSED, State.UPGRADING, State.PROCESSING, State.OFFLINE_REWARD, State.PRESTIGE, State.MENU, State.ERROR, State.SETTINGS, State.TUTORIAL, State.DISCOVERY, State.QUEST],
State.PAUSED: [State.PLAYING, State.MENU, State.ERROR, State.SETTINGS],
State.UPGRADING: [State.PLAYING, State.PAUSED, State.ERROR],
State.PROCESSING: [State.PLAYING, State.PAUSED, State.ERROR],
State.OFFLINE_REWARD: [State.PLAYING, State.ERROR],
State.PRESTIGE: [State.PLAYING, State.ERROR],
State.SETTINGS: [State.PLAYING, State.PAUSED, State.MENU, State.ERROR],
State.TUTORIAL: [State.PLAYING, State.PAUSED, State.ERROR],
State.DISCOVERY: [State.PLAYING, State.PAUSED, State.ERROR],
State.QUEST: [State.PLAYING, State.PAUSED, State.ERROR],
State.ERROR: [State.BOOT, State.MENU]
}

signal state_changed(from_state: State, to_state: State)

func _init() -> void:
    state_history.append(current_state)

func get_state_name(state: State) -> String:
    return State.keys()[state]

func can_transition_to(target: State) -> bool:
var valid_targets = VALID_TRANSITIONS.get(current_state, [])
    return target in valid_targets

func transition_to(target: State) -> bool:
    if not can_transition_to(target):
        push_warning("Invalid state transition: %s -> %s" % [get_state_name(current_state), get_state_name(target)])
        return false

        previous_state = current_state
        current_state = target
        state_history.append(target)

        print("State transition: %s -> %s" % [get_state_name(previous_state), get_state_name(current_state)])
        state_changed.emit(previous_state, current_state)
        return true

func is_in_gameplay() -> bool:
    return current_state in [State.PLAYING, State.UPGRADING, State.PROCESSING, State.TUTORIAL, State.DISCOVERY, State.QUEST]

func is_pauseable() -> bool:
    return current_state == State.PLAYING

func save_state() -> Dictionary:
    return {
    "current_state": get_state_name(current_state),
    "previous_state": get_state_name(previous_state),
    "history_size": state_history.size()
    }

func load_state(data: Dictionary) -> void:
    if data.has("current_state"):
var state_name = data["current_state"]
var idx = State.keys().find(state_name)
        if idx >= 0:
            current_state = idx