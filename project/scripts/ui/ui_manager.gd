extends Node

signal ui_ready
signal menu_opened(menu_name: String)
signal menu_closed(menu_name: String)

var current_menu: String = ""
var is_paused: bool = false

func _ready() -> void:
ui_ready.emit()

func open_menu(menu_name: String) -> void:
if current_menu == menu_name:
return

if current_menu != "":
close_menu(current_menu)

current_menu = menu_name
is_paused = true
menu_opened.emit(menu_name)
print("UIManager: Opened menu: %s" % menu_name)

func close_menu(menu_name: String) -> void:
if current_menu != menu_name:
return

current_menu = ""
is_paused = false
menu_closed.emit(menu_name)
print("UIManager: Closed menu: %s" % menu_name)

func close_all_menus() -> void:
if current_menu != "":
var menu = current_menu
current_menu = ""
is_paused = false
menu_closed.emit(menu)

func toggle_pause() -> void:
if is_paused:
close_all_menus()
else:
open_menu("pause")

func update_money_display(amount: float) -> void:
print("UI: Money: $%.2f" % amount)

func update_resource_display(resource_id: String, amount: int) -> void:
var resource_name = EconomySystem.get_resource_name(resource_id)
print("UI: %s: %d" % [resource_name, amount])

func show_notification(message: String, duration: float = 3.0) -> void:
print("NOTIFICATION: %s" % message)

func show_offline_earnings(data: Dictionary) -> void:
print("=== OFFLINE EARNINGS ===")
for resource_id in data.get("resources_mined", {}):
var amount = data["resources_mined"][resource_id]
print("Mined %s: %d" % [resource_id, amount])
print("Money earned: $%.2f" % data.get("money_earned", 0.0))
print("========================")

func show_prestige_screen() -> void:
open_menu("prestige")

func show_shop() -> void:
open_menu("shop")

func show_inventory() -> void:
open_menu("inventory")

func show_upgrades() -> void:
open_menu("upgrades")

func show_settings() -> void:
open_menu("settings")

func hide_all() -> void:
close_all_menus()
