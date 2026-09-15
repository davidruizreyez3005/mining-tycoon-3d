extends Node
class_name PrestigeSystem

var prestige_points: int = 0
var multiplier: float = 1.0

func can_prestige() -> bool:
    return prestige_points > 0

func do_prestige() -> void:
    if can_prestige():
        multiplier += 0.1
        prestige_points = 0

func get_multiplier() -> float:
    return multiplier
