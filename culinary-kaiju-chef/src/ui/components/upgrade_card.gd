# upgrade_card.gd - Epic 2: 元進程升級卡片
extends Control

@onready var icon: TextureRect = $HBoxContainer/IconContainer/Icon
@onready var name_label: Label = $HBoxContainer/InfoContainer/NameLabel
@onready var description_label: Label = $HBoxContainer/InfoContainer/DescriptionLabel
@onready var level_label: Label = $HBoxContainer/InfoContainer/LevelLabel
@onready var cost_label: Label = $HBoxContainer/ButtonContainer/CostLabel
@onready var purchase_button: Button = $HBoxContainer/ButtonContainer/PurchaseButton

var upgrade_data: MetaUpgradeData
signal upgrade_purchased(upgrade_data: MetaUpgradeData)

func _ready() -> void:
	purchase_button.pressed.connect(_on_purchase_button_pressed)
	PlayerData.gold_changed.connect(_on_gold_changed)
	PlayerData.meta_upgrade_purchased.connect(_on_meta_upgrade_purchased)

func setup(upgrade: MetaUpgradeData) -> void:
	upgrade_data = upgrade
	
	# 設置基本信息
	name_label.text = upgrade.display_name
	
	if upgrade.icon:
		icon.texture = upgrade.icon
	
	_update_display()

func _update_display() -> void:
	if not upgrade_data:
		return
	
	var current_level = PlayerData.get_meta_upgrade_level(upgrade_data.id)
	var is_max_level = current_level >= upgrade_data.max_level
	
	# 更新等級顯示
	level_label.text = "等級: %d/%d" % [current_level, upgrade_data.max_level]
	
	# 更新描述（顯示下一級的效果）
	if is_max_level:
		description_label.text = upgrade_data.get_formatted_description(current_level) + " (已滿級)"
	else:
		var next_level = current_level + 1
		description_label.text = upgrade_data.get_formatted_description(next_level)
	
	# 更新購買按鈕
	if is_max_level:
		cost_label.text = "已滿級"
		purchase_button.text = "已滿級"
		purchase_button.disabled = true
	else:
		var cost = upgrade_data.get_cost_for_level(current_level)
		cost_label.text = "花費: %d 金幣" % cost
		purchase_button.text = "升級"
		_update_purchase_button()

func _update_purchase_button() -> void:
	if not upgrade_data:
		return
		
	var current_level = PlayerData.get_meta_upgrade_level(upgrade_data.id)
	var is_max_level = current_level >= upgrade_data.max_level
	
	if is_max_level:
		return
	
	var cost = upgrade_data.get_cost_for_level(current_level)
	var can_afford = PlayerData.gold >= cost
	
	purchase_button.disabled = not can_afford
	
	if can_afford:
		purchase_button.modulate = Color.WHITE
	else:
		purchase_button.modulate = Color.GRAY

func update_purchase_button() -> void:
	_update_purchase_button()

func _on_purchase_button_pressed() -> void:
	upgrade_purchased.emit(upgrade_data)

func _on_gold_changed(_new_amount: int) -> void:
	_update_purchase_button()

func _on_meta_upgrade_purchased(upgrade_id: String, new_level: int) -> void:
	if upgrade_data and upgrade_data.id == upgrade_id:
		_update_display()