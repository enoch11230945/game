# AdManager.gd - Epic 3: 廣告整合系統
extends Node

# 廣告類型枚舉
enum AdType {
	REWARDED_VIDEO,    # 激勵式影片廣告
	INTERSTITIAL      # 插頁廣告（暫不使用）
}

# 廣告狀態
var ads_initialized: bool = false
var rewarded_ad_loaded: bool = false
var test_mode: bool = true  # 開發階段使用測試廣告

# 廣告回調信號
signal rewarded_ad_loaded_successfully
signal rewarded_ad_failed_to_load(error_message: String)
signal rewarded_ad_showed
signal rewarded_ad_completed_successfully
signal rewarded_ad_failed_to_show(error_message: String)
signal rewarded_ad_dismissed

func _ready() -> void:
	# 連接到 PlayerData 信號
	if PlayerData.has_signal("data_loaded"):
		PlayerData.data_loaded.connect(_on_player_data_loaded)
	
	# 初始化廣告系統
	_initialize_ads()

func _initialize_ads() -> void:
	# TODO: 實際的 AdMob SDK 初始化
	# 這裡應該檢查平台並初始化相應的廣告插件
	
	if OS.get_name() == "Android":
		_initialize_android_ads()
	elif OS.get_name() == "iOS":
		_initialize_ios_ads()
	else:
		# 桌面平台或 Web - 使用模擬廣告
		_initialize_mock_ads()

func _initialize_android_ads() -> void:
	# TODO: 實際的 Android AdMob 初始化
	print("Initializing Android AdMob...")
	# var admob = Engine.get_singleton("GodotAdMob")
	# if admob:
	#     admob.initialize()
	#     admob.load_rewarded_video("ca-app-pub-XXXXXXXX~XXXXXXXX")
	
	# 暫時使用模擬系統
	_initialize_mock_ads()

func _initialize_ios_ads() -> void:
	# TODO: 實際的 iOS AdMob 初始化
	print("Initializing iOS AdMob...")
	_initialize_mock_ads()

func _initialize_mock_ads() -> void:
	print("Initializing Mock Ad System for testing...")
	ads_initialized = true
	rewarded_ad_loaded = true
	rewarded_ad_loaded_successfully.emit()

# === Epic 3 核心功能：激勵式廣告 ===

func show_rewarded_ad(reward_type: String = "default") -> void:
	"""顯示激勵式廣告"""
	if not ads_initialized:
		print("Ads not initialized")
		rewarded_ad_failed_to_show.emit("Ads not initialized")
		return
	
	if PlayerData.ads_removed:
		# 如果玩家已購買去廣告，直接給予獎勵
		_grant_reward_directly(reward_type)
		return
	
	if not rewarded_ad_loaded:
		print("Rewarded ad not loaded")
		rewarded_ad_failed_to_show.emit("Ad not loaded")
		return
	
	_show_rewarded_video(reward_type)

func _show_rewarded_video(reward_type: String) -> void:
	"""顯示激勵式影片廣告"""
	print("Showing rewarded video ad for: ", reward_type)
	
	# TODO: 實際的廣告顯示代碼
	# var admob = Engine.get_singleton("GodotAdMob")
	# if admob:
	#     admob.show_rewarded_video()
	
	# 模擬廣告顯示
	rewarded_ad_showed.emit()
	
	# 模擬廣告完成（實際情況下這會在廣告插件的回調中觸發）
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0  # 模擬 2 秒廣告
	timer.one_shot = true
	timer.timeout.connect(func(): 
		_on_rewarded_ad_completed(reward_type)
		timer.queue_free()
	)
	timer.start()

func _grant_reward_directly(reward_type: String) -> void:
	"""直接給予獎勵（用於去廣告玩家）"""
	print("Granting reward directly (ads removed): ", reward_type)
	_process_reward(reward_type)

func _on_rewarded_ad_completed(reward_type: String) -> void:
	"""廣告觀看完成回調"""
	print("Rewarded ad completed successfully")
	PlayerData.watch_rewarded_ad()  # 更新廣告觀看統計
	rewarded_ad_completed_successfully.emit()
	
	# 處理獎勵
	_process_reward(reward_type)
	
	# 重新載入廣告
	_load_next_rewarded_ad()

func _process_reward(reward_type: String) -> void:
	"""處理廣告獎勵"""
	match reward_type:
		"revive":
			_grant_revive_reward()
		"double_gold":
			_grant_double_gold_reward()
		"daily_bonus":
			_grant_daily_bonus_reward()
		"extra_gold":
			_grant_extra_gold_reward()
		_:
			print("Unknown reward type: ", reward_type)

func _grant_revive_reward() -> void:
	"""給予復活獎勵"""
	EventBus.emit("player_revived_by_ad")
	print("Player revived by watching ad")

func _grant_double_gold_reward() -> void:
	"""給予金幣翻倍獎勵"""
	if PlayerData.last_run.has("gold_earned"):
		var extra_gold = PlayerData.last_run.gold_earned
		PlayerData.add_gold(extra_gold)
		EventBus.emit("gold_doubled_by_ad", extra_gold)
		print("Gold doubled by ad: +", extra_gold)

func _grant_daily_bonus_reward() -> void:
	"""給予每日獎勵"""
	var bonus_gold = 50 + PlayerData.total_games_played * 2  # 隨遊戲次數增加
	PlayerData.add_gold(bonus_gold)
	EventBus.emit("daily_bonus_claimed", bonus_gold)
	print("Daily bonus claimed: +", bonus_gold, " gold")

func _grant_extra_gold_reward() -> void:
	"""給予額外金幣獎勵"""
	var extra_gold = 25
	PlayerData.add_gold(extra_gold)
	EventBus.emit("extra_gold_earned", extra_gold)
	print("Extra gold earned: +", extra_gold)

func _load_next_rewarded_ad() -> void:
	"""載入下一個激勵式廣告"""
	# TODO: 實際的廣告載入代碼
	# var admob = Engine.get_singleton("GodotAdMob")
	# if admob:
	#     admob.load_rewarded_video("ca-app-pub-XXXXXXXX~XXXXXXXX")
	
	# 模擬載入
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.timeout.connect(func():
		rewarded_ad_loaded = true
		rewarded_ad_loaded_successfully.emit()
		timer.queue_free()
	)
	timer.start()

# === 工具函數 ===

func can_show_rewarded_ad() -> bool:
	"""檢查是否可以顯示激勵式廣告"""
	return ads_initialized and (rewarded_ad_loaded or PlayerData.ads_removed)

func is_ads_removed() -> bool:
	"""檢查玩家是否已購買去廣告"""
	return PlayerData.ads_removed

func _on_player_data_loaded() -> void:
	"""玩家數據載入完成回調"""
	# 可以在此處更新廣告相關設定