extends Node
class_name EconomySystem

signal money_changed(amount: int)
signal resource_changed(resource_id: String, amount: int)

var money: int = 100
var resources: Dictionary = {}

func add_money(amount: int) -> void:
    money += amount
    money_changed.emit(money)

func spend_money(amount: int) -> bool:
    if money >= amount:
        money -= amount
        money_changed.emit(money)
        return true
    return false

func add_resource(resource_id: String, amount: int) -> void:
    resources[resource_id] = resources.get(resource_id, 0) + amount
    resource_changed.emit(resource_id, amount)
