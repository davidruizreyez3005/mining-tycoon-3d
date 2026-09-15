extends Node3D
class_name Worker

## Individual worker instance with AI behavior
## Handles navigation, task assignment, and state machine

signal task_completed(worker: Worker)
signal stamina_changed(new_stamina: float)
signal state_changed(new_state: String)

enum WorkerState {
IDLE,
MOVING_TO_TASK,
WORKING,
CARRYING,
RETURNING,
REPAIRING,
RESTING
}

# Configuration
@export var worker_id: String = ""
@export var definition: WorkerDefinition
@export var current_depth: int = 0

# State
var state: WorkerState = WorkerState.IDLE
var current_task: Dictionary = {}
var stamina: float = 100.0
var is_busy: bool = false
var assigned_machine: Node3D = null
var carry_amount: int = 0
var target_position: Vector3 = Vector3.ZERO

# Navigation
var navigation_agent: NavigationAgent3D
var path: PackedVector3Array = []
var current_path_index: int = 0

# Timing
var _work_timer: float = 0.0
var _rest_timer: float = 0.0

func _ready() -> void:
    _setup_navigation()
    stamina = definition.max_stamina if definition else 100.0

func _setup_navigation() -> void:
    navigation_agent = NavigationAgent3D.new()
    add_child(navigation_agent)
    navigation_agent.velocity_computed.connect(_on_velocity_computed)

func _process(delta: float) -> void:
    _update_stamina(delta)
    _update_state_machine(delta)
    _follow_path(delta)

func _update_stamina(delta: float) -> void:
    if state == WorkerState.WORKING or state == WorkerState.CARRYING:
        stamina -= definition.stamina_drain_rate * delta
        else:
            stamina += definition.stamina_regen_rate * delta

            stamina = clamp(stamina, 0.0, definition.max_stamina)

            if stamina <= 0 and state != WorkerState.RESTING:
                _start_resting()
                elif stamina >= definition.max_stamina * 0.8 and state == WorkerState.RESTING:
                    _stop_resting()

                    stamina_changed.emit(stamina)

func _update_state_machine(delta: float) -> void:
    match state:
        WorkerState.IDLE:
        _handle_idle_state(delta)
        WorkerState.MOVING_TO_TASK:
        _handle_moving_state(delta)
        WorkerState.WORKING:
        _handle_working_state(delta)
        WorkerState.CARRYING:
        _handle_carrying_state(delta)
        WorkerState.RETURNING:
        _handle_returning_state(delta)
        WorkerState.REPAIRING:
        _handle_repairing_state(delta)
        WorkerState.RESTING:
        _handle_resting_state(delta)

func _handle_idle_state(_delta: float) -> void:
    if current_task.is_empty():
        return  # Stay idle until assigned a task

# Start moving to task location
var target = current_task.get("target_position", Vector3.ZERO)
        move_to(target)

func _handle_moving_state(delta: float) -> void:
    if not is_moving():
    # Arrived at destination
        _start_working()

func _handle_working_state(delta: float) -> void:
    _work_timer += delta

# Simulate work progress
var work_speed = definition.base_efficiency * 2.0  # Units per second
    if _work_timer >= 1.0:
        _work_timer = 0.0
# Emit resource collected signal or update machine
        if current_task.has("output_resource"):
var amount = int(work_speed)
            current_task["progress"] = current_task.get("progress", 0) + amount

# Check if task is complete
            if current_task["progress"] >= current_task.get("target_amount", 999999):
                _complete_task()

func _handle_carrying_state(_delta: float) -> void:
    # Moving while carrying resources
    if not is_moving():
    # Arrived at drop-off point
        _deposit_resources()

func _handle_returning_state(_delta: float) -> void:
    if not is_moving():
    # Back at work station
        state = WorkerState.WORKING
        state_changed.emit("working")

func _handle_repairing_state(delta: float) -> void:
    _work_timer += delta
    if _work_timer >= current_task.get("repair_time", 5.0):
        _complete_repair()

func _handle_resting_state(_delta: float) -> void:
    # Just wait for stamina to regenerate
    pass

func _start_working() -> void:
    state = WorkerState.WORKING
    state_changed.emit("working")
    _work_timer = 0.0

# Play mining animation if character has one
    _play_animation("mine")

func _start_resting() -> void:
    state = WorkerState.RESTING
    state_changed.emit("resting")
    _play_animation("idle")

func _stop_resting() -> void:
    if not current_task.is_empty():
        state = WorkerState.MOVING_TO_TASK
        state_changed.emit("moving_to_task")
        else:
            state = WorkerState.IDLE
            state_changed.emit("idle")

func _complete_task() -> void:
    task_completed.emit(self)

    if current_task.has("deposit_location"):
    # Move to deposit location
        carry_amount = current_task.get("carried_amount", 0)
        state = WorkerState.CARRYING
        state_changed.emit("carrying")
        move_to(current_task["deposit_location"])
        else:
    # Task complete, go idle or get new task
            current_task.clear()
            state = WorkerState.IDLE
            state_changed.emit("idle")

func _deposit_resources() -> void:
    # Deposit carried resources at storage
    if carry_amount > 0 and current_task.has("storage_node"):
var storage = current_task["storage_node"]
        if storage and storage.has_method("add_resource"):
            storage.add_resource(current_task.get("resource_type", "stone"), carry_amount)

            carry_amount = 0
            current_task.clear()
            state = WorkerState.IDLE
            state_changed.emit("idle")

func _complete_repair() -> void:
    if assigned_machine:
        assigned_machine.repair(100)  # Full repair

        current_task.clear()
        state = WorkerState.IDLE
        state_changed.emit("idle")

func assign_task(task: Dictionary) -> void:
    current_task = task
    is_busy = true

    if state == WorkerState.IDLE or state == WorkerState.RESTING:
        state = WorkerState.MOVING_TO_TASK
        state_changed.emit("moving_to_task")

func move_to(target: Vector3) -> void:
    target_position = target
    path = calculate_path_to(target)
    current_path_index = 0

    if navigation_agent:
        navigation_agent.target_position = target

func calculate_path_to(target: Vector3) -> PackedVector3Array:
    # Simple direct path for now - can be enhanced with proper navmesh
    return [global_position, target]

func _follow_path(delta: float) -> void:
    if path.size() < 2:
        return

        if current_path_index >= path.size() - 1:
            return  # Reached destination

var current_target = path[current_path_index + 1]
var direction = (current_target - global_position).normalized()

            if direction.length() > 0.1:
var velocity = direction * definition.movement_speed * delta
                global_position += velocity

# Check if reached waypoint
                if global_position.distance_to(current_target) < 0.5:
                    current_path_index += 1

func _on_velocity_computed(safe_velocity: Vector3) -> void:
    # Use safe velocity for collision avoidance
    pass

func is_moving() -> bool:
    return current_path_index < path.size() - 1

func _play_animation(anim_name: String) -> void:
    # Placeholder for animation playback
# In production, this would trigger AnimationPlayer
    pass

func get_current_state() -> String:
    return WorkerState.keys()[state]

func is_available() -> bool:
    return state == WorkerState.IDLE and stamina > 20.0

func cancel_task() -> void:
    current_task.clear()
    is_busy = false
    state = WorkerState.IDLE
    state_changed.emit("idle")