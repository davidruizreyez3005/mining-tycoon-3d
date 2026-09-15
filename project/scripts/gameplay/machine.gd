extends Node3D
class_name Machine

## Base class for all mining machinery
## Handles operation, upgrades, maintenance, and resource processing

signal machine_started(machine: Machine)
signal machine_stopped(machine: Machine)
signal resource_processed(resource_id: String, amount: int)
signal upgrade_completed(machine: Machine, level: int)
signal repair_completed(machine: Machine)
signal broken_changed(is_broken: bool)

enum MachineType {
    EXTRACTOR,      # Mines resources from nodes
    PROCESSOR,      # Processes raw resources
    CONVEYOR,       # Transports resources
    STORAGE,        # Stores resources
    ELEVATOR,       # Moves between depths
    PUMP,           # Removes water/gas
    GENERATOR       # Provides power
}

enum MachineState {
    IDLE,
    RUNNING,
    BROKEN,
    NO_POWER,
    NO_INPUT,
    FULL_OUTPUT,
    UPGRADING,
    REPAIRING
}

# Configuration
@export var machine_id: String = ""
@export var machine_type: MachineType = MachineType.EXTRACTOR
@export var tier: int = 1
@export var max_tier: int = 5

# Operational parameters
@export var base_speed: float = 1.0  # Operations per second
@export var power_consumption: int = 10
@export var input_capacity: int = 100
@export var output_capacity: int = 50
@export var durability: float = 100.0
@export var max_durability: float = 100.0
@export var durability_drain_rate: float = 0.1  # Per operation

# Resources
@export var input_resource: String = ""
@export var output_resource: String = "stone"
@export var output_per_operation: int = 1

# Upgrade costs
@export var base_upgrade_cost: int = 100
@export var cost_multiplier: float = 1.5

# State
var current_state: MachineState = MachineState.IDLE
var current_level: int = 1
var current_durability: float = 100.0
var is_operational: bool = true
var has_power: bool = true
var input_buffer: Dictionary = {}
var output_buffer: Dictionary = {}
var operation_timer: float = 0.0
var assigned_workers: Array = []

# Derived values (calculated from base stats + upgrades)
var effective_speed: float = 1.0
var effective_output: int = 1
var effective_power: int = 10

func _ready() -> void:
    _calculate_effective_stats()

func _process(delta: float) -> void:
    if not is_operational:
        return
    
    if current_state == MachineState.RUNNING:
        _process_operation(delta)
    
    # Durability drain while running
    if current_state == MachineState.RUNNING and durability_drain_rate > 0:
        current_durability -= durability_drain_rate * delta
        if current_durability <= 0:
            _break_machine()

func _calculate_effective_stats() -> void:
    # Apply level bonuses
    var level_mult = 1.0 + (current_level - 1) * 0.2  # 20% per level
    effective_speed = base_speed * level_mult
    effective_output = int(output_per_operation * level_mult)
    effective_power = int(power_consumption * level_mult)

func _process_operation(delta: float) -> void:
    operation_timer += delta
    
    var operation_time = 1.0 / effective_speed
    if operation_timer >= operation_time:
        operation_timer = 0.0
        _perform_operation()

func _perform_operation() -> void:
    match machine_type:
        MachineType.EXTRACTOR:
            _extract_resource()
        MachineType.PROCESSOR:
            _process_resource()
        MachineType.CONVEYOR:
            _transport_resource()
        MachineType.STORAGE:
            _store_resource()
        _:
            pass

func _extract_resource() -> void:
    # Extractor machines produce resources directly
    if output_buffer.size() >= output_capacity:
        current_state = MachineState.FULL_OUTPUT
        return
    
    add_to_output_buffer(output_resource, effective_output)
    resource_processed.emit(output_resource, effective_output)

func _process_resource() -> void:
    # Processor machines convert input to output
    if input_resource.is_empty():
        current_state = MachineState.NO_INPUT
        return
    
    if not has_input_resource(input_resource, effective_output):
        current_state = MachineState.NO_INPUT
        return
    
    remove_from_input_buffer(input_resource, effective_output)
    add_to_output_buffer(output_resource, effective_output)
    resource_processed.emit(output_resource, effective_output)

func _transport_resource() -> void:
    # Conveyor moves resources between points
    # Implementation depends on connected machines
    pass

func _store_resource() -> void:
    # Storage accumulates resources
    pass

func add_to_input_buffer(resource_id: String, amount: int) -> void:
    if not input_buffer.has(resource_id):
        input_buffer[resource_id] = 0
    input_buffer[resource_id] += amount

func remove_from_input_buffer(resource_id: String, amount: int) -> bool:
    if not has_input_resource(resource_id, amount):
        return false
    input_buffer[resource_id] -= amount
    if input_buffer[resource_id] <= 0:
        input_buffer.erase(resource_id)
    return true

func has_input_resource(resource_id: String, amount: int) -> bool:
    return input_buffer.get(resource_id, 0) >= amount

func add_to_output_buffer(resource_id: String, amount: int) -> void:
    if not output_buffer.has(resource_id):
        output_buffer[resource_id] = 0
    output_buffer[resource_id] += amount

func remove_from_output_buffer(resource_id: String, amount: int) -> bool:
    if not output_buffer.has(resource_id) or output_buffer[resource_id] < amount:
        return false
    output_buffer[resource_id] -= amount
    if output_buffer[resource_id] <= 0:
        output_buffer.erase(resource_id)
    return true

func get_output_amount(resource_id: String) -> int:
    return output_buffer.get(resource_id, 0)

func can_accept_input(resource_id: String, amount: int) -> bool:
    var current_total = 0
    for r in input_buffer.values():
        current_total += r
    return current_total + amount <= input_capacity

func start() -> void:
    if current_state == MachineState.BROKEN or current_state == MachineState.UPGRADING:
        return
    
    if not has_power:
        current_state = MachineState.NO_POWER
        return
    
    current_state = MachineState.RUNNING
    is_operational = true
    machine_started.emit(self)

func stop() -> void:
    if current_state == MachineState.RUNNING:
        current_state = MachineState.IDLE
        machine_stopped.emit(self)

func _break_machine() -> void:
    current_state = MachineState.BROKEN
    is_operational = false
    broken_changed.emit(true)
    print("Machine %s broke down!" % machine_id)

func repair(amount: float = 100.0) -> void:
    if current_state != MachineState.BROKEN:
        return
    
    current_durability = min(max_durability, current_durability + amount)
    
    if current_durability >= max_durability:
        current_state = MachineState.IDLE
        is_operational = true
        broken_changed.emit(false)
        repair_completed.emit(self)
        print("Machine %s repaired!" % machine_id)

func upgrade() -> bool:
    if current_level >= max_tier:
        return false
    
    var cost = get_upgrade_cost()
    # Cost check should be done by caller
    
    current_level += 1
    current_state = MachineState.UPGRADING
    is_operational = false
    
    # Simulate upgrade time (would be longer in actual game)
    await get_tree().create_timer(2.0).timeout
    
    _calculate_effective_stats()
    current_state = MachineState.IDLE
    is_operational = true
    
    # Restore durability on upgrade
    current_durability = max_durability
    
    upgrade_completed.emit(self, current_level)
    print("Machine %s upgraded to level %d!" % [machine_id, current_level])
    
    return true

func get_upgrade_cost() -> int:
    return int(base_upgrade_cost * pow(cost_multiplier, current_level - 1))

func get_repair_cost() -> int:
    var missing = max_durability - current_durability
    return int(missing * 0.5)  # 0.5 currency per durability point

func assign_worker(worker: Node3D) -> void:
    if worker not in assigned_workers:
        assigned_workers.append(worker)
        # Worker efficiency bonus
        var efficiency_bonus = 1.0 + (assigned_workers.size() * 0.1)
        effective_speed = base_speed * (1.0 + (current_level - 1) * 0.2) * efficiency_bonus

func remove_worker(worker: Node3D) -> void:
    assigned_workers.erase(worker)
    _recalculate_efficiency()

func _recalculate_efficiency() -> void:
    var efficiency_bonus = 1.0 + (assigned_workers.size() * 0.1)
    effective_speed = base_speed * (1.0 + (current_level - 1) * 0.2) * efficiency_bonus

func set_power(enabled: bool) -> void:
    has_power = enabled
    if not enabled and current_state == MachineState.RUNNING:
        current_state = MachineState.NO_POWER
    elif enabled and current_state == MachineState.NO_POWER:
        current_state = MachineState.IDLE

func get_machine_info() -> Dictionary:
    return {
        "id": machine_id,
        "type": MachineType.keys()[machine_type],
        "tier": tier,
        "level": current_level,
        "state": MachineState.keys()[current_state],
        "durability": current_durability / max_durability,
        "speed": effective_speed,
        "output": effective_output,
        "power": effective_power,
        "input_buffer": input_buffer.duplicate(),
        "output_buffer": output_buffer.duplicate()
    }

func save_state() -> Dictionary:
    return {
        "machine_id": machine_id,
        "machine_type": machine_type,
        "tier": tier,
        "level": current_level,
        "durability": current_durability,
        "input_buffer": input_buffer.duplicate(),
        "output_buffer": output_buffer.duplicate()
    }

func load_state(data: Dictionary) -> void:
    if data.has("machine_id"):
        machine_id = data["machine_id"]
    if data.has("machine_type"):
        machine_type = data["machine_type"]
    if data.has("tier"):
        tier = data["tier"]
    if data.has("level"):
        current_level = data["level"]
    if data.has("durability"):
        current_durability = data["durability"]
    if data.has("input_buffer"):
        input_buffer = data["input_buffer"].duplicate()
    if data.has("output_buffer"):
        output_buffer = data["output_buffer"].duplicate()
    
    _calculate_effective_stats()
