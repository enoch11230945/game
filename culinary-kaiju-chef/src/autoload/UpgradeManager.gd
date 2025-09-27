# UpgradeManager.gd - Data-driven upgrade system (Linus approved)
extends Node

# === UPGRADE DATABASE ===
var all_weapons: Array[WeaponData] = []
var all_items: Array[ItemData] = []
var current_upgrades: Dictionary = {}  # Applied upgrades with stack counts

# === PLAYER INVENTORY ===
var equipped_weapons: Array[WeaponData] = []
var equipped_items: Array[ItemData] = []

func _ready() -> void:
    print("🔧 UpgradeManager initialized - Data-driven upgrades")
    _load_upgrade_database()
    
    # Connect to events
    EventBus.upgrade_selected.connect(_on_upgrade_selected)

func _load_upgrade_database() -> void:
    """Load all available weapons and items"""
    # Load weapons
    all_weapons.append(load("res://features/weapons/weapon_data/throwing_knife.tres"))
    all_weapons.append(load("res://features/weapons/weapon_data/whisk_tornado.tres"))
    all_weapons.append(load("res://features/weapons/weapon_data/spatula_shield.tres"))
    
    # Load items
    all_items.append(load("res://features/items/item_data/garlic_aura.tres"))
    all_items.append(load("res://features/items/item_data/chef_boots.tres"))
    
    print("✅ Loaded %d weapons, %d items" % [all_weapons.size(), all_items.size()])
    var passive_files = [
        "damage_boost_1", "damage_boost_2", "damage_boost_3",
        "health_boost_1", "health_boost_2", "health_boost_3",
        "speed_boost_1", "speed_boost_2", "speed_boost_3",
        "pickup_range_1", "pickup_range_2", "pickup_range_3",
        "cooldown_reduction_1", "cooldown_reduction_2", "cooldown_reduction_3",
        "crit_chance_1", "crit_chance_2", "crit_chance_3",
        "crit_damage_1", "crit_damage_2", "crit_damage_3",
        "armor_1", "armor_2", "armor_3",
        "regeneration_1", "regeneration_2", "regeneration_3",
        "magnetic_pickup_1", "magnetic_pickup_2", "magnetic_pickup_3",
        "experience_boost_1", "experience_boost_2", "experience_boost_3",
        "knockback_immunity", "poison_immunity", "fire_immunity",
        "double_shot", "triple_shot", "quad_shot",
        "weapon_evolution_charm", "lucky_charm", "berserker_rage"
    ]
    
    # Create upgrade data programmatically (since we have many)
    create_weapon_upgrades()
    create_passive_upgrades()
    
    print("📊 Loaded %d upgrades total" % all_upgrades.size())

func create_weapon_upgrades():
    """Create weapon-specific upgrades programmatically"""
    var weapons = ["cleaver", "whisk", "garlic", "holy_water", "spice_blast", "fork_barrage", 
                   "pizza_cutter", "lightning_spoon", "ice_cream", "bubble_tea", "spatula_shield", "cookbook"]
    
    for weapon in weapons:
        # Damage upgrades
        create_upgrade(
            "%s_damage" % weapon,
            "+25% %s Damage" % weapon.capitalize(),
            "WEAPON",
            "COMMON",
            {weapon: {"damage_multiplier": 0.25}},
            5
        )
        
        # Speed/Cooldown upgrades
        create_upgrade(
            "%s_speed" % weapon,
            "+20% %s Attack Speed" % weapon.capitalize(),
            "WEAPON", 
            "COMMON",
            {weapon: {"cooldown_multiplier": -0.2}},
            5
        )
        
        # Special upgrades per weapon type
        match weapon:
            "cleaver":
                create_upgrade("cleaver_count", "+1 Cleaver Projectile", "WEAPON", "RARE", 
                             {"cleaver": {"projectile_count": 1}}, 3)
            "whisk":
                create_upgrade("whisk_range", "+30% Whisk Range", "WEAPON", "RARE",
                             {"whisk": {"range_multiplier": 0.3}}, 3)
            "garlic":
                create_upgrade("garlic_radius", "+25% Garlic Aura Size", "WEAPON", "RARE",
                             {"garlic": {"aura_size": 0.25}}, 4)

func create_passive_upgrades():
    """Create general passive upgrades"""
    # Damage boosts
    for i in range(1, 4):
        create_upgrade(
            "damage_boost_%d" % i,
            "+%d%% All Damage" % (10 + i * 5),
            "STAT",
            "COMMON" if i == 1 else "RARE",
            {"damage_multiplier": 0.1 + i * 0.05},
            3
        )
    
    # Health boosts
    for i in range(1, 4):
        create_upgrade(
            "health_boost_%d" % i,
            "+%d Max Health" % (20 + i * 10),
            "STAT",
            "COMMON" if i <= 2 else "RARE",
            {"max_health": 20 + i * 10},
            3
        )
    
    # Speed boosts
    for i in range(1, 4):
        create_upgrade(
            "speed_boost_%d" % i,
            "+%d%% Movement Speed" % (10 + i * 5),
            "STAT",
            "COMMON" if i <= 2 else "RARE",
            {"speed_multiplier": 0.1 + i * 0.05},
            3
        )
    
    # Critical hit upgrades
    create_upgrade("crit_chance_1", "+5% Critical Hit Chance", "STAT", "RARE", {"crit_chance": 0.05}, 5)
    create_upgrade("crit_chance_2", "+10% Critical Hit Chance", "STAT", "EPIC", {"crit_chance": 0.1}, 3)
    create_upgrade("crit_damage_1", "+50% Critical Damage", "STAT", "RARE", {"crit_damage": 0.5}, 3)
    create_upgrade("crit_damage_2", "+100% Critical Damage", "STAT", "EPIC", {"crit_damage": 1.0}, 2)
    
    # Special passive abilities
    create_upgrade("magnetic_pickup", "+50% Pickup Range", "PASSIVE", "RARE", {"pickup_range": 0.5}, 3)
    create_upgrade("cooldown_master", "+15% All Cooldown Reduction", "PASSIVE", "EPIC", {"cooldown_reduction": 0.15}, 2)
    create_upgrade("berserker_rage", "+100% Damage, -25% Health", "PASSIVE", "LEGENDARY", 
                 {"damage_multiplier": 1.0, "max_health_multiplier": -0.25}, 1)
    create_upgrade("lucky_charm", "+25% Rare Upgrade Chance", "PASSIVE", "EPIC", {"luck": 0.25}, 1)
    create_upgrade("weapon_evolution", "Enables Weapon Evolution", "PASSIVE", "LEGENDARY", {"evolution_enabled": true}, 1)

func create_upgrade(id: String, name: String, type: String, rarity: String, effects: Dictionary, max_stack: int):
    """Create an upgrade resource programmatically"""
    var upgrade = UpgradeData.new()
    upgrade.upgrade_name = name
    upgrade.description = name  # Simple description for now
    upgrade.upgrade_type = type
    upgrade.rarity = rarity
    upgrade.stat_effects = effects if type == "STAT" else {}
    upgrade.weapon_effects = effects if type == "WEAPON" else {}
    upgrade.passive_effects = [id] if type == "PASSIVE" else []
    upgrade.max_stack = max_stack
    upgrade.weight = rarity_weights.get(rarity, 10) / 10.0
    
    all_upgrades.append(upgrade)
    
    if type == "WEAPON":
        for weapon_name in effects.keys():
            if not weapon_upgrades.has(weapon_name):
                weapon_upgrades[weapon_name] = []
            weapon_upgrades[weapon_name].append(upgrade)
    elif type in ["STAT", "PASSIVE"]:
        passive_upgrades.append(upgrade)

func get_random_upgrades(count: int) -> Array[UpgradeData]:
    """Select random upgrades for player choice - weighted by rarity"""
    var available_upgrades = get_available_upgrades()
    var selected: Array[UpgradeData] = []
    
    if available_upgrades.is_empty():
        print("⚠️ No available upgrades!")
        return selected
    
    # Apply luck bonus from meta progression
    var luck_bonus = PlayerData.get_luck_bonus()
    
    for i in range(count):
        if available_upgrades.is_empty():
            break
        
        var chosen = select_weighted_upgrade(available_upgrades, luck_bonus)
        if chosen:
            selected.append(chosen)
            available_upgrades.erase(chosen)
            
            # Remove if at max stack
            if upgrade_counts.get(chosen.upgrade_name, 0) >= chosen.max_stack - 1:
                available_upgrades.erase(chosen)
    
    return selected

func get_available_upgrades() -> Array[UpgradeData]:
    """Get upgrades that can currently be selected"""
    var available: Array[UpgradeData] = []
    
    for upgrade in all_upgrades:
        # Check if not at max stack
        if upgrade_counts.get(upgrade.upgrade_name, 0) < upgrade.max_stack:
            # Check requirements (implement later if needed)
            if meets_requirements(upgrade):
                available.append(upgrade)
    
    return available

func meets_requirements(upgrade: UpgradeData) -> bool:
    """Check if upgrade requirements are met"""
    # For now, all upgrades are available
    # TODO: Implement weapon level requirements, kill count requirements, etc.
    return true

func select_weighted_upgrade(available: Array[UpgradeData], luck_bonus: float) -> UpgradeData:
    """Select upgrade using weighted probability with luck modifier"""
    if available.is_empty():
        return null
    
    var total_weight = 0.0
    var weights: Array[float] = []
    
    for upgrade in available:
        var base_weight = upgrade.weight
        # Apply luck bonus to rare upgrades
        if upgrade.rarity in ["RARE", "EPIC", "LEGENDARY"]:
            base_weight *= (1.0 + luck_bonus)
        
        weights.append(base_weight)
        total_weight += base_weight
    
    var random_value = randf() * total_weight
    var current_weight = 0.0
    
    for i in range(available.size()):
        current_weight += weights[i]
        if random_value <= current_weight:
            return available[i]
    
    # Fallback to last upgrade
    return available[-1]

func apply_upgrade(upgrade: UpgradeData):
    """Apply the selected upgrade to the player"""
    applied_upgrades.append(upgrade)
    upgrade_counts[upgrade.upgrade_name] = upgrade_counts.get(upgrade.upgrade_name, 0) + 1
    
    # Apply stat effects
    for stat in upgrade.stat_effects:
        apply_stat_effect(stat, upgrade.stat_effects[stat])
    
    # Apply weapon effects
    for weapon_name in upgrade.weapon_effects:
        apply_weapon_effect(weapon_name, upgrade.weapon_effects[weapon_name])
    
    # Apply passive effects
    for effect in upgrade.passive_effects:
        apply_passive_effect(effect)
    
    EventBus.upgrade_applied.emit(upgrade)
    print("⬆️ Applied upgrade: %s" % upgrade.upgrade_name)

func apply_stat_effect(stat_name: String, value):
    """Apply a stat effect to the player"""
    match stat_name:
        "damage_multiplier":
            Game.base_damage_multiplier *= (1.0 + value)
        "max_health":
            Game.base_health += value
        "speed_multiplier":
            Game.base_speed_multiplier *= (1.0 + value)
        "crit_chance":
            # Handle via Game system or player directly
            pass
        "crit_damage":
            # Handle via Game system or player directly
            pass

func apply_weapon_effect(weapon_name: String, effects: Dictionary):
    """Apply effects to a specific weapon"""
    if not weapon_levels.has(weapon_name):
        weapon_levels[weapon_name] = 0
    weapon_levels[weapon_name] += 1
    
    # Send signal to weapon systems
    EventBus.weapon_upgraded.emit(weapon_name, effects)

func apply_passive_effect(effect_name: String):
    """Apply a passive effect"""
    # Send signal for passive effect handling
    EventBus.passive_effect_applied.emit(effect_name)

func _on_player_level_up(new_level: int):
    """Handle player level up"""
    # Upgrade selection is handled by Game.gd calling get_random_upgrades
    pass

func reset_run():
    """Reset upgrade state for new run"""
    applied_upgrades.clear()
    upgrade_counts.clear()
    weapon_levels.clear()
    print("🔄 UpgradeManager reset for new run")