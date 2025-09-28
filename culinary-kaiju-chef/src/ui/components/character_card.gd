# character_card.gd - Epic 2: 角色卡片組件
extends Control

@onready var background: Panel = $Background
@onready var selected_background: Panel = $SelectedBackground
@onready var portrait: TextureRect = $VBoxContainer/Portrait
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel
@onready var health_label: Label = $VBoxContainer/StatsContainer/HealthLabel
@onready var speed_label: Label = $VBoxContainer/StatsContainer/SpeedLabel
@onready var damage_label: Label = $VBoxContainer/StatsContainer/DamageLabel
@onready var select_button: Button = $VBoxContainer/ButtonsContainer/SelectButton
@onready var unlock_button: Button = $VBoxContainer/ButtonsContainer/UnlockButton
@onready var locked_label: Label = $VBoxContainer/ButtonsContainer/LockedLabel

var character_data: CharacterData
var character_id: String
var unlock_cost: int = 0

signal character_selected(character_id: String)
signal character_unlock_requested(character_id: String, cost: int)

func _ready() -> void:
	select_button.pressed.connect(_on_select_button_pressed)
	unlock_button.pressed.connect(_on_unlock_button_pressed)
	
	# 連接玩家數據信號
	PlayerData.character_unlocked.connect(_on_character_unlocked)
	PlayerData.gold_changed.connect(_on_gold_changed)

func setup(character: CharacterData, char_id: String, cost: int = 0) -> void:
	character_data = character
	character_id = char_id
	unlock_cost = cost
	
	# 設置基本信息
	name_label.text = character.name
	description_label.text = character.description
	
	# 設置屬性顯示
	health_label.text = "生命值: %d" % character.max_health
	speed_label.text = "速度: %.0f" % character.movement_speed
	damage_label.text = "傷害: %.0f%%" % (character.damage_multiplier * 100)
	
	# 設置頭像
	if character.sprite_texture:
		portrait.texture = character.sprite_texture
	
	_update_display()

func _update_display() -> void:
	"""更新顯示狀態"""
	if not character_id:
		return
	
	var is_unlocked = character_id in PlayerData.unlocked_characters
	var is_selected = PlayerData.selected_character == character_id
	
	# 更新選中狀態
	selected_background.visible = is_selected
	
	if is_unlocked:
		# 已解鎖角色
		select_button.visible = true
		unlock_button.visible = false
		locked_label.visible = false
		
		# 更新選擇按鈕文字
		if is_selected:
			select_button.text = "已選中"
			select_button.disabled = true
		else:
			select_button.text = "選擇"
			select_button.disabled = false
		
		# 恢復正常顏色
		modulate = Color.WHITE
	else:
		# 未解鎖角色
		select_button.visible = false
		locked_label.visible = true
		
		# 顯示解鎖按鈕（如果不是免費角色）
		if unlock_cost > 0:
			unlock_button.visible = true
			unlock_button.text = "解鎖 (%d 金幣)" % unlock_cost
			_update_unlock_button()
		else:
			unlock_button.visible = false
		
		# 暗化顯示
		modulate = Color.GRAY

func _update_unlock_button() -> void:
	"""更新解鎖按鈕狀態"""
	if unlock_cost <= 0:
		return
	
	var can_afford = PlayerData.gold >= unlock_cost
	unlock_button.disabled = not can_afford
	
	if can_afford:
		unlock_button.modulate = Color.WHITE
	else:
		unlock_button.modulate = Color.GRAY

func update_unlock_button() -> void:
	"""外部調用的更新函數"""
	_update_unlock_button()

func update_selection() -> void:
	"""外部調用的選中狀態更新函數"""
	_update_display()

func _on_select_button_pressed() -> void:
	"""選擇按鈕被按下"""
	character_selected.emit(character_id)

func _on_unlock_button_pressed() -> void:
	"""解鎖按鈕被按下"""
	character_unlock_requested.emit(character_id, unlock_cost)

func _on_character_unlocked(unlocked_character_id: String) -> void:
	"""角色解鎖回調"""
	if unlocked_character_id == character_id:
		_update_display()

func _on_gold_changed(_new_amount: int) -> void:
	"""金幣變化回調"""
	_update_unlock_button()