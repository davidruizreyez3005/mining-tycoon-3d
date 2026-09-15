extends RefCounted
class_name QuestDefinition

## Data-driven quest/achievement definition

@export var id: String
@export var name: String
@export var description: String
@export var quest_type: String = "achievement"
@export var category: String = "general"
@export var objective_type: String = "collect"
@export var target_value: int = 100
@export var target_resource: String = ""
@export var reward_money: int = 50
@export var reward_prestige: int = 0
@export var reward_items: Array[String] = []
@export var prerequisites: Array[String] = []
@export var is_repeatable: bool = false
@export var hidden: bool = false
@export var difficulty: int = 1

func get_display_name() -> String:
    return name if not name.is_empty() else id.capitalize()

func get_description() -> String:
    var desc = description
    if desc.is_empty():
        desc = "%s %d" % [objective_type.capitalize(), target_value]
        if not target_resource.is_empty():
            desc += " %s" % target_resource.capitalize()
    return desc

func get_progress_text(current: int) -> String:
    return "%d / %d" % [current, target_value]

func is_complete(current: int) -> bool:
    return current >= target_value

func get_reward_summary() -> String:
    var parts = []
    if reward_money > 0:
        parts.append("$%d" % reward_money)
    if reward_prestige > 0:
        parts.append("%d Prestige" % reward_prestige)
    if not reward_items.is_empty():
        parts.append("%d items" % reward_items.size())
    return ", ".join(parts) if not parts.is_empty() else "None"
