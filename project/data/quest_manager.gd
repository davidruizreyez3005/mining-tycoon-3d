extends RefCounted
class_name QuestManager

## Manages quests, achievements, and objectives
## Tracks progress and awards rewards

signal quest_completed(quest_id: String)
signal quest_progress_updated(quest_id: String, current: int, target: int)
signal reward_claimed(quest_id: String, rewards: Dictionary)

var _quests: Dictionary = {}
var _progress: Dictionary = {}  # quest_id -> current progress
var _completed: Array[String] = []
var _claimed_rewards: Array[String] = []
var quest_catalog: Array[QuestDefinition] = []

func _init() -> void:
	_initialize_quests()

func _initialize_quests() -> void:
	# === MINING QUESTS ===
	
	var mine_stone = QuestDefinition.new()
	mine_stone.id = "mine_stone_100"
	mine_stone.name = "Stone Miner"
	mine_stone.description = "Mine 100 stone"
	mine_stone.quest_type = "achievement"
	mine_stone.category = "mining"
	mine_stone.objective_type = "collect"
	mine_stone.target_value = 100
	mine_stone.target_resource = "stone"
	mine_stone.reward_money = 50
	mine_stone.difficulty = 1
	_register_quest(mine_stone)
	
	var mine_coal = QuestDefinition.new()
	mine_coal.id = "mine_coal_50"
	mine_coal.name = "Coal Digger"
	mine_coal.description = "Mine 50 coal"
	mine_coal.quest_type = "achievement"
	mine_coal.category = "mining"
	mine_coal.objective_type = "collect"
	mine_coal.target_value = 50
	mine_coal.target_resource = "coal"
	mine_coal.reward_money = 75
	mine_coal.difficulty = 2
	_register_quest(mine_coal)
	
	var mine_iron = QuestDefinition.new()
	mine_iron.id = "mine_iron_25"
	mine_iron.name = "Iron Worker"
	mine_iron.description = "Mine 25 iron ore"
	mine_iron.quest_type = "achievement"
	mine_iron.category = "mining"
	mine_iron.objective_type = "collect"
	mine_iron.target_value = 25
	mine_iron.target_resource = "iron"
	mine_iron.reward_money = 100
	mine_iron.difficulty = 2
	_register_quest(mine_iron)
	
	var mine_gold = QuestDefinition.new()
	mine_gold.id = "mine_gold_10"
	mine_gold.name = "Gold Rush"
	mine_gold.description = "Mine 10 gold ore"
	mine_gold.quest_type = "achievement"
	mine_gold.category = "mining"
	mine_gold.objective_type = "collect"
	mine_gold.target_value = 10
	mine_gold.target_resource = "gold"
	mine_gold.reward_money = 250
	mine_gold.difficulty = 3
	_register_quest(mine_gold)
	
	var mine_diamond = QuestDefinition.new()
	mine_diamond.id = "mine_diamond_1"
	mine_diamond.name = "Diamond Hunter"
	mine_diamond.description = "Discover your first diamond"
	mine_diamond.quest_type = "achievement"
	mine_diamond.category = "mining"
	mine_diamond.objective_type = "discover"
	mine_diamond.target_value = 1
	mine_diamond.target_resource = "diamond"
	mine_diamond.reward_money = 500
	mine_diamond.reward_prestige = 1
	mine_diamond.difficulty = 5
	_register_quest(mine_diamond)
	
	# === ECONOMY QUESTS ===
	
	var earn_money = QuestDefinition.new()
	earn_money.id = "earn_1000"
	earn_money.name = "First Thousand"
	earn_money.description = "Earn $1,000 total"
	earn_money.quest_type = "achievement"
	earn_money.category = "economy"
	earn_money.objective_type = "earn"
	earn_money.target_value = 1000
	earn_money.reward_money = 100
	earn_money.difficulty = 1
	_register_quest(earn_money)
	
	var earn_millionaire = QuestDefinition.new()
	earn_millionaire.id = "earn_1000000"
	earn_millionaire.name = "Mining Tycoon"
	earn_millionaire.description = "Earn $1,000,000 total"
	earn_millionaire.quest_type = "achievement"
	earn_millionaire.category = "economy"
	earn_millionaire.objective_type = "earn"
	earn_millionaire.target_value = 1000000
	earn_millionaire.reward_money = 10000
	earn_millionaire.reward_prestige = 5
	earn_millionaire.difficulty = 5
	_register_quest(earn_millionaire)
	
	# === EXPLORATION QUESTS ===
	
	var reach_depth_10 = QuestDefinition.new()
	reach_depth_10.id = "depth_10"
	reach_depth_10.name = "Going Deeper"
	reach_depth_10.description = "Reach depth level 10"
	reach_depth_10.quest_type = "milestone"
	reach_depth_10.category = "exploration"
	reach_depth_10.objective_type = "reach_depth"
	reach_depth_10.target_value = 10
	reach_depth_10.reward_money = 200
	reach_depth_10.difficulty = 2
	_register_quest(reach_depth_10)
	
	var reach_depth_50 = QuestDefinition.new()
	reach_depth_50.id = "depth_50"
	reach_depth_50.name = "Deep Explorer"
	reach_depth_50.description = "Reach depth level 50"
	reach_depth_50.quest_type = "milestone"
	reach_depth_50.category = "exploration"
	reach_depth_50.objective_type = "reach_depth"
	reach_depth_50.target_value = 50
	reach_depth_50.reward_money = 1000
	reach_depth_50.reward_prestige = 2
	reach_depth_50.difficulty = 4
	_register_quest(reach_depth_50)
	
	# === AUTOMATION QUESTS ===
	
	var hire_worker = QuestDefinition.new()
	hire_worker.id = "hire_first_worker"
	hire_worker.name = "Employer"
	hire_worker.description = "Hire your first worker"
	hire_worker.quest_type = "milestone"
	hire_worker.category = "automation"
	hire_worker.objective_type = "hire"
	hire_worker.target_value = 1
	hire_worker.reward_money = 50
	hire_worker.difficulty = 1
	_register_quest(hire_worker)
	
	var hire_10_workers = QuestDefinition.new()
	hire_10_workers.id = "hire_10_workers"
	hire_10_workers.name = "Workforce"
	hire_10_workers.description = "Have 10 workers employed"
	hire_10_workers.quest_type = "achievement"
	hire_10_workers.category = "automation"
	hire_10_workers.objective_type = "hire"
	hire_10_workers.target_value = 10
	hire_10_workers.reward_money = 300
	hire_10_workers.difficulty = 3
	_register_quest(hire_10_workers)
	
	var build_conveyor = QuestDefinition.new()
	build_conveyor.id = "build_conveyor"
	build_conveyor.name = "Automation Begins"
	build_conveyor.description = "Build your first conveyor belt"
	build_conveyor.quest_type = "milestone"
	build_conveyor.category = "automation"
	build_conveyor.objective_type = "build"
	build_conveyor.target_value = 1
	build_conveyor.reward_money = 100
	build_conveyor.difficulty = 2
	_register_quest(build_conveyor)
	
	# === PRESTIGE QUESTS ===
	
	var first_prestige = QuestDefinition.new()
	first_prestige.id = "first_prestige"
	first_prestige.name = "New Beginnings"
	first_prestige.description = "Perform your first prestige reset"
	first_prestige.quest_type = "milestone"
	first_prestige.category = "prestige"
	first_prestige.objective_type = "prestige"
	first_prestige.target_value = 1
	first_prestige.reward_money = 0
	first_prestige.reward_prestige = 0
	first_prestige.difficulty = 4
	_register_quest(first_prestige)

func _register_quest(quest: QuestDefinition) -> void:
	quest_catalog.append(quest)
	_quests[quest.id] = quest
	_progress[quest.id] = 0

func update_progress(quest_id: String, amount: int) -> void:
	if not _quests.has(quest_id):
		return
	
	if quest_id in _completed:
		var quest = _quests[quest_id]
		if not quest.is_repeatable:
			return
	
	_progress[quest_id] = max(0, _progress[quest_id] + amount)
	
	var quest = _quests[quest_id]
	quest_progress_updated.emit(quest_id, _progress[quest_id], quest.target_value)
	
	# Check completion
	if quest.is_complete(_progress[quest_id]) and quest_id not in _completed:
		_complete_quest(quest_id)

func set_progress(quest_id: String, value: int) -> void:
	if not _quests.has(quest_id):
		return
	
	_progress[quest_id] = value
	
	var quest = _quests[quest_id]
	quest_progress_updated.emit(quest_id, _progress[quest_id], quest.target_value)
	
	if quest.is_complete(_progress[quest_id]) and quest_id not in _completed:
		_complete_quest(quest_id)

func _complete_quest(quest_id: String) -> void:
	_completed.append(quest_id)
	quest_completed.emit(quest_id)
	print("Quest completed: %s" % quest_id)

func claim_reward(quest_id: String) -> bool:
	if quest_id not in _completed:
		return false
	
	if quest_id in _claimed_rewards:
		var quest = _quests[quest_id]
		if not quest.is_repeatable:
			return false
		# Reset for repeatable
		_progress[quest_id] = 0
		_completed.erase(quest_id)
	
	_claimed_rewards.append(quest_id)
	
	var quest = _quests[quest_id]
	var rewards = {
		"money": quest.reward_money,
		"prestige": quest.reward_prestige,
		"items": quest.reward_items.duplicate()
	}
	
	reward_claimed.emit(quest_id, rewards)
	return true

func get_quest(quest_id: String) -> QuestDefinition:
	return _quests.get(quest_id)

func get_all_quests() -> Array[QuestDefinition]:
	return quest_catalog

func get_available_quests() -> Array[QuestDefinition]:
	var result = []
	for quest in quest_catalog:
		if quest.hidden and _progress[quest.id] <= 0:
			continue
		if quest_id not in _completed or quest.is_repeatable:
			result.append(quest)
	return result

func get_completed_quests() -> Array[String]:
	return _completed.duplicate()

func get_unclaimed_rewards() -> Array[String]:
	var result = []
	for quest_id in _completed:
		if quest_id not in _claimed_rewards:
			result.append(quest_id)
	return result

func get_progress(quest_id: String) -> int:
	return _progress.get(quest_id, 0)

func is_completed(quest_id: String) -> bool:
	return quest_id in _completed

func can_claim(quest_id: String) -> bool:
	return quest_id in _completed and quest_id not in _claimed_rewards

func get_total_completed() -> int:
	return _completed.size()

func get_completion_percentage() -> float:
	if quest_catalog.is_empty():
		return 0.0
	return float(_completed.size()) / float(quest_catalog.size()) * 100.0

func save_state() -> Dictionary:
	return {
		"progress": _progress.duplicate(),
		"completed": _completed.duplicate(),
		"claimed": _claimed_rewards.duplicate()
	}

func load_state(data: Dictionary) -> void:
	if data.has("progress"):
		_progress.merge(data["progress"], true)
	if data.has("completed"):
		_completed = data["completed"].duplicate()
	if data.has("claimed"):
		_claimed_rewards = data["claimed"].duplicate()
