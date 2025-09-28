# MetaProgressionManager.gd - Epic 2: 元进程系统实现
# Linus principle: "Permanent progression gives players reason to return"
extends Node

# 永久升级数据库 - 数据驱动设计
var permanent_upgrades_db: Array[Dictionary] = [
	{
		"id": "base_health",
		"name": "🛡️ 铁胃强化",
		"description": "永久增加25点基础生命值",
		"max_level": 10,
		"base_cost": 100,
		"cost_multiplier": 1.5,
		"effect_per_level": 25
	},
	{
		"id": "base_damage", 
		"name": "⚔️ 刀锋精通",
		"description": "永久增加5%武器伤害",
		"max_level": 20,
		"base_cost": 150,
		"cost_multiplier": 1.4,
		"effect_per_level": 0.05
	},
	{
		"id": "movement_speed",
		"name": "🏃 疾风步法", 
		"description": "永久增加10%移动速度",
		"max_level": 15,
		"base_cost": 120,
		"cost_multiplier": 1.3,
		"effect_per_level": 0.10
	},
	{
		"id": "exp_gain",
		"name": "📚 学习天赋",
		"description": "永久增加15%经验获取",
		"max_level": 10,
		"base_cost": 200,
		"cost_multiplier": 1.6,
		"effect_per_level": 0.15
	},
	{
		"id": "coin_gain",
		"name": "💰 财运亨通",
		"description": "永久增加20%金币获取",
		"max_level": 8,
		"base_cost": 300,
		"cost_multiplier": 1.8,
		"effect_per_level": 0.20
	}
]

# 获取升级的当前等级
func get_upgrade_level(upgrade_id: String) -> int:
	return PlayerData.permanent_upgrades.get(upgrade_id, 0)

# 获取升级的下一级花费
func get_upgrade_cost(upgrade_id: String) -> int:
	var upgrade = _find_upgrade_by_id(upgrade_id)
	if not upgrade:
		return 0
	
	var current_level = get_upgrade_level(upgrade_id)
	if current_level >= upgrade.max_level:
		return -1  # 已满级
		
	return int(upgrade.base_cost * pow(upgrade.cost_multiplier, current_level))

# 检查是否可以购买升级
func can_afford_upgrade(upgrade_id: String) -> bool:
	var cost = get_upgrade_cost(upgrade_id)
	return cost > 0 and PlayerData.coins >= cost

# 购买永久升级
func purchase_upgrade(upgrade_id: String) -> bool:
	if not can_afford_upgrade(upgrade_id):
		return false
		
	var cost = get_upgrade_cost(upgrade_id)
	PlayerData.coins -= cost
	
	var current_level = get_upgrade_level(upgrade_id)
	PlayerData.permanent_upgrades[upgrade_id] = current_level + 1
	
	# 发送升级购买事件
	EventBus.permanent_upgrade_purchased.emit(upgrade_id, current_level + 1)
	EventBus.coins_changed.emit(PlayerData.coins)
	
	# 立即保存
	PlayerData.save_data()
	
	print("🌟 PERMANENT UPGRADE: ", upgrade_id, " -> Level ", current_level + 1)
	return true

# 获取所有可用的永久升级信息
func get_all_upgrades_info() -> Array[Dictionary]:
	var upgrades_info: Array[Dictionary] = []
	
	for upgrade in permanent_upgrades_db:
		var current_level = get_upgrade_level(upgrade.id)
		var cost = get_upgrade_cost(upgrade.id)
		var can_afford = can_afford_upgrade(upgrade.id)
		
		upgrades_info.append({
			"id": upgrade.id,
			"name": upgrade.name,
			"description": upgrade.description,
			"current_level": current_level,
			"max_level": upgrade.max_level,
			"cost": cost,
			"can_afford": can_afford,
			"is_max_level": current_level >= upgrade.max_level
		})
	
	return upgrades_info

# 应用永久升级到玩家属性
func apply_permanent_upgrades_to_player(player: Node) -> void:
	if not player or not is_instance_valid(player):
		return
		
	# 应用生命值加成
	var health_bonus = get_upgrade_level("base_health") * 25
	if player.has_method("add_max_health"):
		player.add_max_health(health_bonus)
	
	# 应用伤害加成
	var damage_multiplier = 1.0 + (get_upgrade_level("base_damage") * 0.05)
	if player.has_method("set_damage_multiplier"):
		player.set_damage_multiplier(damage_multiplier)
	
	# 应用速度加成
	var speed_multiplier = 1.0 + (get_upgrade_level("movement_speed") * 0.10)
	if player.has_method("set_speed_multiplier"):
		player.set_speed_multiplier(speed_multiplier)
	
	print("🔧 Applied permanent upgrades to player")

# 计算经验加成倍率
func get_exp_multiplier() -> float:
	return 1.0 + (get_upgrade_level("exp_gain") * 0.15)

# 计算金币加成倍率  
func get_coin_multiplier() -> float:
	return 1.0 + (get_upgrade_level("coin_gain") * 0.20)

# 私有：通过ID查找升级数据
func _find_upgrade_by_id(upgrade_id: String) -> Dictionary:
	for upgrade in permanent_upgrades_db:
		if upgrade.id == upgrade_id:
			return upgrade
	return {}

# 获取总投资的金币数 (用于统计)
func get_total_coins_invested() -> int:
	var total = 0
	for upgrade in permanent_upgrades_db:
		var current_level = get_upgrade_level(upgrade.id)
		for level in range(current_level):
			total += int(upgrade.base_cost * pow(upgrade.cost_multiplier, level))
	return total

# 重置所有永久升级 (调试用)
func reset_all_upgrades() -> void:
	PlayerData.permanent_upgrades.clear()
	PlayerData.save_data()
	print("⚠️ All permanent upgrades reset!")