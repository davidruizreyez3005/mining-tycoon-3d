extends Node3D
class_name WorldGenerator

## Procedural world generation system
## Creates surface terrain, underground tunnels, and resource deposits

signal generation_started()
signal generation_progress(progress: float)
signal generation_completed()

enum BiomeType {
TEMPERATE,
ARID,
MOUNTAIN,
VOLCANIC
}

enum DepthLayer {
SURFACE = 0,
SHALLOW = 1,
MEDIUM = 2,
DEEP = 3,
CRYSTAL = 4,
INDUSTRIAL = 5,
ENDGAME = 6
}

# Configuration
@export var seed: int = 12345
@export var biome: BiomeType = BiomeType.TEMPERATE
@export var surface_size: Vector2 = Vector2(100, 100)
@export var max_depth: float = 200.0
@export var chunk_size: float = 10.0

# Depth configurations
const DEPTH_CONFIG := {
DepthLayer.SURFACE: {"min_height": 0, "max_height": 10, "resources": ["stone"], "difficulty": 0.1},
DepthLayer.SHALLOW: {"min_height": -10, "max_height": -30, "resources": ["stone", "coal"], "difficulty": 0.2},
DepthLayer.MEDIUM: {"min_height": -30, "max_height": -60, "resources": ["stone", "coal", "copper", "iron"], "difficulty": 0.4},
DepthLayer.DEEP: {"min_height": -60, "max_height": -100, "resources": ["coal", "iron", "silver", "gold", "quartz"], "difficulty": 0.6},
DepthLayer.CRYSTAL: {"min_height": -100, "max_height": -150, "resources": ["silver", "gold", "platinum", "emerald", "ruby"], "difficulty": 0.8},
DepthLayer.INDUSTRIAL: {"min_height": -150, "max_height": -180, "resources": ["platinum", "emerald", "ruby", "sapphire"], "difficulty": 0.9},
DepthLayer.ENDGAME: {"min_height": -180, "max_height": -200, "resources": ["diamond", "sapphire"], "difficulty": 1.0}
}

var _random: RandomNumberGenerator
var _noise: FastNoiseLite
var generated_chunks: Dictionary = {}
var resource_nodes: Array[Dictionary] = []
var tunnel_systems: Array[Dictionary] = []

func _ready() -> void:
    _initialize_noise()

func _initialize_noise() -> void:
    _random = RandomNumberGenerator.new()
_random.seed = seed

_noise = FastNoiseLite.new()
_noise.seed = seed
_noise.frequency = 0.05
_noise.fractal_octaves = 4
_noise.fractal_lacunarity = 2.0
_noise.fractal_gain = 0.5

func generate_world(full_generate: bool = true) -> void:
    generation_started.emit()

if full_generate:
    _generate_surface()
_generate_underground()
_place_resource_nodes()
_generate_tunnels()
else:
    _generate_surface()

generation_completed.emit()

func _generate_surface() -> void:
    print("Generating surface terrain...")

# Create surface mesh
var vertices = PackedVector3Array()
var indices = PackedInt32Array()
var uvs = PackedVector2Array()
var normals = PackedVector3Array()

var step = chunk_size / 4.0
var half_size = surface_size / 2.0

for z in range(int(surface_size.y / step) + 1):
    for x in range(int(surface_size.x / step) + 1):
        var px = (x * step) - half_size.x
var pz = (z * step) - half_size.y

# Height from noise
var height = _get_surface_height(px, pz)

vertices.append(Vector3(px, height, pz))
normals.append(Vector3.UP)
uvs.append(Vector2(float(x) / (surface_size.x / step), float(z) / (surface_size.y / step)))

# Generate indices for triangles
for z in range(int(surface_size.y / step)):
    for x in range(int(surface_size.x / step)):
        var i = x + z * int(surface_size.x / step + 1)
indices.append(i)
indices.append(i + int(surface_size.x / step + 1))
indices.append(i + 1)

indices.append(i + 1)
indices.append(i + int(surface_size.x / step + 1))
indices.append(i + int(surface_size.x / step + 1) + 1)

generation_progress.emit(0.2)

func _get_surface_height(x: float, z: float) -> float:
    var height = _noise.get_noise_2d(x, z) * 10.0

# Add some variation based on biome
match biome:
    BiomeType.MOUNTAIN:
    height *= 2.0
BiomeType.ARID:
    height *= 0.7
BiomeType.VOLCANIC:
    height = abs(height) * 1.5

return height

func _generate_underground() -> void:
    print("Generating underground layers...")

# Generate tunnel networks at different depths
for depth_layer in range(1, DEPTH_CONFIG.size()):
    var config = DEPTH_CONFIG[depth_layer]
var layer_center_y = (config["min_height"] + config["max_height"]) / 2.0

# Create main tunnels
for i in range(3 + depth_layer):
    var start_x = (_random.randf() - 0.5) * surface_size.x
var start_z = (_random.randf() - 0.5) * surface_size.y

var tunnel = {
"start": Vector3(start_x, layer_center_y, start_z),
"direction": Vector3(_random.randf() - 0.5, 0, _random.randf() - 0.5).normalized(),
"length": 20.0 + _random.randf() * 30.0,
"width": 3.0 + float(depth_layer),
"height": 4.0 + float(depth_layer),
"depth_layer": depth_layer
}

tunnel_systems.append(tunnel)

generation_progress.emit(0.5)

func _place_resource_nodes() -> void:
    print("Placing resource nodes...")

for depth_layer in range(DEPTH_CONFIG.size()):
    var config = DEPTH_CONFIG[depth_layer]
var resources = config["resources"] as Array

for resource_id in resources:
    # Number of nodes based on depth and resource
var node_count = 5 + (DEPTH_CONFIG.size() - depth_layer) * 2
if resource_id in ["diamond", "sapphire", "ruby", "emerald"]:
    node_count = 2  # Rare resources have fewer nodes

for i in range(node_count):
    var node = _create_resource_node(resource_id, depth_layer, config)
if node:
    resource_nodes.append(node)

generation_progress.emit(0.8)

func _create_resource_node(resource_id: String, depth_layer: int, config: Dictionary) -> Dictionary:
    var half_size = surface_size / 2.0

var node = {
"id": "node_%s_%d" % [resource_id, resource_nodes.size()],
"resource": resource_id,
"position": Vector3(
(_random.randf() - 0.5) * surface_size.x,
(_random.randf() - 0.5) * (config["max_height"] - config["min_height"]) + config["min_height"],
(_random.randf() - 0.5) * surface_size.y
),
"size": 2.0 + _random.randf() * 3.0,
"amount": int(100.0 / config["difficulty"]) * (1 if resource_id == "stone" else 2),
"extracted": 0,
"depth_layer": depth_layer,
"difficulty": config["difficulty"]
}

return node

func _generate_tunnels() -> void:
    print("Finalizing tunnel systems...")

# Connect tunnels to surface entrances
for tunnel in tunnel_systems:
    if tunnel["depth_layer"] == 1:
    # Create entrance at surface
var entrance_pos = tunnel["start"]
entrance_pos.y = _get_surface_height(entrance_pos.x, entrance_pos.z)
tunnel["entrance"] = entrance_pos

generation_progress.emit(1.0)

func get_resource_at_position(position: Vector3) -> Dictionary:
    for node in resource_nodes:
    if node["extracted"] >= node["amount"]:
        continue

var dist = position.distance_to(node["position"])
if dist <= node["size"]:
    return node

return {}

func extract_resource(position: Vector3, amount: int) -> Dictionary:
    var node = get_resource_at_position(position)
if node.is_empty():
    return {}

var remaining = node["amount"] - node["extracted"]
var extracted = min(amount, remaining)

node["extracted"] += extracted

return {
"resource": node["resource"],
"amount": extracted
}

func get_depth_at_position(position: Vector3) -> int:
    for depth_layer in range(DEPTH_CONFIG.size() - 1, -1, -1):
        var config = DEPTH_CONFIG[depth_layer]
if position.y >= config["min_height"]:
    return depth_layer
return 0

func is_valid_position(position: Vector3) -> bool:
    # Check if position is within world bounds
var half_size = surface_size / 2.0
if abs(position.x) > half_size.x or abs(position.z) > half_size.y:
    return false

# Check if position is above ground or in a tunnel
var surface_height = _get_surface_height(position.x, position.z)
if position.y > surface_height:
    return true

# Check if in tunnel
for tunnel in tunnel_systems:
    var dist_to_tunnel = _distance_to_tunnel(position, tunnel)
if dist_to_tunnel < tunnel["width"] / 2.0:
    return true

return false

func _distance_to_tunnel(position: Vector3, tunnel: Dictionary) -> float:
    var tunnel_start = tunnel["start"]
var tunnel_end = tunnel_start + tunnel["direction"] * tunnel["length"]

# Distance to line segment
var v = tunnel_end - tunnel_start
var w = position - tunnel_start

var c1 = w.dot(v)
if c1 <= 0:
    return w.length()

var c2 = v.dot(v)
if c2 <= c1:
    return (position - tunnel_end).length()

var b = c1 / c2
var pb = tunnel_start + b * v

return (position - pb).length()

func get_spawn_position() -> Vector3:
    # Return surface spawn point near center
var spawn_x = (_random.randf() - 0.5) * 20.0
var spawn_z = (_random.randf() - 0.5) * 20.0
var spawn_y = _get_surface_height(spawn_x, spawn_z)

return Vector3(spawn_x, spawn_y + 2.0, spawn_z)

func save_state() -> Dictionary:
    return {
"seed": seed,
"biome": biome,
"resource_nodes": resource_nodes.duplicate(true),
"tunnel_systems": tunnel_systems.duplicate(true),
"generated_chunks": generated_chunks.duplicate()
}

func load_state(data: Dictionary) -> void:
    if data.has("seed"):
        seed = data["seed"]
_initialize_noise()
if data.has("biome"):
    biome = data["biome"]
if data.has("resource_nodes"):
    resource_nodes = data["resource_nodes"].duplicate(true)
if data.has("tunnel_systems"):
    tunnel_systems = data["tunnel_systems"].duplicate(true)
if data.has("generated_chunks"):
    generated_chunks = data["generated_chunks"].duplicate()