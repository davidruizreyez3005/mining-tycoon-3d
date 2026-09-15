extends RefCounted
class_name GameState

enum State { BOOT, MAIN_MENU, LOADING, PLAYING, PAUSED, SAVE }

var current: State = State.BOOT

func transition_to(new_state: State) -> bool:
    current = new_state
    return true

func get_state_name() -> String:
    return State.keys()[current]
