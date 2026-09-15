extends Node3D
class_name VFXManager

## Visual effects management system
## Handles particles, emissive effects, and environmental VFX

signal vfx_played(vfx_name: String)

# Particle systems cache
var _particle_pools: Dictionary = {}
var _active_effects: Array[Dictionary] = []

# Configuration
@export var max_particles: int = 10000
@export var default_lod_distance: float = 50.0

# Preload common particle scenes (in production these would be actual .tscn files)
const VFX_PATHS := {
"dust_cloud": "res://assets/vfx/dust_cloud.tscn",
"rock_fragments": "res://assets/vfx/rock_fragments.tscn",
"sparks": "res://assets/vfx/sparks.tscn",
"smoke": "res://assets/vfx/smoke.tscn",
"steam": "res://assets/vfx/steam.tscn",
"glow_mineral": "res://assets/vfx/glow_mineral.tscn",
"discovery_burst": "res://assets/vfx/discovery_burst.tscn",
"drill_dust": "res://assets/vfx/drill_dust.tscn",
"conveyor_dust": "res://assets/vfx/conveyor_dust.tscn",
"explosion": "res://assets/vfx/explosion.tscn"
}

func _ready() -> void:
    _initialize_particle_pools()

func _initialize_particle_pools() -> void:
    # Create particle pools for each effect type
for vfx_key in VFX_PATHS.keys():
    _particle_pools[vfx_key] = []

# In production, would preload actual scenes
# For now, we'll create GPUParticles3D nodes programmatically

for i in range(8):  # Pool size per effect type
    var particles = _create_generic_particles()
particles.emitting = false
add_child(particles)
_particle_pools[vfx_key].append(particles)

func _create_generic_particles() -> GPUParticles3D:
    var particles = GPUParticles3D.new()

# Basic configuration
particles.amount = 64
particles.lifetime = 2.0
particles.one_shot = false
particles.explosiveness = 0.0
particles.randomness = 0.2

# Default material
var material = ParticleProcessMaterial.new()
material.direction = Vector3(0, 1, 0)
material.spread = 45.0
material.initial_velocity_min = 2.0
material.initial_velocity_max = 5.0
material.gravity = Vector3(0, -9.8, 0)

particles.process_material = material
return particles

func play_vfx(vfx_name: String, position: Vector3, scale: float = 1.0, color: Color = Color.WHITE) -> void:
    if not VFX_PATHS.has(vfx_name):
        push_warning("VFX not found: %s" % vfx_name)
return

var pool = _particle_pools.get(vfx_name, [])
if pool.is_empty():
    return

# Find available particle system
var particles: GPUParticles3D = null
for p in pool:
    if not p.emitting:
        particles = p
break

if not particles:
    # All instances in use, skip this effect (LOD/culling)
return

# Configure and play
particles.global_position = position
particles.scale = Vector3.ONE * scale

# Apply color if the material supports it
var material = particles.process_material as ParticleProcessMaterial
if material:
    material.color = color

particles.restart()
particles.emitting = true

_active_effects.append({
"vfx": vfx_name,
"particles": particles,
"start_time": Time.get_unix_time_from_system(),
"position": position
})

vfx_played.emit(vfx_name)

func stop_vfx_at(position: Vector3, radius: float = 5.0) -> void:
    for effect in _active_effects:
        var particles = effect.get("particles") as GPUParticles3D
if particles and particles.global_position.distance_to(position) <= radius:
    particles.emitting = false

func stop_all_vfx() -> void:
    for pool in _particle_pools.values():
        for particles in pool:
            particles.emitting = false
_active_effects.clear()

func set_vfx_enabled(enabled: bool) -> void:
    for pool in _particle_pools.values():
        for particles in pool:
            particles.process_material = particles.process_material if enabled else null

# Specific VFX helpers
func play_mining_dust(position: Vector3, intensity: float = 1.0) -> void:
    play_vfx("dust_cloud", position, intensity)
play_vfx("rock_fragments", position, intensity * 0.5)

func play_drill_effect(position: Vector3, rotation: Vector3 = Vector3.ZERO) -> void:
    play_vfx("drill_dust", position, 1.0)
play_vfx("sparks", position + Vector3(0, 0.5, 0), 0.7)

func play_discovery_effect(position: Vector3, resource_rarity: String = "common") -> void:
    var color = _get_rarity_color(resource_rarity)
play_vfx("discovery_burst", position, 1.5, color)
play_vfx("glow_mineral", position, 1.0, color)

func play_explosion(position: Vector3, scale: float = 2.0) -> void:
    play_vfx("explosion", position, scale)
play_vfx("smoke", position, scale * 1.5)

func play_smoke(position: Vector3, amount: float = 1.0) -> void:
    play_vfx("smoke", position, amount)

func play_steam(position: Vector3, amount: float = 1.0) -> void:
    play_vfx("steam", position + Vector3(0, 0.3, 0), amount)

func play_conveyor_dust(position: Vector3) -> void:
    play_vfx("conveyor_dust", position, 0.5)

func _get_rarity_color(rarity: String) -> Color:
    match rarity:
        "common":
        return Color.GRAY
"uncommon":
    return Color.GREEN
"rare":
    return Color.BLUE
"very_rare":
    return Color.PURPLE
"legendary":
    return Color.ORANGE
_:
    return Color.WHITE

func get_active_effect_count() -> int:
    var count = 0
for pool in _particle_pools.values():
    for particles in pool:
        if particles.emitting:
            count += 1
return count

func cleanup_finished_effects() -> void:
    var current_time = Time.get_unix_time_from_system()
var to_remove = []

for i in range(_active_effects.size()):
    var effect = _active_effects[i]
var particles = effect.get("particles") as GPUParticles3D

if not particles or not particles.emitting:
    to_remove.append(i)

# Remove in reverse order to maintain indices
for i in range(to_remove.size() - 1, -1, -1):
    _active_effects.remove_at(to_remove[i])

func _process(_delta: float) -> void:
    cleanup_finished_effects()

func save_state() -> Dictionary:
    return {
"max_particles": max_particles,
"enabled": true  # Could track enable state
}

func load_state(data: Dictionary) -> void:
    if data.has("max_particles"):
        max_particles = data["max_particles"]