extends Node
class_name WorkerManager

var _workers: Array = []

func hire_worker(type: String) -> void:
    var worker = {"id": str(_workers.size()), "type": type}
    _workers.append(worker)

func get_worker_count() -> int:
    return _workers.size()
