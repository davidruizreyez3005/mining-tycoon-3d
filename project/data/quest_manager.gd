extends RefCounted
class_name QuestManager

signal quest_completed(quest_id: String)
signal quest_progress_updated(quest_id: String, current: int, target: int)

var _quests: Dictionary = {}
var _progress: Dictionary = {}
var _completed: Array[String] = []

func _init() -> void:
    _initialize_quests()

func _initialize_quests() -> void:
    var mine_stone = QuestDefinition.new()
    mine_stone.id = "mine_stone_100"
    mine_stone.name = "Stone Miner"
    mine_stone.description = "Mine 100 stone"
    mine_stone.objective_type = "collect"
    mine_stone.target_value = 100
    mine_stone.target_resource = "stone"
    mine_stone.reward_money = 50
    _register_quest(mine_stone)
    
    var earn_money = QuestDefinition.new()
    earn_money.id = "earn_1000"
    earn_money.name = "First Fortune"
    earn_money.description = "Earn $1000"
    earn_money.objective_type = "earn"
    earn_money.target_value = 1000
    earn_money.reward_money = 100
    _register_quest(earn_money)

func _register_quest(quest: QuestDefinition) -> void:
    _quests[quest.id] = quest
    _progress[quest.id] = 0

func get_all_quests() -> Array:
    return _quests.values()

func update_progress(quest_id: String, amount: int) -> void:
    if quest_id in _progress:
        _progress[quest_id] += amount
        if quest_id in _quests:
            var quest = _quests[quest_id]
            quest_progress_updated.emit(quest_id, _progress[quest_id], quest.target_value)
            if _progress[quest_id] >= quest.target_value and quest_id not in _completed:
                _completed.append(quest_id)
                quest_completed.emit(quest_id)

func get_progress(quest_id: String) -> int:
    return _progress.get(quest_id, 0)

func is_completed(quest_id: String) -> bool:
    return quest_id in _completed
