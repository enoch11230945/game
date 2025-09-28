# meta_upgrade_screen.gd - Epic 2: 元進程升級界面
extends Control

@onready var gold_label: Label = $VBoxContainer/Header/GoldLabel
@onready var upgrades_container: VBoxContainer = $VBoxContainer/ScrollContainer/UpgradesContainer
@onready var back_button: Button = $VBoxContainer/BackButton

var upgrade_card_scene = preload("res://src/ui/components/upgrade_card.tscn")
var meta_upgrades: Array[MetaUpgradeData] = []

func _ready() -> void:
	# 連接信號
	back_button.pressed.connect(_on_back_button_pressed)
	PlayerData.gold_changed.connect(_on_gold_changed)
	PlayerData.meta_upgrade_purchased.connect(_on_meta_upgrade_purchased)
	
	# 加載所有元進程升級
	_load_meta_upgrades()
	_setup_upgrade_cards()
	_update_gold_display()

func _load_meta_upgrades() -> void:
	# 加載所有升級資源
	var upgrades_path = "res://src/core/data/meta_upgrades/"
	var dir = DirAccess.open(upgrades_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".tres"):
				var upgrade = load(upgrades_path + file_name) as MetaUpgradeData
				if upgrade:
					meta_upgrades.append(upgrade)
			file_name = dir.get_next()
	
	print("Loaded ", meta_upgrades.size(), " meta upgrades")

func _setup_upgrade_cards() -> void:
	# 清除現有卡片
	for child in upgrades_container.get_children():
		child.queue_free()
	
	# 為每個升級創建卡片
	for upgrade in meta_upgrades:
		var card = upgrade_card_scene.instantiate()
		upgrades_container.add_child(card)
		card.setup(upgrade)
		card.upgrade_purchased.connect(_on_upgrade_card_purchased)

func _update_gold_display() -> void:
	gold_label.text = "金幣: " + str(PlayerData.gold)

func _on_gold_changed(new_amount: int) -> void:
	_update_gold_display()
	# 更新所有卡片的可購買狀態
	for child in upgrades_container.get_children():
		if child.has_method("update_purchase_button"):
			child.update_purchase_button()

func _on_meta_upgrade_purchased(upgrade_id: String, new_level: int) -> void:
	print("Upgrade purchased: ", upgrade_id, " Level: ", new_level)
	# 卡片會自動更新，因為它們監聽 PlayerData 信號

func _on_upgrade_card_purchased(upgrade_data: MetaUpgradeData) -> void:
	# 嘗試購買升級
	if PlayerData.purchase_meta_upgrade(upgrade_data):
		print("Successfully purchased: ", upgrade_data.display_name)
		# 播放購買音效
		if AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("purchase")
	else:
		print("Failed to purchase: ", upgrade_data.display_name)
		# 播放錯誤音效
		if AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("error")

func _on_back_button_pressed() -> void:
	# 返回主選單
	get_tree().change_scene_to_file("res://src/ui/screens/main_menu.tscn")