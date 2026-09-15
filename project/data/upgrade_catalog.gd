extends RefCounted
class_name UpgradeCatalog

var _upgrades: Dictionary = {}

func _init() -> void:
    pass

func get_upgrade(id: String) -> UpgradeDefinition:
    return _upgrades.get(id)
