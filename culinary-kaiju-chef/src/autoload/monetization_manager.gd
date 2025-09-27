extends Node

# 商业化管理器 - 处理广告和IAP
class_name MonetizationManager

# 商业化状态
var ads_removed: bool = false
var premium_purchased: bool = false

# IAP产品ID
const REMOVE_ADS_PRODUCT_ID = "remove_ads"
const PREMIUM_UPGRADE_PRODUCT_ID = "premium_upgrade"

# 广告相关
var rewarded_ad_available: bool = true
var last_ad_time: float = 0.0
var ad_cooldown: float = 30.0  # 广告冷却时间（秒）

signal ad_watched(reward_type: String)
signal purchase_completed(product_id: String)
signal purchase_failed(error: String)

func _ready():
	# 加载购买状态
	_load_purchase_data()
	
	# 连接事件
	EventBus.player_died.connect(_on_player_died)
	EventBus.game_completed.connect(_on_game_completed)

func _load_purchase_data():
	"""从本地存储加载购买状态"""
	var save_file = "user://purchases.save"
	if FileAccess.file_exists(save_file):
		var file = FileAccess.open(save_file, FileAccess.READ)
		if file:
			var data = file.get_var()
			ads_removed = data.get("ads_removed", false)
			premium_purchased = data.get("premium_purchased", false)
			file.close()

func _save_purchase_data():
	"""保存购买状态到本地存储"""
	var save_file = "user://purchases.save"
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	if file:
		var data = {
			"ads_removed": ads_removed,
			"premium_purchased": premium_purchased
		}
		file.store_var(data)
		file.close()

# === 广告系统 ===

func can_show_rewarded_ad() -> bool:
	"""检查是否可以显示激励视频广告"""
	if ads_removed:
		return false
		
	var current_time = Time.get_unix_time_from_system()
	return rewarded_ad_available and (current_time - last_ad_time) >= ad_cooldown

func show_rewarded_ad(reward_type: String = "general"):
	"""显示激励视频广告"""
	if not can_show_rewarded_ad():
		print("⚠️ 广告暂时不可用")
		return false
	
	# 这里集成真实的广告SDK（如AdMob）
	# 现在用模拟实现
	_simulate_ad_viewing(reward_type)
	return true

func _simulate_ad_viewing(reward_type: String):
	"""模拟广告观看过程（生产环境中替换为真实广告SDK）"""
	print("🎥 正在播放激励视频广告...")
	
	# 模拟广告播放时间
	await get_tree().create_timer(3.0).timeout
	
	# 广告观看成功
	last_ad_time = Time.get_unix_time_from_system()
	ad_watched.emit(reward_type)
	AudioManager.play_sfx("victory")
	
	print("✅ 广告播放完成，获得奖励！")

func _on_player_died():
	"""玩家死亡时提供复活机会"""
	if can_show_rewarded_ad():
		# 这里应该显示复活UI
		EventBus.show_revive_offer.emit()

func _on_game_completed():
	"""游戏完成时提供奖励加倍"""
	if can_show_rewarded_ad():
		EventBus.show_reward_double_offer.emit()

# === IAP系统 ===

func purchase_remove_ads():
	"""购买去除广告"""
	if ads_removed:
		print("⚠️ 广告已经被移除")
		return
		
	# 这里集成真实的IAP系统（如Google Play Billing）
	# 现在用模拟实现
	_simulate_purchase(REMOVE_ADS_PRODUCT_ID, 2.99)

func purchase_premium_upgrade():
	"""购买高级版升级"""
	if premium_purchased:
		print("⚠️ 高级版已经购买")
		return
		
	_simulate_purchase(PREMIUM_UPGRADE_PRODUCT_ID, 4.99)

func _simulate_purchase(product_id: String, price: float):
	"""模拟购买过程（生产环境中替换为真实IAP系统）"""
	print("💳 正在处理购买: %s (￥%.2f)" % [product_id, price])
	
	# 模拟支付处理时间
	await get_tree().create_timer(2.0).timeout
	
	# 模拟90%的成功率
	if randf() < 0.9:
		_complete_purchase(product_id)
	else:
		purchase_failed.emit("支付失败，请重试")

func _complete_purchase(product_id: String):
	"""完成购买处理"""
	match product_id:
		REMOVE_ADS_PRODUCT_ID:
			ads_removed = true
			print("✅ 广告已移除！")
		PREMIUM_UPGRADE_PRODUCT_ID:
			premium_purchased = true
			print("✅ 高级版已激活！")
	
	_save_purchase_data()
	purchase_completed.emit(product_id)
	AudioManager.play_sfx("upgrade")

# === 奖励处理 ===

func apply_ad_reward(reward_type: String):
	"""应用广告奖励"""
	match reward_type:
		"revive":
			EventBus.player_revived.emit()
			print("✅ 玩家通过广告复活！")
		"double_coins":
			var bonus_coins = PlayerData.get_session_coins()
			PlayerData.add_coins(bonus_coins)
			print("✅ 金币已翻倍！获得 %d 额外金币" % bonus_coins)
		"bonus_xp":
			EventBus.bonus_xp_granted.emit(100)
			print("✅ 获得100经验值奖励！")
		"general":
			PlayerData.add_coins(50)
			print("✅ 获得50金币奖励！")

# === 商店UI支持 ===

func get_shop_items() -> Array:
	"""获取商店物品列表"""
	var items = []
	
	if not ads_removed:
		items.append({
			"id": REMOVE_ADS_PRODUCT_ID,
			"name": "移除广告",
			"description": "永久移除所有广告",
			"price": "￥2.99",
			"type": "iap"
		})
	
	if not premium_purchased:
		items.append({
			"id": PREMIUM_UPGRADE_PRODUCT_ID,
			"name": "高级版",
			"description": "解锁全部内容 + 移除广告",
			"price": "￥4.99",
			"type": "iap"
		})
	
	return items

func is_premium_user() -> bool:
	"""检查是否为高级用户"""
	return premium_purchased or ads_removed