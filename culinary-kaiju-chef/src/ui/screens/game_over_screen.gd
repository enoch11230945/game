# game_over_screen.gd - Epic 3: 遊戲結束界面與廣告整合
extends Control

# UI 元素
@onready var score_label: Label = $CenterContainer/VBoxContainer/ScoreContainer/ScoreLabel
@onready var time_label: Label = $CenterContainer/VBoxContainer/ScoreContainer/TimeLabel
@onready var kills_label: Label = $CenterContainer/VBoxContainer/ScoreContainer/KillsLabel
@onready var gold_earned_label: Label = $CenterContainer/VBoxContainer/ScoreContainer/GoldEarnedLabel

# 復活相關
@onready var revive_container: VBoxContainer = $CenterContainer/VBoxContainer/ButtonsContainer/ReviveContainer
@onready var revive_button: Button = $CenterContainer/VBoxContainer/ButtonsContainer/ReviveContainer/ReviveButton
@onready var revive_timer_label: Label = $CenterContainer/VBoxContainer/ButtonsContainer/ReviveContainer/ReviveTimer

# 獎勵相關
@onready var reward_container: VBoxContainer = $CenterContainer/VBoxContainer/ButtonsContainer/RewardContainer
@onready var double_gold_button: Button = $CenterContainer/VBoxContainer/ButtonsContainer/RewardContainer/DoubleGoldButton

# 基本按鈕
@onready var restart_button: Button = $CenterContainer/VBoxContainer/ButtonsContainer/FinalButtonsContainer/RestartButton
@onready var upgrades_button: Button = $CenterContainer/VBoxContainer/ButtonsContainer/FinalButtonsContainer/UpgradesButton
@onready var main_menu_button: Button = $CenterContainer/VBoxContainer/ButtonsContainer/FinalButtonsContainer/MainMenuButton

# 遊戲數據
var game_stats: Dictionary = {}
var revive_available: bool = true
var revive_time_left: float = 10.0

func _ready() -> void:
	# 連接按鈕信號
	revive_button.pressed.connect(_on_revive_button_pressed)
	double_gold_button.pressed.connect(_on_double_gold_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	upgrades_button.pressed.connect(_on_upgrades_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	
	# 連接廣告系統信號
	AdManager.rewarded_ad_completed_successfully.connect(_on_rewarded_ad_completed)
	AdManager.rewarded_ad_failed_to_show.connect(_on_rewarded_ad_failed)
	
	# 連接事件總線
	EventBus.connect("player_revived_by_ad", _on_player_revived)
	EventBus.connect("gold_doubled_by_ad", _on_gold_doubled)

func _process(delta: float) -> void:
	if revive_available and revive_time_left > 0:
		revive_time_left -= delta
		revive_timer_label.text = "復活機會剩餘: %d 秒" % int(revive_time_left)
		
		if revive_time_left <= 0:
			_disable_revive_option()

func show_game_over(stats: Dictionary) -> void:
	"""顯示遊戲結束界面"""
	game_stats = stats
	_update_stats_display()
	_setup_revive_option()
	_setup_reward_options()
	
	# 顯示界面
	show()
	
	# 更新 PlayerData
	PlayerData.update_game_stats(
		stats.get("score", 0),
		stats.get("time", 0.0),
		stats.get("kills", 0)
	)

func _update_stats_display() -> void:
	"""更新統計顯示"""
	score_label.text = "分數: %d" % game_stats.get("score", 0)
	
	var time_seconds = game_stats.get("time", 0.0)
	var minutes = int(time_seconds / 60)
	var seconds = int(time_seconds) % 60
	time_label.text = "存活時間: %d:%02d" % [minutes, seconds]
	
	kills_label.text = "擊殺: %d" % game_stats.get("kills", 0)
	
	var gold_earned = game_stats.get("score", 0) / 100  # 每100分 = 1金幣
	gold_earned_label.text = "獲得金幣: %d" % gold_earned
	
	# 保存金幣數據用於雙倍獎勵
	PlayerData.last_run["gold_earned"] = gold_earned

func _setup_revive_option() -> void:
	"""設置復活選項"""
	# 檢查是否允許復活（例如：一局只能復活一次）
	revive_available = true  # 這裡可以加入更複雜的邏輯
	
	if revive_available and AdManager.can_show_rewarded_ad():
		revive_container.show()
		revive_time_left = 10.0  # 10秒倒數
	else:
		revive_container.hide()

func _setup_reward_options() -> void:
	"""設置獎勵選項"""
	if AdManager.can_show_rewarded_ad():
		reward_container.show()
		
		# 如果玩家已購買去廣告，修改按鈕文字
		if PlayerData.ads_removed:
			double_gold_button.text = "獲得雙倍金幣"
		else:
			double_gold_button.text = "看廣告獲得雙倍金幣"
	else:
		reward_container.hide()

func _disable_revive_option() -> void:
	"""禁用復活選項"""
	revive_available = false
	revive_container.hide()

# === 廣告相關回調 ===

func _on_revive_button_pressed() -> void:
	"""復活按鈕被按下"""
	if not revive_available:
		return
	
	print("Player chose to revive by watching ad")
	AdManager.show_rewarded_ad("revive")
	
	# 禁用復活按鈕，防止重複點擊
	revive_button.disabled = true

func _on_double_gold_button_pressed() -> void:
	"""雙倍金幣按鈕被按下"""
	print("Player chose to double gold by watching ad")
	AdManager.show_rewarded_ad("double_gold")
	
	# 禁用按鈕，防止重複點擊
	double_gold_button.disabled = true

func _on_rewarded_ad_completed() -> void:
	"""廣告觀看完成"""
	print("Rewarded ad completed successfully")
	# 具體獎勵處理在 AdManager 中完成

func _on_rewarded_ad_failed(error: String) -> void:
	"""廣告顯示失敗"""
	print("Failed to show rewarded ad: ", error)
	
	# 重新啟用按鈕
	revive_button.disabled = false
	double_gold_button.disabled = false
	
	# 顯示錯誤消息（可選）
	# TODO: 添加錯誤提示 UI

func _on_player_revived() -> void:
	"""玩家被廣告復活"""
	print("Player has been revived!")
	# 隱藏遊戲結束界面，返回遊戲
	hide()
	# TODO: 通知遊戲管理器恢復遊戲

func _on_gold_doubled(extra_gold: int) -> void:
	"""金幣已翻倍"""
	print("Gold doubled! Extra gold: ", extra_gold)
	# 更新顯示
	_update_stats_display()
	
	# 播放特效或聲音
	# TODO: 添加金幣獲得特效

# === 基本按鈕回調 ===

func _on_restart_button_pressed() -> void:
	"""重新開始遊戲"""
	get_tree().change_scene_to_file("res://src/main/main.tscn")

func _on_upgrades_button_pressed() -> void:
	"""前往永久升級界面"""
	get_tree().change_scene_to_file("res://src/ui/screens/meta_upgrade_screen.tscn")

func _on_main_menu_button_pressed() -> void:
	"""返回主選單"""
	get_tree().change_scene_to_file("res://src/ui/screens/main_menu.tscn")