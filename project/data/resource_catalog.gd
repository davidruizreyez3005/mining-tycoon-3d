extends RefCounted
class_name ResourceCatalog

var _resources: Dictionary = {}

func _init() -> void:
    _initialize_resources()

func _initialize_resources() -> void:
    var stone = ResourceDefinition.new()
    stone.id = "stone"
    stone.name = "Stone"
    stone.rarity = "common"
    stone.value = 1
    _register(stone)
    
    var coal = ResourceDefinition.new()
    coal.id = "coal"
    coal.name = "Coal"
    coal.rarity = "common"
    coal.value = 2
    _register(coal)

func _register(res: ResourceDefinition) -> void:
    _resources[res.id] = res

func get_resource(id: String) -> ResourceDefinition:
    return _resources.get(id)

func get_all_resources() -> Array:
    return _resources.values()
