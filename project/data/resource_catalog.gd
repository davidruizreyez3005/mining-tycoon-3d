extends RefCounted
class_name ResourceCatalog

## Central catalog of all resource definitions
## Provides lookup and filtering capabilities

var _resources: Dictionary = {}

func _init() -> void:
    _initialize_default_resources()

func _initialize_default_resources() -> void:
    # Create default resource definitions programmatically
# In production, these would be loaded from .tres files

var stone = ResourceDefinition.new()
stone.id = "stone"
stone.name = "Stone"
stone.rarity = "common"
stone.base_value = 1
stone.extraction_difficulty = 0.1
stone.unlock_depth = 0
_register_resource(stone)

var coal = ResourceDefinition.new()
coal.id = "coal"
coal.name = "Coal"
coal.rarity = "common"
coal.base_value = 3
coal.extraction_difficulty = 0.2
coal.unlock_depth = 5
_register_resource(coal)

var copper = ResourceDefinition.new()
copper.id = "copper"
copper.name = "Copper Ore"
copper.rarity = "common"
copper.base_value = 8
copper.extraction_difficulty = 0.3
copper.processing_requirement = "crusher_t1"
copper.unlock_depth = 10
_register_resource(copper)

var iron = ResourceDefinition.new()
iron.id = "iron"
iron.name = "Iron Ore"
iron.rarity = "common"
iron.base_value = 12
iron.extraction_difficulty = 0.4
iron.processing_requirement = "crusher_t1"
iron.unlock_depth = 15
_register_resource(iron)

var silver = ResourceDefinition.new()
silver.id = "silver"
silver.name = "Silver Ore"
silver.rarity = "uncommon"
silver.base_value = 25
silver.extraction_difficulty = 0.5
silver.processing_requirement = "crusher_t2"
silver.unlock_depth = 25
_register_resource(silver)

var gold = ResourceDefinition.new()
gold.id = "gold"
gold.name = "Gold Ore"
gold.rarity = "uncommon"
gold.base_value = 50
gold.extraction_difficulty = 0.6
gold.processing_requirement = "crusher_t2"
gold.unlock_depth = 35
_register_resource(gold)

var quartz = ResourceDefinition.new()
quartz.id = "quartz"
quartz.name = "Quartz Crystal"
quartz.rarity = "uncommon"
quartz.base_value = 35
quartz.extraction_difficulty = 0.55
quartz.unlock_depth = 30
quartz.production_modifiers = {"value_multiplier": 1.1}
_register_resource(quartz)

var platinum = ResourceDefinition.new()
platinum.id = "platinum"
platinum.name = "Platinum Ore"
platinum.rarity = "rare"
platinum.base_value = 100
platinum.extraction_difficulty = 0.7
platinum.processing_requirement = "crusher_t3"
platinum.unlock_depth = 50
_register_resource(platinum)

var emerald = ResourceDefinition.new()
emerald.id = "emerald"
emerald.name = "Emerald Crystal"
emerald.rarity = "rare"
emerald.base_value = 150
emerald.extraction_difficulty = 0.75
emerald.unlock_depth = 55
emerald.production_modifiers = {"value_multiplier": 1.2}
_register_resource(emerald)

var ruby = ResourceDefinition.new()
ruby.id = "ruby"
ruby.name = "Ruby Crystal"
ruby.rarity = "rare"
ruby.base_value = 175
ruby.extraction_difficulty = 0.78
ruby.unlock_depth = 60
ruby.production_modifiers = {"value_multiplier": 1.2}
_register_resource(ruby)

var sapphire = ResourceDefinition.new()
sapphire.id = "sapphire"
sapphire.name = "Sapphire Crystal"
sapphire.rarity = "rare"
sapphire.base_value = 180
sapphire.extraction_difficulty = 0.8
sapphire.unlock_depth = 65
sapphire.production_modifiers = {"value_multiplier": 1.2}
_register_resource(sapphire)

var diamond = ResourceDefinition.new()
diamond.id = "diamond"
diamond.name = "Diamond"
diamond.rarity = "very_rare"
diamond.base_value = 500
diamond.extraction_difficulty = 0.9
diamond.processing_requirement = "crusher_t4"
diamond.unlock_depth = 80
diamond.production_modifiers = {"value_multiplier": 1.5}
_register_resource(diamond)

func _register_resource(resource: ResourceDefinition) -> void:
    _resources[resource.id] = resource

func get_resource(id: String) -> ResourceDefinition:
    return _resources.get(id)

func get_all_resources() -> Array:
    return _resources.values()

func get_resources_by_rarity(rarity: String) -> Array:
    var result = []
for resource in _resources.values():
    if resource.rarity == rarity:
        result.append(resource)
return result

func get_available_at_depth(depth: int) -> Array:
    var result = []
for resource in _resources.values():
    if resource.can_be_mined_at_depth(depth):
        result.append(resource)
return result

func get_common_resources() -> Array:
    return get_resources_by_rarity("common")

func get_uncommon_resources() -> Array:
    return get_resources_by_rarity("uncommon")

func get_rare_resources() -> Array:
    return get_resources_by_rarity("rare")

func get_very_rare_resources() -> Array:
    return get_resources_by_rarity("very_rare")

func has_resource(id: String) -> bool:
    return _resources.has(id)

func get_resource_count() -> int:
    return _resources.size()