extends Node

func test_add_money() -> void:
    var eco = EconomySystem.new()
    eco.add_money(50)
    assert eco.money == 150

func test_spend_money() -> void:
    var eco = EconomySystem.new()
    var success = eco.spend_money(50)
    assert success == true
    assert eco.money == 50
