# test_epic_features.gd - Epic 2 & 3 功能測試腳本
extends Node

func _ready() -> void:
	print("=== Epic 2 & 3 功能測試 ===")
	
	# 測試元進程系統
	test_meta_progression()
	
	# 測試角色系統
	test_character_system()
	
	# 測試廣告系統
	test_ad_system()

func test_meta_progression() -> void:
	print("\n--- Epic 2: 元進程系統測試 ---")
	
	# 給玩家一些金幣來測試
	PlayerData.add_gold(1000)
	print("Added 1000 gold. Current gold: ", PlayerData.gold)
	
	# 測試升級購買
	var health_upgrade = load("res://src/core/data/meta_upgrades/health_bonus.tres") as MetaUpgradeData
	if health_upgrade:
		print("Testing health upgrade purchase...")
		var success = PlayerData.purchase_meta_upgrade(health_upgrade)
		print("Purchase result: ", success)
		print("Current level: ", PlayerData.get_meta_upgrade_level(health_upgrade.id))
		print("Remaining gold: ", PlayerData.gold)

func test_character_system() -> void:
	print("\n--- Epic 2: 角色系統測試 ---")
	
	print("Unlocked characters: ", PlayerData.unlocked_characters)
	print("Selected character: ", PlayerData.selected_character)
	
	# 嘗試解鎖新角色
	var unlock_success = PlayerData.unlock_character("speed_chef", 500)
	print("Unlock speed_chef result: ", unlock_success)
	print("Updated unlocked characters: ", PlayerData.unlocked_characters)

func test_ad_system() -> void:
	print("\n--- Epic 3: 廣告系統測試 ---")
	
	print("Ads initialized: ", AdManager.ads_initialized)
	print("Can show rewarded ad: ", AdManager.can_show_rewarded_ad())
	print("Ads removed: ", PlayerData.ads_removed)
	
	# 模擬觀看廣告
	if AdManager.can_show_rewarded_ad():
		print("Testing rewarded ad...")
		AdManager.show_rewarded_ad("test_reward")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				# 測試打開元進程升級界面
				get_tree().change_scene_to_file("res://src/ui/screens/meta_upgrade_screen.tscn")
			KEY_2:
				# 測試打開角色選擇界面
				get_tree().change_scene_to_file("res://src/ui/screens/character_select_screen.tscn")
			KEY_3:
				# 測試遊戲結束界面
				test_game_over_screen()

func test_game_over_screen() -> void:
	var game_over_scene = preload("res://src/ui/screens/game_over_screen.tscn")
	var game_over_instance = game_over_scene.instantiate()
	get_tree().root.add_child(game_over_instance)
	
	# 模擬遊戲數據
	var test_stats = {
		"score": 1250,
		"time": 185.5,
		"kills": 47
	}
	
	game_over_instance.show_game_over(test_stats)