class_name MainMenu
extends Control

signal sub_menu_opened
signal sub_menu_closed
signal game_started
signal game_exited

## Defines the path to the game scene. Hides the play button if empty.
@export_file("*.tscn") var game_scene_path : String
@export var options_packed_scene : PackedScene
@export var credits_packed_scene : PackedScene
@export_group("Extra Settings")
@export var signal_game_start : bool = false
@export var signal_game_exit : bool = false

var options_scene
var credits_scene
var sub_menu

@onready var menu_container = %MenuContainer
@onready var menu_buttons_box_container = %MenuButtonsBoxContainer
@onready var new_game_button = %NewGameButton
@onready var options_button = %OptionsButton
@onready var credits_button = %CreditsButton
@onready var exit_button = %ExitButton
@onready var options_container = %OptionsContainer
@onready var credits_container = %CreditsContainer
@onready var flow_control_container = %FlowControlContainer
@onready var back_button = %BackButton

# Epic 2 & 3: 新增按鈕
@onready var character_select_button = %CharacterSelectButton
@onready var meta_upgrades_button = %MetaUpgradesButton
@onready var gold_label = %GoldLabel

func _ready() -> void:
	# 連接新按鈕的信號
	if character_select_button:
		character_select_button.pressed.connect(_on_character_select_pressed)
	if meta_upgrades_button:
		meta_upgrades_button.pressed.connect(_on_meta_upgrades_pressed)
	
	# 連接玩家數據信號
	PlayerData.gold_changed.connect(_on_gold_changed)
	
	# 更新金幣顯示
	_update_gold_display()

func load_game_scene() -> void:
	# 確保玩家已選擇角色
	if PlayerData.selected_character.is_empty():
		PlayerData.select_character("default_chef")
	
	# 使用正確的主場景路徑
	var target_scene_path := "res://src/main/main.tscn"
	if signal_game_start:
		SceneLoader.load_scene(target_scene_path, true)
		game_started.emit()
	else:
		SceneLoader.load_scene(target_scene_path)

func new_game() -> void:
	load_game_scene()

# Epic 2 & 3: 新增功能函數
func _on_character_select_pressed() -> void:
	"""角色選擇按鈕"""
	get_tree().change_scene_to_file("res://src/ui/screens/character_select_screen.tscn")

func _on_meta_upgrades_pressed() -> void:
	"""永久升級按鈕"""
	get_tree().change_scene_to_file("res://src/ui/screens/meta_upgrade_screen.tscn")

func _on_gold_changed(new_amount: int) -> void:
	"""金幣變化回調"""
	_update_gold_display()

func _update_gold_display() -> void:
	"""更新金幣顯示"""
	if gold_label:
		gold_label.text = "金幣: " + str(PlayerData.gold)

func exit_game() -> void:
	if OS.has_feature("web"):
		return
	if signal_game_exit:
		game_exited.emit()
	else:
		get_tree().quit()

func _hide_menu() -> void:
	back_button.show()
	menu_container.hide()

func _show_menu() -> void:
	back_button.hide()
	menu_container.show()

func _open_sub_menu(menu : Control) -> void:
	sub_menu = menu
	sub_menu.show()
	_hide_menu()
	sub_menu_opened.emit()

func _close_sub_menu() -> void:
	if sub_menu == null:
		return
	sub_menu.hide()
	sub_menu = null
	_show_menu()
	sub_menu_closed.emit()

func _event_is_mouse_button_released(event : InputEvent) -> bool:
	return event is InputEventMouseButton and not event.is_pressed()

func _input(event : InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		if sub_menu:
			_close_sub_menu()
		else:
			exit_game()
	if event.is_action_released("ui_accept") and get_viewport().gui_get_focus_owner() == null:
		menu_buttons_box_container.focus_first()

func _hide_exit_for_web() -> void:
	if OS.has_feature("web"):
		exit_button.hide()

func _hide_new_game_if_unset() -> void:
	if game_scene_path.is_empty():
		new_game_button.hide()

func _add_or_hide_options() -> void:
	if options_packed_scene == null:
		options_button.hide()
	else:
		options_scene = options_packed_scene.instantiate()
		options_scene.hide()
		options_container.show()
		options_container.call_deferred("add_child", options_scene)

func _add_or_hide_credits() -> void:
	if credits_packed_scene == null:
		credits_button.hide()
	else:
		credits_scene = credits_packed_scene.instantiate()
		credits_scene.hide()
		if credits_scene.has_signal("end_reached"):
			credits_scene.connect("end_reached", _on_credits_end_reached)
		credits_container.show()
		credits_container.call_deferred("add_child", credits_scene)

func _ready() -> void:
	flow_control_container.show()
	_hide_exit_for_web()
	_add_or_hide_options()
	_add_or_hide_credits()
	_hide_new_game_if_unset()

func _on_new_game_button_pressed() -> void:
	new_game()

func _on_options_button_pressed() -> void:
	_open_sub_menu(options_scene)

func _on_credits_button_pressed() -> void:
	_open_sub_menu(credits_scene)

func _on_exit_button_pressed() -> void:
	exit_game()

func _on_credits_end_reached() -> void:
	if sub_menu == credits_scene:
		_close_sub_menu()

func _on_back_button_pressed() -> void:
	_close_sub_menu()
