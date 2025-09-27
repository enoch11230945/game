# upgrade_definitions.gd - All 50 upgrade definitions in one place
extends Node

# This creates all upgrades at runtime - more maintainable than 50 .tres files
static func create_all_upgrades() -> Array[UpgradeData]:
	var upgrades: Array[UpgradeData] = []
	
	# === WEAPON UPGRADES (15) ===
	upgrades.append(_create_upgrade("🔪 Cleaver Mastery", "More cleavers!", "WEAPON", 
		{"weapon_name": "cleaver", "count": 1}, "COMMON", 5))
	upgrades.append(_create_upgrade("⚔️ Razor Edge", "More damage!", "WEAPON",
		{"weapon_name": "cleaver", "damage": 0.2}, "COMMON", 5))
	upgrades.append(_create_upgrade("⚡ Lightning Hands", "Faster attacks!", "WEAPON",
		{"weapon_name": "cleaver", "cooldown": -0.1}, "COMMON", 5))
	upgrades.append(_create_upgrade("🎯 Perfect Aim", "Piercing cleavers!", "WEAPON",
		{"weapon_name": "cleaver", "piercing": 1}, "RARE", 1))
	upgrades.append(_create_upgrade("🌪️ Whisk Tornado", "UNLOCK: Area weapon!", "UNLOCK",
		{"weapon_unlock": "whisk"}, "RARE", 1))
	upgrades.append(_create_upgrade("🧄 Garlic Guardian", "UNLOCK: Protective aura!", "UNLOCK",
		{"weapon_unlock": "garlic_aura"}, "RARE", 1))
	upgrades.append(_create_upgrade("💧 Holy Blessing", "UNLOCK: Area damage!", "UNLOCK",
		{"weapon_unlock": "holy_water"}, "RARE", 1))
	upgrades.append(_create_upgrade("🌶️ Spice Master", "UNLOCK: Explosive power!", "UNLOCK",
		{"weapon_unlock": "spice_blast"}, "EPIC", 1))
	upgrades.append(_create_upgrade("🍴 Fork Fury", "UNLOCK: Rapid fire!", "UNLOCK",
		{"weapon_unlock": "fork_barrage"}, "EPIC", 1))
	upgrades.append(_create_upgrade("🍦 Frost Control", "UNLOCK: Crowd control!", "UNLOCK",
		{"weapon_unlock": "ice_cream"}, "EPIC", 1))
	upgrades.append(_create_upgrade("🍕 Pizza Power", "UNLOCK: Boomerang weapon!", "UNLOCK",
		{"weapon_unlock": "pizza_cutter"}, "EPIC", 1))
	upgrades.append(_create_upgrade("⚡ Storm Caller", "UNLOCK: Chain lightning!", "UNLOCK",
		{"weapon_unlock": "lightning_spoon"}, "LEGENDARY", 1))
	upgrades.append(_create_upgrade("🧋 Bubble Master", "UNLOCK: Bouncing shots!", "UNLOCK",
		{"weapon_unlock": "bubble_tea"}, "LEGENDARY", 1))
	upgrades.append(_create_upgrade("📖 Ancient Knowledge", "UNLOCK: Summon allies!", "UNLOCK",
		{"weapon_unlock": "cookbook"}, "LEGENDARY", 1))
	upgrades.append(_create_upgrade("🥄 Ultimate Defense", "UNLOCK: Shield weapon!", "UNLOCK",
		{"weapon_unlock": "spatula_shield"}, "LEGENDARY", 1))
	
	# === STAT UPGRADES (20) ===
	upgrades.append(_create_upgrade("💪 Kaiju Vigor", "Faster movement!", "STAT",
		{"movement_speed": 40}, "COMMON", 5))
	upgrades.append(_create_upgrade("💚 Chef's Resilience", "More health!", "STAT",
		{"max_health": 25}, "COMMON", 5))
	upgrades.append(_create_upgrade("🛡️ Iron Apron", "Damage reduction!", "STAT",
		{"damage_reduction": 0.1}, "COMMON", 3))
	upgrades.append(_create_upgrade("🐉 Giant Growth", "Bigger size!", "STAT",
		{"size_multiplier": 1.25}, "COMMON", 3))
	upgrades.append(_create_upgrade("🌟 Spice Magnet", "Larger pickup radius!", "STAT",
		{"pickup_radius": 1.5}, "COMMON", 3))
	upgrades.append(_create_upgrade("⚡ Hyperactive", "Attack speed boost!", "STAT",
		{"attack_speed": 0.15}, "RARE", 3))
	upgrades.append(_create_upgrade("💎 Critical Strike", "Higher crit chance!", "STAT",
		{"crit_chance": 0.1}, "RARE", 3))
	upgrades.append(_create_upgrade("💥 Critical Power", "Higher crit damage!", "STAT",
		{"crit_damage": 0.5}, "RARE", 2))
	upgrades.append(_create_upgrade("🧲 Super Magnet", "Massive pickup range!", "STAT",
		{"pickup_radius": 2.5}, "EPIC", 1))
	upgrades.append(_create_upgrade("🌊 Knockback Master", "Stronger knockback!", "STAT",
		{"knockback_power": 0.3}, "EPIC", 2))
	upgrades.append(_create_upgrade("🩹 Regeneration", "Health regeneration!", "PASSIVE",
		{"health_regen": 2}, "EPIC", 1))
	upgrades.append(_create_upgrade("🔥 Burning Weapons", "All attacks burn!", "PASSIVE",
		{"burn_effect": true}, "EPIC", 1))
	upgrades.append(_create_upgrade("❄️ Freezing Touch", "All attacks slow!", "PASSIVE",
		{"slow_effect": true}, "EPIC", 1))
	upgrades.append(_create_upgrade("⚡ Electric Aura", "Damage nearby enemies!", "PASSIVE",
		{"damage_aura": 10}, "EPIC", 1))
	upgrades.append(_create_upgrade("🍀 Lucky Charm", "Double XP chance!", "PASSIVE",
		{"double_xp_chance": 0.2}, "LEGENDARY", 1))
	upgrades.append(_create_upgrade("💰 Gold Rush", "Extra meta currency!", "PASSIVE",
		{"gold_multiplier": 1.5}, "LEGENDARY", 1))
	upgrades.append(_create_upgrade("🎯 Perfect Accuracy", "All attacks pierce!", "PASSIVE",
		{"universal_piercing": true}, "LEGENDARY", 1))
	upgrades.append(_create_upgrade("🌈 Rainbow Power", "All damage types!", "PASSIVE",
		{"rainbow_damage": true}, "LEGENDARY", 1))
	upgrades.append(_create_upgrade("👑 Kaiju King", "Massive size and power!", "STAT",
		{"size_multiplier": 2.0, "damage_multiplier": 1.5}, "LEGENDARY", 1))
	upgrades.append(_create_upgrade("♾️ Infinite Appetite", "No cooldowns!", "PASSIVE",
		{"no_cooldowns": true}, "LEGENDARY", 1))
	
	# === EVOLUTION UPGRADES (15) ===
	upgrades.append(_create_upgrade("🔮 Protective Charm", "Enables Garlic evolution", "EVOLUTION",
		{"evolution_component": "protective_charm"}, "RARE", 1))
	upgrades.append(_create_upgrade("📜 Spell Power", "Enables Holy Water evolution", "EVOLUTION",
		{"evolution_component": "spell_power"}, "RARE", 1))
	upgrades.append(_create_upgrade("🔥 Fire Mastery", "Enables Spice evolution", "EVOLUTION",
		{"evolution_component": "fire_mastery"}, "RARE", 1))
	upgrades.append(_create_upgrade("🎯 Precision Aim", "Enables Fork evolution", "EVOLUTION",
		{"evolution_component": "precision_aim"}, "RARE", 1))
	upgrades.append(_create_upgrade("❄️ Frost Mastery", "Enables Ice Cream evolution", "EVOLUTION",
		{"evolution_component": "frost_mastery"}, "RARE", 1))
	upgrades.append(_create_upgrade("🍕 Boomerang Mastery", "Enables Pizza evolution", "EVOLUTION",
		{"evolution_component": "boomerang_mastery"}, "EPIC", 1))
	upgrades.append(_create_upgrade("⚡ Storm Mastery", "Enables Lightning evolution", "EVOLUTION",
		{"evolution_component": "storm_mastery"}, "EPIC", 1))
	upgrades.append(_create_upgrade("🧋 Bubble Mastery", "Enables Bubble Tea evolution", "EVOLUTION",
		{"evolution_component": "bubble_mastery"}, "EPIC", 1))
	upgrades.append(_create_upgrade("🛡️ Defense Mastery", "Enables Shield evolution", "EVOLUTION",
		{"evolution_component": "defense_mastery"}, "EPIC", 1))
	upgrades.append(_create_upgrade("📖 Summoning Mastery", "Enables Cookbook evolution", "EVOLUTION",
		{"evolution_component": "summoning_mastery"}, "LEGENDARY", 1))
	upgrades.append(_create_upgrade("🌟 Ultimate Cleaver", "Cleaver → Mega Cleaver", "EVOLUTION",
		{"weapon_evolution": "cleaver_to_mega"}, "LEGENDARY", 1))
	upgrades.append(_create_upgrade("🌪️ Ultimate Whisk", "Whisk → Tornado Whisk", "EVOLUTION",
		{"weapon_evolution": "whisk_to_tornado"}, "LEGENDARY", 1))
	upgrades.append(_create_upgrade("🧄 Holy Garlic", "Garlic → Divine Protection", "EVOLUTION",
		{"weapon_evolution": "garlic_to_holy"}, "LEGENDARY", 1))
	upgrades.append(_create_upgrade("💧 Divine Flood", "Holy Water → Tsunami", "EVOLUTION",
		{"weapon_evolution": "water_to_flood"}, "LEGENDARY", 1))
	upgrades.append(_create_upgrade("🔥 Inferno Spice", "Spice → Hellfire Blast", "EVOLUTION",
		{"weapon_evolution": "spice_to_inferno"}, "LEGENDARY", 1))
	
	return upgrades

static func _create_upgrade(name: String, desc: String, type: String, effects: Dictionary, rarity: String, max_stack: int) -> UpgradeData:
	var upgrade = UpgradeData.new()
	upgrade.upgrade_name = name
	upgrade.description = desc
	upgrade.upgrade_type = type
	upgrade.stat_effects = effects if type == "STAT" else {}
	upgrade.weapon_effects = effects if type == "WEAPON" else {}
	upgrade.passive_effects = [effects.keys()[0]] if type == "PASSIVE" else []
	upgrade.rarity = rarity
	upgrade.max_stack = max_stack
	upgrade.weight = _get_rarity_weight(rarity)
	return upgrade

static func _get_rarity_weight(rarity: String) -> float:
	match rarity:
		"COMMON": return 1.0
		"RARE": return 0.4
		"EPIC": return 0.15
		"LEGENDARY": return 0.05
		_: return 1.0