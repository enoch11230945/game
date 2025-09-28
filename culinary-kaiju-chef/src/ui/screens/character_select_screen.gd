# character_select_screen.gd - Epic 2: 角色選擇系統
extends Control

@onready var back_button: Button = $VBoxContainer/Header/BackButton
@onready var gold_label: Label = $VBoxContainer/Header/GoldLabel
@onready var characters_container: HBoxContainer = $VBoxContainer/ScrollContainer/CharactersContainer
@onready var start_button: Button = $VBoxContainer/StartButton

var character_card_scene = preload("res://src/ui/components/character_card.tscn")
var available_characters: Array[CharacterData] = []

func _ready() -> void:
	# 連接信號
	back_button.pressed.connect(_on_back_button_pressed)
	start_button.pressed.connect(_on_start_button_pressed)
	PlayerData.gold_changed.connect(_on_gold_changed)
	PlayerData.character_unlocked.connect(_on_character_unlocked)
	
	# 載入角色數據
	_load_characters()
	_setup_character_cards()
	_update_gold_display()

func _load_characters() -> void:
	"""載入所有可用角色"""
	# 這裡應該從 DataManager 或直接從文件系統載入
	# 暫時創建一些測試角色數據
	
	var default_chef = CharacterData.new()
	default_chef.name = "經典大廚"
	default_chef.description = "平衡型角色，適合新手"
	default_chef.max_health = 100
	default_chef.movement_speed = 300.0
	default_chef.damage_multiplier = 1.0
	
	var speed_chef = CharacterData.new()
	speed_chef.name = "疾風廚師"  
	speed_chef.description = "移動速度快，但血量較低"
	speed_chef.max_health = 75
	speed_chef.movement_speed = 400.0
	speed_chef.damage_multiplier = 0.9
	speed_chef.speed_multiplier = 1.3
	
	var tank_chef = CharacterData.new()
	tank_chef.name = "重裝主廚"
	tank_chef.description = "高血量高傷害，但移動較慢"
	tank_chef.max_health = 150
	tank_chef.movement_speed = 250.0
	tank_chef.damage_multiplier = 1.2
	tank_chef.speed_multiplier = 0.8
	
	available_characters = [default_chef, speed_chef, tank_chef]

func _setup_character_cards() -> void:
	"""設置角色卡片"""
	# 清除現有卡片
	for child in characters_container.get_children():
		child.queue_free()
	
	# 為每個角色創建卡片
	for i in range(available_characters.size()):
		var character = available_characters[i]
		var card = character_card_scene.instantiate()
		characters_container.add_child(card)
		
		# 設置角色 ID
		var character_id = _get_character_id(i)
		card.setup(character, character_id, _get_unlock_cost(i))
		card.character_selected.connect(_on_character_selected)
		card.character_unlock_requested.connect(_on_character_unlock_requested)

func _get_character_id(index: int) -> String:
	"""獲取角色 ID"""
	match index:
		0: return "default_chef"
		1: return "speed_chef"  
		2: return "tank_chef"
		_: return "unknown_chef"

func _get_unlock_cost(index: int) -> int:
	"""獲取解鎖費用"""
	match index:
		0: return 0      # 免費角色
		1: return 500    # 疾風廚師
		2: return 1000   # 重裝主廚
		_: return 999999

func _update_gold_display() -> void:
	gold_label.text = "金幣: " + str(PlayerData.gold)

func _on_gold_changed(new_amount: int) -> void:
	_update_gold_display()
	# 更新所有卡片的解鎖按鈕狀態
	for child in characters_container.get_children():
		if child.has_method("update_unlock_button"):
			child.update_unlock_button()

func _on_character_unlocked(character_id: String) -> void:
	"""角色解鎖回調"""
	print("Character unlocked: ", character_id)
	# 卡片會自動更新顯示

func _on_character_selected(character_id: String) -> void:
	"""角色被選中"""
	PlayerData.select_character(character_id)
	print("Character selected: ", character_id)
	
	# 更新所有卡片的選中狀態
	for child in characters_container.get_children():
		if child.has_method("update_selection"):
			child.update_selection()

func _on_character_unlock_requested(character_id: String, cost: int) -> void:
	"""請求解鎖角色"""
	if PlayerData.unlock_character(character_id, cost):
		print("Successfully unlocked character: ", character_id)
		# 播放解鎖音效
		if AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("character_unlock")
	else:
		print("Failed to unlock character: ", character_id)
		# 播放錯誤音效
		if AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("error")

func _on_start_button_pressed() -> void:
	"""開始遊戲"""
	# 確保有選中的角色
	if PlayerData.selected_character.is_empty():
		PlayerData.select_character("default_chef")
	
	# 進入遊戲
	get_tree().change_scene_to_file("res://src/main/main.tscn")

func _on_back_button_pressed() -> void:
	"""返回主選單"""
	get_tree().change_scene_to_file("res://src/ui/screens/main_menu.tscn")