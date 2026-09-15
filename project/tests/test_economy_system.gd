extends RefCounted
class_name TestEconomySystem

## Automated tests for EconomySystem
## Validates production, selling, offline progression, and economy balance

var passed: int = 0
var failed: int = 0
var test_results: Array[Dictionary] = []

func run_all_tests() -> bool:
	print("=== Running Economy System Tests ===")
	
	_test_initialization()
	_test_resource_operations()
	_test_selling()
	_test_production_calculation()
	_test_offline_progression()
	_test_multipliers()
	_test_save_load()
	
	_print_summary()
	return failed == 0

func _test_initialization() -> void:
	var test_name = "Initialization"
	var economy = EconomySystem.new()
	var player_data = {"money": 100, "total_earned": 0}
	var world_data = {"machines": [], "workers": []}
	
	economy.initialize(player_data, world_data)
	
	if economy.player_data == player_data and economy.world_data == world_data:
		_pass(test_name)
	else:
		_fail(test_name, "Economy not initialized correctly")

func _test_resource_operations() -> void:
	var test_name = "Resource Operations"
	var economy = _create_test_economy()
	
	# Add resources
	economy.add_resource("stone", 100)
	economy.add_resource("iron", 50)
	
	if economy.get_resource("stone") != 100:
		_fail(test_name, "Failed to add stone")
		return
	
	if economy.get_resource("iron") != 50:
		_fail(test_name, "Failed to add iron")
		return
	
	# Remove resources
	var removed = economy.remove_resource("stone", 30)
	if not removed or economy.get_resource("stone") != 70:
		_fail(test_name, "Failed to remove stone")
		return
	
	# Try to remove more than available
	removed = economy.remove_resource("stone", 1000)
	if removed:
		_fail(test_name, "Should not remove more than available")
		return
	
	_pass(test_name)

func _test_selling() -> void:
	var test_name = "Selling Resources"
	var economy = _create_test_economy()
	
	economy.add_resource("stone", 100)
	var initial_money = economy.player_data["money"]
	
	var earnings = economy.sell_resource("stone", 50)
	var expected_earnings = 50 * 1  # stone base_value = 1
	
	if earnings != expected_earnings:
		_fail(test_name, "Wrong earnings: got %d, expected %d" % [earnings, expected_earnings])
		return
	
	if economy.player_data["money"] != initial_money + expected_earnings:
		_fail(test_name, "Money not updated correctly")
		return
	
	if economy.get_resource("stone") != 50:
		_fail(test_name, "Resource not deducted after sale")
		return
	
	_pass(test_name)

func _test_production_calculation() -> void:
	var test_name = "Production Calculation"
	var economy = _create_test_economy()
	
	var machines = [
		{"id": "miner1", "base_rate": 2.0, "output_resource": "stone", "output_per_operation": 5, "efficiency": 1.0, "worker_slots": 2},
		{"id": "miner2", "base_rate": 1.5, "output_resource": "coal", "output_per_operation": 3, "efficiency": 1.2, "worker_slots": 1}
	]
	var workers = 3
	var delta = 60.0  # 1 minute
	
	var production = economy.calculate_production(machines, workers, delta)
	
	if not production.has("stone") or production["stone"] <= 0:
		_fail(test_name, "No stone produced")
		return
	
	if not production.has("coal") or production["coal"] <= 0:
		_fail(test_name, "No coal produced")
		return
	
	_pass(test_name)

func _test_offline_progression() -> void:
	var test_name = "Offline Progression"
	var economy = _create_test_economy()
	
	var machines = [
		{"id": "miner1", "base_rate": 1.0, "output_resource": "stone", "output_per_operation": 10, "efficiency": 1.0, "worker_slots": 1}
	]
	var workers = 2
	economy.world_data["machines"] = machines
	
	var offline_seconds = 3600  # 1 hour
	var result = economy.simulate_offline_progress(offline_seconds, workers)
	
	if not result.has("money_earned") or result["money_earned"] <= 0:
		_fail(test_name, "No money earned offline")
		return
	
	if not result.has("resources_mined") or result["resources_mined"] <= 0:
		_fail(test_name, "No resources mined offline")
		return
	
	_pass(test_name)

func _test_multipliers() -> void:
	var test_name = "Production Multipliers"
	var economy = _create_test_economy()
	
	# Set base production rate
	economy.production_rate = 2.0
	economy.value_multiplier = 1.5
	
	economy.add_resource("stone", 100)
	var earnings = economy.sell_resource("stone", 100)
	var expected = 100 * 1 * 1.5  # amount * base_value * multiplier
	
	if earnings != expected:
		_fail(test_name, "Multiplier not applied: got %d, expected %d" % [earnings, expected])
		return
	
	_pass(test_name)

func _test_save_load() -> void:
	var test_name = "Save/Load State"
	var economy = _create_test_economy()
	
	economy.add_resource("stone", 100)
	economy.add_resource("iron", 50)
	economy.player_data["money"] = 500
	
	var state = economy.save_state()
	
	var new_economy = EconomySystem.new()
	new_economy.initialize({"money": 0, "total_earned": 0}, {"machines": [], "workers": []})
	new_economy.load_state(state)
	
	if new_economy.get_resource("stone") != 100:
		_fail(test_name, "Stone not restored")
		return
	
	if new_economy.get_resource("iron") != 50:
		_fail(test_name, "Iron not restored")
		return
	
	if new_economy.player_data["money"] != 500:
		_fail(test_name, "Money not restored")
		return
	
	_pass(test_name)

func _create_test_economy() -> EconomySystem:
	var economy = EconomySystem.new()
	var player_data = {"money": 100, "total_earned": 0}
	var world_data = {"machines": [], "workers": []}
	economy.initialize(player_data, world_data)
	return economy

func _pass(name: String) -> void:
	passed += 1
	test_results.append({"name": name, "passed": true})
	print("  ✓ %s" % name)

func _fail(name: String, reason: String) -> void:
	failed += 1
	test_results.append({"name": name, "passed": false, "reason": reason})
	print("  ✗ %s: %s" % [name, reason])

func _print_summary() -> void:
	print("\n=== Test Summary ===")
	print("Passed: %d" % passed)
	print("Failed: %d" % failed)
	print("Total:  %d" % (passed + failed))
