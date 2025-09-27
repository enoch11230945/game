# DataManager.gd - Central data loading system (Linus-approved)
# "All game data should be loaded once and cached efficiently" - Linus
extends Node

# === DATA CACHES ===
var weapon_data_cache: Dictionary = {}
var enemy_data_cache: Dictionary = {}
var boss_data_cache: Dictionary = {}
var upgrade_data_cache: Dictionary = {}

# === DATA PATHS ===
const DATA_PATH = "res://src/core/data/"

# === WEAPON EVOLUTION MAPPING ===
var weapon_evolutions: Dictionary = {
    "cleaver_weapon": {
        "requirements": ["cleaver_max_level", "berserker_charm"],
        "evolved_form": "meat_cleaver_rampage"
    },
    "whisk_weapon": {
        "requirements": ["whisk_max_level", "speed_charm"],
        "evolved_form": "tornado_whisk"
    },
    "garlic_aura_weapon": {
        "requirements": ["garlic_max_level", "protective_charm"],
        "evolved_form": "holy_garlic_sanctuary"
    },
    "holy_water_weapon": {
        "requirements": ["holy_water_max_level", "area_charm"],
        "evolved_form": "blessed_tsunami"
    },
    "spice_blast_weapon": {
        "requirements": ["spice_max_level", "explosion_charm"],
        "evolved_form": "inferno_spice_storm"
    },
    "fork_barrage_weapon": {
        "requirements": ["fork_max_level", "projectile_charm"],
        "evolved_form": "fork_lightning_storm"
    }
}

func _ready():
    print("📊 DataManager initialized - Caching all game data")
    load_all_data()

func load_all_data():
    """Load and cache all game data resources"""
    load_weapon_data()
    load_enemy_data()
    load_boss_data()
    load_upgrade_data()
    
    var total_items = weapon_data_cache.size() + enemy_data_cache.size() + boss_data_cache.size() + upgrade_data_cache.size()
    print("📊 Loaded %d total data resources" % total_items)

func load_weapon_data():
    """Load all weapon data resources"""
    var weapon_files = [
        "cleaver_weapon.tres",
        "whisk_weapon.tres", 
        "garlic_aura_weapon.tres",
        "holy_water_weapon.tres",
        "spice_blast_weapon.tres",
        "fork_barrage_weapon.tres",
        "pizza_cutter_weapon.tres",
        "lightning_spoon_weapon.tres",
        "ice_cream_weapon.tres",
        "bubble_tea_weapon.tres",
        "spatula_shield_weapon.tres",
        "cookbook_weapon.tres"
    ]
    
    for file in weapon_files:
        var resource_path = DATA_PATH + file
        if ResourceLoader.exists(resource_path):
            var weapon_data = load(resource_path) as WeaponData
            if weapon_data:
                var key = file.replace(".tres", "").replace("_weapon", "")
                weapon_data_cache[key] = weapon_data
                print("🗡️ Loaded weapon: %s" % weapon_data.weapon_name)
        else:
            print("⚠️ Weapon file not found: %s" % resource_path)
    
    print("🗡️ Loaded %d weapons" % weapon_data_cache.size())

func load_enemy_data():
    """Load all enemy data resources"""
    var enemy_files = [
        "onion_enemy.tres",
        "tomato_enemy.tres",
        "swarmer_enemy.tres",
        "tank_enemy.tres",
        "ranger_enemy.tres",
        "berserker_enemy.tres",
        "ghost_enemy.tres",
        "exploder_enemy.tres",
        "healer_enemy.tres",
        "mimic_enemy.tres",
        "spawner_enemy.tres",
        "elite_enemy.tres"
    ]
    
    for file in enemy_files:
        var resource_path = DATA_PATH + file
        if ResourceLoader.exists(resource_path):
            var enemy_data = load(resource_path) as EnemyData
            if enemy_data:
                var key = file.replace(".tres", "").replace("_enemy", "")
                enemy_data_cache[key] = enemy_data
                print("👹 Loaded enemy: %s" % enemy_data.enemy_name)
        else:
            print("⚠️ Enemy file not found: %s" % resource_path)
    
    print("👹 Loaded %d enemies" % enemy_data_cache.size())

func load_boss_data():
    """Load all boss data resources"""
    var boss_files = [
        "king_onion_boss.tres",
        "pepper_artillery_boss.tres", 
        "final_feast_boss.tres"
    ]
    
    for file in boss_files:
        var resource_path = DATA_PATH + file
        if ResourceLoader.exists(resource_path):
            var boss_data = load(resource_path) as BossData
            if boss_data:
                var key = file.replace(".tres", "").replace("_boss", "")
                boss_data_cache[key] = boss_data
                print("👑 Loaded boss: %s" % boss_data.boss_name)
        else:
            print("⚠️ Boss file not found: %s" % resource_path)
    
    print("👑 Loaded %d bosses" % boss_data_cache.size())

func load_upgrade_data():
    """Load upgrade data - handled by UpgradeManager"""
    # Upgrades are created programmatically in UpgradeManager
    print("⬆️ Upgrades handled by UpgradeManager")

# === GETTER FUNCTIONS ===

func get_weapon(weapon_name: String) -> WeaponData:
    """Get weapon data by name"""
    var key = weapon_name.to_lower().replace(" ", "_")
    if weapon_data_cache.has(key):
        return weapon_data_cache[key]
    
    # Try alternative keys
    for cache_key in weapon_data_cache:
        var weapon = weapon_data_cache[cache_key]
        if weapon.weapon_name.to_lower() == weapon_name.to_lower():
            return weapon
    
    print("⚠️ Weapon not found: %s" % weapon_name)
    return null

func get_enemy(enemy_name: String) -> EnemyData:
    """Get enemy data by name"""
    var key = enemy_name.to_lower().replace(" ", "_")
    if enemy_data_cache.has(key):
        return enemy_data_cache[key]
    
    # Try alternative keys
    for cache_key in enemy_data_cache:
        var enemy = enemy_data_cache[cache_key]
        if enemy.enemy_name.to_lower() == enemy_name.to_lower():
            return enemy
    
    print("⚠️ Enemy not found: %s" % enemy_name)
    return null

func get_boss(boss_name: String) -> BossData:
    """Get boss data by name"""
    var key = boss_name.to_lower().replace(" ", "_")
    if boss_data_cache.has(key):
        return boss_data_cache[key]
    
    # Try alternative keys
    for cache_key in boss_data_cache:
        var boss = boss_data_cache[cache_key]
        if boss.boss_name.to_lower() == boss_name.to_lower():
            return boss
    
    print("⚠️ Boss not found: %s" % boss_name)
    return null

func get_all_weapons() -> Array[WeaponData]:
    """Get all available weapons"""
    var weapons: Array[WeaponData] = []
    for weapon in weapon_data_cache.values():
        weapons.append(weapon)
    return weapons

func get_all_enemies() -> Array[EnemyData]:
    """Get all available enemies"""
    var enemies: Array[EnemyData] = []
    for enemy in enemy_data_cache.values():
        enemies.append(enemy)
    return enemies

func get_all_bosses() -> Array[BossData]:
    """Get all available bosses"""
    var bosses: Array[BossData] = []
    for boss in boss_data_cache.values():
        bosses.append(boss)
    return bosses

func get_weapons_by_type(weapon_type: String) -> Array[WeaponData]:
    """Get weapons of specific type"""
    var filtered: Array[WeaponData] = []
    for weapon in weapon_data_cache.values():
        if weapon.weapon_type == weapon_type:
            filtered.append(weapon)
    return filtered

func get_enemies_by_type(enemy_type: String) -> Array[EnemyData]:
    """Get enemies of specific type"""
    var filtered: Array[EnemyData] = []
    for enemy in enemy_data_cache.values():
        if enemy.enemy_type == enemy_type:
            filtered.append(enemy)
    return filtered

# === WEAPON EVOLUTION SYSTEM ===

func can_weapon_evolve(weapon_name: String, player_upgrades: Array) -> bool:
    """Check if a weapon can evolve based on requirements"""
    var weapon_key = weapon_name.to_lower().replace(" ", "_")
    
    if not weapon_evolutions.has(weapon_key):
        return false
    
    var requirements = weapon_evolutions[weapon_key]["requirements"]
    
    for requirement in requirements:
        if not has_upgrade_requirement(requirement, player_upgrades):
            return false
    
    return true

func get_evolved_weapon(weapon_name: String) -> WeaponData:
    """Get the evolved form of a weapon"""
    var weapon_key = weapon_name.to_lower().replace(" ", "_")
    
    if not weapon_evolutions.has(weapon_key):
        return null
    
    var evolved_name = weapon_evolutions[weapon_key]["evolved_form"]
    return get_weapon(evolved_name)

func has_upgrade_requirement(requirement: String, player_upgrades: Array) -> bool:
    """Check if player has specific upgrade requirement"""
    # This would check against the player's current upgrades
    for upgrade in player_upgrades:
        if upgrade.upgrade_name.to_lower().contains(requirement.replace("_", " ")):
            return true
    return false

# === RANDOM SELECTION HELPERS ===

func get_random_weapon() -> WeaponData:
    """Get a random weapon"""
    var weapons = weapon_data_cache.values()
    if weapons.is_empty():
        return null
    return weapons[randi() % weapons.size()]

func get_random_enemy() -> EnemyData:
    """Get a random enemy"""
    var enemies = enemy_data_cache.values()
    if enemies.is_empty():
        return null
    return enemies[randi() % enemies.size()]

func get_random_boss() -> BossData:
    """Get a random boss"""
    var bosses = boss_data_cache.values()
    if bosses.is_empty():
        return null
    return bosses[randi() % bosses.size()]

func get_weighted_random_enemy(wave_level: int) -> EnemyData:
    """Get a random enemy weighted by wave level"""
    var available_enemies: Array[EnemyData] = []
    
    # Add basic enemies (always available)
    var basic_enemies = ["onion", "tomato", "swarmer"]
    for enemy_name in basic_enemies:
        var enemy = get_enemy(enemy_name)
        if enemy:
            available_enemies.append(enemy)
    
    # Add advanced enemies based on wave level
    if wave_level >= 3:
        var advanced = ["tank", "ranger"]
        for enemy_name in advanced:
            var enemy = get_enemy(enemy_name)
            if enemy:
                available_enemies.append(enemy)
    
    if wave_level >= 5:
        var elite = ["berserker", "ghost", "exploder"]
        for enemy_name in elite:
            var enemy = get_enemy(enemy_name)
            if enemy:
                available_enemies.append(enemy)
    
    if wave_level >= 8:
        var special = ["healer", "mimic", "spawner", "elite"]
        for enemy_name in special:
            var enemy = get_enemy(enemy_name)
            if enemy:
                available_enemies.append(enemy)
    
    if available_enemies.is_empty():
        return get_random_enemy()
    
    return available_enemies[randi() % available_enemies.size()]

# === DATA VALIDATION ===

func validate_all_data() -> bool:
    """Validate all loaded data for consistency"""
    var is_valid = true
    
    # Validate weapons
    for weapon in weapon_data_cache.values():
        if not validate_weapon_data(weapon):
            is_valid = false
    
    # Validate enemies
    for enemy in enemy_data_cache.values():
        if not validate_enemy_data(enemy):
            is_valid = false
    
    # Validate bosses
    for boss in boss_data_cache.values():
        if not validate_boss_data(boss):
            is_valid = false
    
    return is_valid

func validate_weapon_data(weapon: WeaponData) -> bool:
    """Validate weapon data for required fields"""
    if weapon.weapon_name.is_empty():
        print("❌ Weapon missing name")
        return false
    if weapon.damage <= 0:
        print("❌ Weapon %s has invalid damage: %d" % [weapon.weapon_name, weapon.damage])
        return false
    if weapon.attack_speed <= 0:
        print("❌ Weapon %s has invalid attack speed: %f" % [weapon.weapon_name, weapon.attack_speed])
        return false
    return true

func validate_enemy_data(enemy: EnemyData) -> bool:
    """Validate enemy data for required fields"""
    if enemy.enemy_name.is_empty():
        print("❌ Enemy missing name")
        return false
    if enemy.max_health <= 0:
        print("❌ Enemy %s has invalid health: %d" % [enemy.enemy_name, enemy.max_health])
        return false
    if enemy.movement_speed < 0:
        print("❌ Enemy %s has invalid speed: %f" % [enemy.enemy_name, enemy.movement_speed])
        return false
    return true

func validate_boss_data(boss: BossData) -> bool:
    """Validate boss data for required fields"""
    if boss.boss_name.is_empty():
        print("❌ Boss missing name")
        return false
    if boss.base_health <= 0:
        print("❌ Boss %s has invalid health: %d" % [boss.boss_name, boss.base_health])
        return false
    return true

# === DEBUGGING FUNCTIONS ===

func print_data_summary():
    """Print summary of all loaded data"""
    print("=== DATA MANAGER SUMMARY ===")
    print("Weapons: %d" % weapon_data_cache.size())
    for weapon in weapon_data_cache.values():
        print("  - %s (%s)" % [weapon.weapon_name, weapon.weapon_type])
    
    print("Enemies: %d" % enemy_data_cache.size())
    for enemy in enemy_data_cache.values():
        print("  - %s (HP: %d, Speed: %.0f)" % [enemy.enemy_name, enemy.max_health, enemy.movement_speed])
    
    print("Bosses: %d" % boss_data_cache.size())
    for boss in boss_data_cache.values():
        print("  - %s (HP: %d, Type: %s)" % [boss.boss_name, boss.base_health, boss.boss_type])
    
    print("===========================")

func reload_all_data():
    """Reload all data resources (for development)"""
    weapon_data_cache.clear()
    enemy_data_cache.clear()
    boss_data_cache.clear()
    upgrade_data_cache.clear()
    
    load_all_data()
    print("🔄 All data reloaded")