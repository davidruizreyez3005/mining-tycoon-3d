extends Node
class_name WorldGenerator

func generate_surface() -> void:
    pass

func generate_underground(depth: int) -> void:
    pass

func get_depth_info(depth: int) -> Dictionary:
    return {"depth": depth, "resources": []}
