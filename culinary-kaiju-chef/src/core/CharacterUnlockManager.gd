# CharacterUnlockManager.gd - Epic 2: 角色解锁系统
# Linus principle: "Each character should break the rules in their own way"
extends Node

# 角色数据库 - 每个角色都是"规则破坏者"
var characters_db: Array[Dictionary] = [
	{
		"id": "monster_chef", 
		"name": "🐉 怪兽主厨",
		"description": "平衡的全能型角色，适合新手",
		"unlock_requirement": "default",  # 默认解锁
		"unlock_cost": 0,
		"starting_weapon": "Throwing Knife",
		"base_health": 100,
		"base_speed": 300.0,
		"special_ability": "balanced_growth",
		"ability_description": "所有升级效果+10%"
	},
	{
		"id": "iron_chef",
		"name": "🔥 铁板烧大师", 
		"description": "只能使用近战武器，但近战伤害翻倍！",
		"unlock_requirement": "survive_time",
		"unlock_value": 600,  # 存活10分钟解锁
		"unlock_cost": 500,
		"starting_weapon": "Cleaver",
		"base_health": 120,
		"base_speed": 250.0,
		"special_ability": "melee_mastery",
		"ability_description": "近战武器范围+50%，伤害+100%"
	},
	{
		"id": "pastry_assassin",
		"name": "🗡️ 糕点刺客",
		"description": "血量很低，但移动速度和攻击速度极快",
		"unlock_requirement": "kills_in_single_run",
		"unlock_value": 500,  # 单局击杀500敌人
		"unlock_cost": 750,
		"starting_weapon": "Throwing Knife",
		"base_health": 50,
		"base_speed": 400.0,
		"special_ability": "glass_cannon",
		"ability_description": "攻击速度+75%，但血量-50%"
	},
	{
		"id": "soup_wizard",
		"name": "🧙 汤汁法师",
		"description": "专精范围攻击武器，魔法伤害专家",
		"unlock_requirement": "weapon_evolutions",
		"unlock_value": 3,    # 完成3次武器进化
		"unlock_cost": 1000,
		"starting_weapon": "Magic Whisk",
		"base_health": 80,
		"base_speed": 280.0,
		"special_ability": "aoe_master",
		"ability_description": "范围武器效果+100%，投射物武器-50%"
	}
]

# 检查角色是否已解锁
func is_character_unlocked(character_id: String) -> bool:
	if character_id == "monster_chef":
		return true  # 默认角色总是解锁的
		
	return PlayerData.unlocked_characters.has(character_id)

# 检查角色解锁要求是否满足
func check_unlock_requirements(character_id: String) -> bool:
	var character = _find_character_by_id(character_id)
	if not character:
		return false
		
	if is_character_unlocked(character_id):
		return true  # 已经解锁了
		
	match character.unlock_requirement:
		"survive_time":
			return PlayerData.best_survival_time >= character.unlock_value
		"kills_in_single_run":
			return PlayerData.best_kills_single_run >= character.unlock_value
		"weapon_evolutions":
			return PlayerData.total_weapon_evolutions >= character.unlock_value
		"total_kills":
			return PlayerData.total_enemies_killed >= character.unlock_value
		_:
			return false

# 尝试解锁角色
func try_unlock_character(character_id: String) -> bool:
	if is_character_unlocked(character_id):
		return true  # 已解锁
		
	if not check_unlock_requirements(character_id):
		return false  # 不满足要求
		
	var character = _find_character_by_id(character_id)
	if PlayerData.coins < character.unlock_cost:
		return false  # 金币不足
		
	# 解锁角色
	PlayerData.coins -= character.unlock_cost
	PlayerData.unlocked_characters.append(character_id)
	
	EventBus.emit_signal("character_unlocked", character_id)
	EventBus.coins_changed.emit(PlayerData.coins)
	PlayerData.save_data()
	
	print("🌟 CHARACTER UNLOCKED: ", character.name)
	return true

# 获取所有角色信息（包括解锁状态）
func get_all_characters_info() -> Array[Dictionary]:
	var characters_info: Array[Dictionary] = []
	
	for character in characters_db:
		var is_unlocked = is_character_unlocked(character.id)
		var can_unlock = check_unlock_requirements(character.id)
		var can_afford = PlayerData.coins >= character.unlock_cost
		
		characters_info.append({
			"id": character.id,
			"name": character.name,
			"description": character.description,
			"starting_weapon": character.starting_weapon,
			"base_health": character.base_health,
			"base_speed": character.base_speed,
			"special_ability": character.special_ability,
			"ability_description": character.ability_description,
			"is_unlocked": is_unlocked,
			"can_unlock": can_unlock and can_afford,
			"unlock_cost": character.unlock_cost,
			"unlock_requirement": character.unlock_requirement,
			"unlock_value": character.unlock_value
		})
	
	return characters_info

# 应用角色特殊能力
func apply_character_abilities(player: Node, character_id: String) -> void:
	var character = _find_character_by_id(character_id)
	if not character:
		return
		
	match character.special_ability:
		"melee_mastery":
			# 近战武器加成
			if player.has_method("set_melee_bonus"):
				player.set_melee_bonus(2.0, 1.5)  # 伤害翻倍，范围+50%
		"glass_cannon":
			# 玻璃大炮：攻速+75%，血量-50%
			if player.has_method("set_attack_speed_multiplier"):
				player.set_attack_speed_multiplier(1.75)
			if player.has_method("set_health_multiplier"):
				player.set_health_multiplier(0.5)
		"aoe_master":
			# 范围攻击专精
			if player.has_method("set_aoe_bonus"):
				player.set_aoe_bonus(2.0)  # 范围武器效果翻倍
			if player.has_method("set_projectile_penalty"):
				player.set_projectile_penalty(0.5)  # 投射物武器-50%
		"balanced_growth":
			# 全能型：所有升级效果+10%
			if player.has_method("set_upgrade_multiplier"):
				player.set_upgrade_multiplier(1.1)

# 获取角色的起始数据
func get_character_starting_data(character_id: String) -> Dictionary:
	var character = _find_character_by_id(character_id)
	if not character:
		return {}
		
	return {
		"starting_weapon": character.starting_weapon,
		"base_health": character.base_health,
		"base_speed": character.base_speed,
		"special_ability": character.special_ability
	}

# 私有：通过ID查找角色数据
func _find_character_by_id(character_id: String) -> Dictionary:
	for character in characters_db:
		if character.id == character_id:
			return character
	return {}

# 获取解锁进度文本
func get_unlock_progress_text(character_id: String) -> String:
	var character = _find_character_by_id(character_id)
	if not character:
		return ""
		
	if is_character_unlocked(character_id):
		return "已解锁"
		
	match character.unlock_requirement:
		"survive_time":
			var current = PlayerData.best_survival_time
			var required = character.unlock_value
			return "存活时间: %d/%d秒" % [current, required]
		"kills_in_single_run":
			var current = PlayerData.best_kills_single_run
			var required = character.unlock_value
			return "单局击杀: %d/%d" % [current, required]
		"weapon_evolutions":
			var current = PlayerData.total_weapon_evolutions
			var required = character.unlock_value
			return "武器进化: %d/%d次" % [current, required]
		_:
			return "未知要求"