# IAPManager.gd - Epic 3: 应用内购买系统
# Linus principle: "IAP should provide value, not create pay-to-win"
extends Node

# IAP产品数据库
var iap_products: Array[Dictionary] = [
	{
		"id": "remove_ads",
		"name": "🚫 永久去除广告",
		"description": "移除所有广告，直接获得奖励",
		"price": "$2.99",
		"type": "non_consumable"
	},
	{
		"id": "coin_pack_small",
		"name": "💰 小型金币包",
		"description": "获得500金币",
		"price": "$0.99", 
		"type": "consumable",
		"coin_amount": 500
	},
	{
		"id": "coin_pack_large",
		"name": "💎 大型金币包",
		"description": "获得2000金币 (超值!)",
		"price": "$3.99",
		"type": "consumable", 
		"coin_amount": 2000
	},
	{
		"id": "starter_pack",
		"name": "🎁 新手礼包",
		"description": "1000金币 + 解锁所有基础角色",
		"price": "$4.99",
		"type": "consumable",
		"coin_amount": 1000,
		"unlock_characters": ["iron_chef", "pastry_assassin"]
	},
	{
		"id": "premium_pass",
		"name": "👑 高级通行证",
		"description": "永久双倍经验和金币获取",
		"price": "$9.99",
		"type": "non_consumable"
	}
]

var mock_iap_system: bool = true
var purchased_products: Array[String] = []

signal purchase_successful(product_id: String)
signal purchase_failed(product_id: String, error: String)
signal products_loaded

func _ready() -> void:
	# 加载已购买的产品
	_load_purchased_products()
	
	if mock_iap_system:
		# 模拟商店加载
		call_deferred("_mock_store_loaded")
	else:
		# 实际IAP初始化代码
		# GooglePlayBilling.initialize()
		pass

func _load_purchased_products() -> void:
	purchased_products = PlayerData.purchased_iap_products.duplicate()
	
	# 应用已购买产品的效果
	for product_id in purchased_products:
		_apply_product_effects(product_id)

func _mock_store_loaded() -> void:
	print("🏪 Mock IAP store loaded")
	products_loaded.emit()

# 尝试购买产品
func purchase_product(product_id: String) -> void:
	var product = _find_product_by_id(product_id)
	if not product:
		print("❌ Product not found: ", product_id)
		return
	
	if product.type == "non_consumable" and is_product_purchased(product_id):
		print("❌ Product already purchased: ", product_id)
		purchase_failed.emit(product_id, "Already purchased")
		return
	
	print("💳 Processing purchase: ", product.name)
	
	if mock_iap_system:
		_mock_purchase(product)
	else:
		# 实际IAP购买代码
		# GooglePlayBilling.purchase(product_id)
		pass

func _mock_purchase(product: Dictionary) -> void:
	# 模拟购买流程
	await get_tree().create_timer(1.0).timeout
	
	# 90%成功率
	if randf() < 0.9:
		_on_purchase_successful(product.id)
	else:
		_on_purchase_failed(product.id, "Payment failed")

func _on_purchase_successful(product_id: String) -> void:
	print("✅ Purchase successful: ", product_id)
	
	# 记录购买
	if not is_product_purchased(product_id):
		purchased_products.append(product_id)
		PlayerData.purchased_iap_products.append(product_id)
	
	# 应用产品效果
	_apply_product_effects(product_id)
	
	# 保存数据
	PlayerData.save_data()
	
	purchase_successful.emit(product_id)

func _on_purchase_failed(product_id: String, error: String) -> void:
	print("❌ Purchase failed: ", product_id, " - ", error)
	purchase_failed.emit(product_id, error)

func _apply_product_effects(product_id: String) -> void:
	var product = _find_product_by_id(product_id)
	if not product:
		return
	
	match product_id:
		"remove_ads":
			PlayerData.set_permanent_upgrade("remove_ads", true)
			print("🚫 Ads permanently removed")
			
		"coin_pack_small", "coin_pack_large":
			PlayerData.coins += product.coin_amount
			EventBus.coins_changed.emit(PlayerData.coins)
			print("💰 Added ", product.coin_amount, " coins")
			
		"starter_pack":
			PlayerData.coins += product.coin_amount
			for character_id in product.unlock_characters:
				if not PlayerData.unlocked_characters.has(character_id):
					PlayerData.unlocked_characters.append(character_id)
			EventBus.coins_changed.emit(PlayerData.coins)
			print("🎁 Starter pack applied")
			
		"premium_pass":
			PlayerData.set_permanent_upgrade("premium_pass", true)
			print("👑 Premium pass activated")

# 检查产品是否已购买
func is_product_purchased(product_id: String) -> bool:
	return purchased_products.has(product_id)

# 获取所有产品信息
func get_all_products_info() -> Array[Dictionary]:
	var products_info: Array[Dictionary] = []
	
	for product in iap_products:
		products_info.append({
			"id": product.id,
			"name": product.name,
			"description": product.description,
			"price": product.price,
			"type": product.type,
			"is_purchased": is_product_purchased(product.id),
			"can_purchase": product.type == "consumable" or not is_product_purchased(product.id)
		})
	
	return products_info

# 恢复购买 (重新验证非消耗品)
func restore_purchases() -> void:
	if mock_iap_system:
		print("🔄 Mock restore completed")
		return
	
	# 实际恢复购买代码
	# GooglePlayBilling.restore_purchases()

# 获取Premium Pass状态
func has_premium_pass() -> bool:
	return is_product_purchased("premium_pass")

# 获取经验倍率 (包括Premium Pass加成)
func get_total_exp_multiplier() -> float:
	var base_multiplier = 1.0
	if has_premium_pass():
		base_multiplier *= 2.0
	return base_multiplier

# 获取金币倍率 (包括Premium Pass加成)
func get_total_coin_multiplier() -> float:
	var base_multiplier = 1.0
	if has_premium_pass():
		base_multiplier *= 2.0
	return base_multiplier

# 私有：通过ID查找产品
func _find_product_by_id(product_id: String) -> Dictionary:
	for product in iap_products:
		if product.id == product_id:
			return product
	return {}

# 调试：重置所有购买 (仅调试模式)
func reset_all_purchases() -> void:
	purchased_products.clear()
	PlayerData.purchased_iap_products.clear()
	PlayerData.save_data()
	print("⚠️ All purchases reset!")