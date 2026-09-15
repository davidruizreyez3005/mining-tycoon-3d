extends RefCounted
class_name UpgradeCatalog

## Central catalog of all upgrade definitions

var _upgrades: Dictionary = {}

func _init() -> void:
	_initialize_default_upgrades()

func _initialize_default_upgrades() -> void:
	# === MACHINE UPGRADES ===
	
	# Pickaxe upgrades (early game)
	var pickaxe_t2 = UpgradeDefinition.new()
	pickaxe_t2.id = "pickaxe_t2"
	pickaxe_t2.name = "Iron Pickaxe"
	pickaxe_t2.description = "Increases mining speed by 25%"
	pickaxe_t2.upgrade_type = "machine"
	pickaxe_t2.tier = 1
	pickaxe_t2.cost = 150
	pickaxe_t2.target_type = "pickaxe"
	pickaxe_t2.effects = {"mining_speed": 1.25}
	pickaxe_t2.unlock_depth = 0
	_register_upgrade(pickaxe_t2)
	
	var pickaxe_t3 = UpgradeDefinition.new()
	pickaxe_t3.id = "pickaxe_t3"
	pickaxe_t3.name = "Steel Pickaxe"
	pickaxe_t3.description = "Increases mining speed by 50%"
	pickaxe_t3.upgrade_type = "machine"
	pickaxe_t3.tier = 2
	pickaxe_t3.cost = 400
	pickaxe_t3.prerequisites = ["pickaxe_t2"]
	pickaxe_t3.target_type = "pickaxe"
	pickaxe_t3.effects = {"mining_speed": 1.5}
	pickaxe_t3.unlock_depth = 10
	_register_upgrade(pickaxe_t3)
	
	# Drill upgrades
	var drill_t1 = UpgradeDefinition.new()
	drill_t1.id = "drill_t1"
	drill_t1.name = "Basic Drill"
	drill_t1.description = "Automated drilling, 2x mining speed"
	drill_t1.upgrade_type = "machine"
	drill_t1.tier = 1
	drill_t1.cost = 500
	drill_t1.target_type = "drill"
	drill_t1.effects = {"mining_speed": 2.0, "automation": true}
	drill_t1.unlock_depth = 5
	_register_upgrade(drill_t1)
	
	var drill_t2 = UpgradeDefinition.new()
	drill_t2.id = "drill_t2"
	drill_t2.name = "Powered Drill"
	drill_t2.description = "Advanced drilling, 3x mining speed"
	drill_t2.upgrade_type = "machine"
	drill_t2.tier = 2
	drill_t2.cost = 1200
	drill_t2.prerequisites = ["drill_t1"]
	drill_t2.target_type = "drill"
	drill_t2.effects = {"mining_speed": 3.0}
	drill_t2.unlock_depth = 20
	_register_upgrade(drill_t2)
	
	# Conveyor upgrades
	var conveyor_t1 = UpgradeDefinition.new()
	conveyor_t1.id = "conveyor_t1"
	conveyor_t1.name = "Basic Conveyor"
	conveyor_t1.description = "Automated resource transport"
	conveyor_t1.upgrade_type = "machine"
	conveyor_t1.tier = 1
	conveyor_t1.cost = 300
	conveyor_t1.target_type = "conveyor"
	conveyor_t1.effects = {"transport_speed": 1.0, "automation": true}
	conveyor_t1.unlock_depth = 8
	_register_upgrade(conveyor_t1)
	
	var conveyor_t2 = UpgradeDefinition.new()
	conveyor_t2.id = "conveyor_t2"
	conveyor_t2.name = "Fast Conveyor"
	conveyor_t2.description = "Increased transport speed"
	conveyor_t2.upgrade_type = "machine"
	conveyor_t2.tier = 2
	conveyor_t2.cost = 750
	conveyor_t2.prerequisites = ["conveyor_t1"]
	conveyor_t2.target_type = "conveyor"
	conveyor_t2.effects = {"transport_speed": 2.0}
	conveyor_t2.unlock_depth = 25
	_register_upgrade(conveyor_t2)
	
	# Crusher upgrades
	var crusher_t1 = UpgradeDefinition.new()
	crusher_t1.id = "crusher_t1"
	crusher_t1.name = "Ore Crusher T1"
	crusher_t1.description = "Processes copper and iron ore"
	crusher_t1.upgrade_type = "machine"
	crusher_t1.tier = 1
	crusher_t1.cost = 800
	crusher_t1.target_type = "crusher"
	crusher_t1.effects = {"processing_unlock": ["copper", "iron"]}
	crusher_t1.unlock_depth = 15
	_register_upgrade(crusher_t1)
	
	var crusher_t2 = UpgradeDefinition.new()
	crusher_t2.id = "crusher_t2"
	crusher_t2.name = "Ore Crusher T2"
	crusher_t2.description = "Processes silver and gold ore"
	crusher_t2.upgrade_type = "machine"
	crusher_t2.tier = 2
	crusher_t2.cost = 2000
	crusher_t2.prerequisites = ["crusher_t1"]
	crusher_t2.target_type = "crusher"
	crusher_t2.effects = {"processing_unlock": ["silver", "gold"]}
	crusher_t2.unlock_depth = 35
	_register_upgrade(crusher_t2)
	
	# Storage upgrades
	var storage_t1 = UpgradeDefinition.new()
	storage_t1.id = "storage_t1"
	storage_t1.name = "Large Storage"
	storage_t1.description = "Doubles storage capacity"
	storage_t1.upgrade_type = "machine"
	storage_t1.tier = 1
	storage_t1.cost = 400
	storage_t1.target_type = "storage"
	storage_t1.effects = {"capacity_multiplier": 2.0}
	storage_t1.unlock_depth = 5
	_register_upgrade(storage_t1)
	
	var storage_t2 = UpgradeDefinition.new()
	storage_t2.id = "storage_t2"
	storage_t2.name = "Industrial Storage"
	storage_t2.description = "Triples storage capacity"
	storage_t2.upgrade_type = "machine"
	storage_t2.tier = 2
	storage_t2.cost = 1000
	storage_t2.prerequisites = ["storage_t1"]
	storage_t2.target_type = "storage"
	storage_t2.effects = {"capacity_multiplier": 3.0}
	storage_t2.unlock_depth = 30
	_register_upgrade(storage_t2)
	
	# === WORKER UPGRADES ===
	
	var worker_training = UpgradeDefinition.new()
	worker_training.id = "worker_training"
	worker_training.name = "Basic Training"
	worker_training.description = "Workers are 15% more efficient"
	worker_training.upgrade_type = "worker"
	worker_training.tier = 1
	worker_training.cost = 250
	worker_training.effects = {"worker_efficiency": 1.15}
	worker_training.unlock_depth = 3
	_register_upgrade(worker_training)
	
	var worker_advanced_training = UpgradeDefinition.new()
	worker_advanced_training.id = "worker_advanced_training"
	worker_advanced_training.name = "Advanced Training"
	worker_advanced_training.description = "Workers are 30% more efficient"
	worker_advanced_training.upgrade_type = "worker"
	worker_advanced_training.tier = 2
	worker_advanced_training.cost = 600
	worker_advanced_training.prerequisites = ["worker_training"]
	worker_advanced_training.effects = {"worker_efficiency": 1.3}
	worker_advanced_training.unlock_depth = 15
	_register_upgrade(worker_advanced_training)
	
	var worker_safety = UpgradeDefinition.new()
	worker_safety.id = "worker_safety"
	worker_safety.name = "Safety Equipment"
	worker_safety.description = "Reduces worker fatigue by 20%"
	worker_safety.upgrade_type = "worker"
	worker_safety.tier = 1
	worker_safety.cost = 350
	worker_safety.effects = {"stamina_drain_reduction": 0.8}
	worker_safety.unlock_depth = 10
	_register_upgrade(worker_safety)
	
	# === GLOBAL/TECHNOLOGY UPGRADES ===
	
	var cart_upgrade = UpgradeDefinition.new()
	cart_upgrade.id = "cart_upgrade"
	cart_upgrade.name = "Mine Cart"
	cart_upgrade.description = "Unlocks mine carts for resource transport"
	cart_upgrade.upgrade_type = "technology"
	cart_upgrade.tier = 1
	cart_upgrade.cost = 200
	cart_upgrade.effects = {"unlock_vehicle": "mine_cart"}
	cart_upgrade.unlock_depth = 5
	_register_upgrade(cart_upgrade)
	
	var elevator_upgrade = UpgradeDefinition.new()
	elevator_upgrade.id = "elevator_upgrade"
	elevator_upgrade.name = "Mine Elevator"
	elevator_upgrade.description = "Unlocks elevator for deeper access"
	elevator_upgrade.upgrade_type = "technology"
	elevator_upgrade.tier = 1
	elevator_upgrade.cost = 1000
	elevator_upgrade.effects = {"unlock_depth_bonus": 10}
	elevator_upgrade.unlock_depth = 15
	_register_upgrade(elevator_upgrade)
	
	var dynamite = UpgradeDefinition.new()
	dynamite.id = "dynamite"
	dynamite.name = "Dynamite"
	dynamite.description = "Explosives for faster rock removal"
	dynamite.upgrade_type = "technology"
	dynamite.tier = 2
	dynamite.cost = 500
	dynamite.effects = {"explosion_damage": 50, "unlock_explosives": true}
	dynamite.unlock_depth = 20
	_register_upgrade(dynamite)
	
	var ventilation = UpgradeDefinition.new()
	ventilation.id = "ventilation"
	ventilation.name = "Ventilation System"
	ventilation.description = "Allows deeper mining operations"
	ventilation.upgrade_type = "technology"
	ventilation.tier = 2
	ventilation.cost = 1500
	ventilation.prerequisites = ["elevator_upgrade"]
	ventilation.effects = {"max_depth_bonus": 20}
	ventilation.unlock_depth = 30
	_register_upgrade(ventilation)
	
	var automation_hub = UpgradeDefinition.new()
	automation_hub.id = "automation_hub"
	automation_hub.name = "Automation Hub"
	automation_hub.description = "Central control for automated systems"
	automation_hub.upgrade_type = "technology"
	automation_hub.tier = 3
	automation_hub.cost = 3000
	automation_hub.prerequisites = ["conveyor_t2", "drill_t2"]
	automation_hub.effects = {"automation_cap": 10, "efficiency_bonus": 1.2}
	automation_hub.unlock_depth = 40
	_register_upgrade(automation_hub)

func _register_upgrade(upgrade: UpgradeDefinition) -> void:
	_upgrades[upgrade.id] = upgrade

func get_upgrade(id: String) -> UpgradeDefinition:
	return _upgrades.get(id)

func get_all_upgrades() -> Array:
	return _upgrades.values()

func get_upgrades_by_type(type: String) -> Array:
	var result = []
	for upgrade in _upgrades.values():
		if upgrade.upgrade_type == type:
			result.append(upgrade)
	return result

func get_available_upgrades(unlocked_depth: int, owned_upgrades: Array[String]) -> Array:
	var result = []
	for upgrade in _upgrades.values():
		if upgrade.unlock_depth <= unlocked_depth and upgrade.id not in owned_upgrades:
			# Check prerequisites
			var has_prereqs = true
			for prereq in upgrade.prerequisites:
				if prereq not in owned_upgrades:
					has_prereqs = false
					break
			if has_prereqs:
				result.append(upgrade)
	return result

func can_purchase_upgrade(upgrade_id: String, money: int, owned_upgrades: Array[String]) -> bool:
	var upgrade = _upgrades.get(upgrade_id)
	if not upgrade:
		return false
	if money < upgrade.cost:
		return false
	if upgrade_id in owned_upgrades:
		return false
	for prereq in upgrade.prerequisites:
		if prereq not in owned_upgrades:
			return false
	return true

func has_upgrade(id: String) -> bool:
	return _upgrades.has(id)

func get_upgrade_count() -> int:
	return _upgrades.size()
