extends Control

# 升级卡片UI组件
class_name UpgradeCardUI

@onready var card_background: NinePatchRect = $CardBackground
@onready var icon: TextureRect = $VBoxContainer/Icon
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel
@onready var rarity_indicator: ColorRect = $RarityIndicator

var upgrade_data: UpgradeData
var card_index: int = 0

# 稀有度颜色
const RARITY_COLORS = {
	"common": Color(0.8, 0.8, 0.8),      # 灰色
	"rare": Color(0.2, 0.8, 0.2),        # 绿色
	"epic": Color(0.2, 0.4, 1.0),        # 蓝色
	"legendary": Color(1.0, 0.8, 0.0)    # 金色
}

signal card_selected(upgrade_data: UpgradeData)

func _ready():
	# 设置卡片交互
	card_background.gui_input.connect(_on_card_input)
	card_background.mouse_entered.connect(_on_card_hover_start)
	card_background.mouse_exited.connect(_on_card_hover_end)

func setup_card(data: UpgradeData, index: int):
	upgrade_data = data
	card_index = index
	
	if not data:
		return
	
	# 设置文本内容
	title_label.text = data.name
	description_label.text = data.description
	
	# 设置图标
	if data.icon:
		icon.texture = data.icon
		icon.visible = true
	else:
		icon.visible = false
	
	# 设置稀有度指示器
	if data.rarity and RARITY_COLORS.has(data.rarity):
		rarity_indicator.color = RARITY_COLORS[data.rarity]
	else:
		rarity_indicator.color = RARITY_COLORS["common"]
	
	# 设置卡片样式
	_setup_card_appearance()

func _setup_card_appearance():
	# 设置卡片背景样式
	if card_background:
		card_background.modulate = Color.WHITE
		
	# 设置文本样式
	if title_label:
		title_label.add_theme_color_override("font_color", Color.WHITE)
		title_label.add_theme_font_size_override("font_size", 18)
		
	if description_label:
		description_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		description_label.add_theme_font_size_override("font_size", 14)

func _on_card_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_select_card()

func _on_card_hover_start():
	# 播放悬停音效
	if AudioManager:
		AudioManager.play_sfx("select")
	
	# 卡片悬停效果
	var tween = create_tween()
	tween.tween_property(card_background, "modulate", Color(1.2, 1.2, 1.2), 0.1)
	tween.parallel().tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)

func _on_card_hover_end():
	# 恢复卡片样式
	var tween = create_tween()
	tween.tween_property(card_background, "modulate", Color.WHITE, 0.1)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.1)

func _select_card():
	# 播放选择音效
	if AudioManager:
		AudioManager.play_sfx("upgrade")
	
	# 发出选择信号
	card_selected.emit(upgrade_data)
	
	# 选择动画
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)