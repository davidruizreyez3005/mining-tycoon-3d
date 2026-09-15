extends RefCounted
class_name WorkerCatalog

var _workers: Dictionary = {}

func _init() -> void:
    pass

func get_worker(id: String) -> WorkerDefinition:
    return _workers.get(id)
