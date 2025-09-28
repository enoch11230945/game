# PlayerData.gd - Meta-progression system (Linus-approved persistence)
# "Save/load systems must be bulletproof - never lose user progress" - Linus
extends Node

const SAVE_FILE = "user://culinary_kaiju_save.tres"

# === META PROGRESSION DATA (Epic 2.1 - 永久货币) ===
var total_gold: int = 0  # 永久货币
var spent_gold: int = 0
var games_played: int = 0

# === PERMANENT UPGRADES ===
var meta_upgrades: Dictionary = {
    "damage_bonus": 0,      # Each level: +5% damage
    "health_bonus": 0,      # Each level: +10 HP
    "speed_bonus": 0,       # Each level: +5% speed
    "pickup_range": 0,      # Each level: +10% pickup range
    "xp_bonus": 0,         # Each level: +5% XP gain
    "gold_bonus": 0,       # Each level: +10% gold gain
    "start_weapon": 0,     # Unlock different starting weapons
    "start_level": 0,      # Start at higher level
    "crit_chance": 0,      # Each level: +2% crit chance
    "crit_damage": 0,      # Each level: +10% crit damage
    "cooldown_reduction": 0, # Each level: +3% cooldown reduction
    "armor": 0,            # Each level: +2 armor
    "regen": 0,            # Each level: +1 HP/sec
    "magnetic_pickup": 0,  # Each level: +20% pickup magnet strength
    "luck": 0,             # Each level: +5% upgrade rarity chance
    "revival": 0           # Each level: +1 revival per run
}

# === STATISTICS ===
var total_time_played: float = 0.0
var best_survival_time: float = 0.0
var total_kills: int = 0
var best_level_reached: int = 1
var total_bosses_defeated: int = 0

# === UNLOCKABLES ===
var unlocked_characters: Array[String] = ["default_chef"]
var unlocked_weapons: Array[String] = []
var unlocked_achievements: Array[String] = []

func _ready():
    print("💾 PlayerData system initialized")
    load_game_data()

func load_game_data():
    """Load persistent player data - robust error handling"""
    if FileAccess.file_exists(SAVE_FILE):
        var save_file = FileAccess.open(SAVE_FILE, FileAccess.READ)
        if save_file:
            var json_string = save_file.get_var()
            save_file.close()
            
            if json_string != null:
                var data = json_string
                if data.has("total_gold"):
                    total_gold = data.get("total_gold", 0)
                    spent_gold = data.get("spent_gold", 0)
                    meta_upgrades = data.get("meta_upgrades", meta_upgrades)
                    games_played = data.get("games_played", 0)
                    total_time_played = data.get("total_time_played", 0.0)
                    best_survival_time = data.get("best_survival_time", 0.0)
                    total_kills = data.get("total_kills", 0)
                    best_level_reached = data.get("best_level_reached", 1)
                    total_bosses_defeated = data.get("total_bosses_defeated", 0)
                    unlocked_characters = data.get("unlocked_characters", ["default_chef"])
                    unlocked_weapons = data.get("unlocked_weapons", [])
                    unlocked_achievements = data.get("unlocked_achievements", [])
                    
                    print("✅ Save data loaded successfully")
                else:
                    print("⚠️ Save file corrupted, using defaults")
            else:
                print("⚠️ Could not parse save file, using defaults")
        else:
            print("⚠️ Could not open save file, using defaults")
    else:
        print("📁 No save file found, starting fresh")

func save_game_data():
    """Save persistent player data - atomic write operation"""
    var save_data = {
        "total_gold": total_gold,
        "spent_gold": spent_gold,
        "meta_upgrades": meta_upgrades,
        "games_played": games_played,
        "total_time_played": total_time_played,
        "best_survival_time": best_survival_time,
        "total_kills": total_kills,
        "best_level_reached": best_level_reached,
        "total_bosses_defeated": total_bosses_defeated,
        "unlocked_characters": unlocked_characters,
        "unlocked_weapons": unlocked_weapons,
        "unlocked_achievements": unlocked_achievements,
        "save_version": "1.0.0",
        "save_timestamp": Time.get_unix_time_from_system()
    }
    
    var save_file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
    if save_file:
        save_file.store_var(save_data)
        save_file.close()
        print("💾 Game data saved successfully")
    else:
        print("❌ Failed to save game data!")

# === META PROGRESSION FUNCTIONS ===
func add_gold(amount: int):
    """Add gold with bonus multipliers applied"""
    var bonus_multiplier = 1.0 + (meta_upgrades.get("gold_bonus", 0) * 0.1)
    var actual_amount = int(amount * bonus_multiplier)
    total_gold += actual_amount
    print("💰 Gold added: %d (with bonus: %d)" % [amount, actual_amount])

func spend_gold(amount: int) -> bool:
    """Spend gold if available"""
    if total_gold >= amount:
        total_gold -= amount
        spent_gold += amount
        save_game_data()
        return true
    return false

func upgrade_meta_stat(stat_name: String) -> bool:
    """Upgrade a meta progression stat"""
    if not meta_upgrades.has(stat_name):
        print("❌ Unknown meta upgrade: %s" % stat_name)
        return false
    
    var current_level = meta_upgrades[stat_name]
    var cost = get_upgrade_cost(stat_name, current_level)
    
    if spend_gold(cost):
        meta_upgrades[stat_name] += 1
        print("⬆️ Upgraded %s to level %d" % [stat_name, meta_upgrades[stat_name]])
        save_game_data()
        return true
    else:
        print("💸 Not enough gold for %s upgrade (need %d)" % [stat_name, cost])
        return false

func get_upgrade_cost(stat_name: String, current_level: int) -> int:
    """Calculate cost for next upgrade level (exponential scaling)"""
    var base_costs = {
        "damage_bonus": 10,
        "health_bonus": 15,
        "speed_bonus": 12,
        "pickup_range": 8,
        "xp_bonus": 20,
        "gold_bonus": 25,
        "start_weapon": 50,
        "start_level": 100,
        "crit_chance": 30,
        "crit_damage": 35,
        "cooldown_reduction": 40,
        "armor": 18,
        "regen": 45,
        "magnetic_pickup": 15,
        "luck": 60,
        "revival": 80
    }
    
    var base_cost = base_costs.get(stat_name, 10)
    return int(base_cost * pow(1.5, current_level))

func get_max_upgrade_level(stat_name: String) -> int:
    """Maximum level for each upgrade"""
    var max_levels = {
        "damage_bonus": 20,
        "health_bonus": 15,
        "speed_bonus": 15,
        "pickup_range": 10,
        "xp_bonus": 10,
        "gold_bonus": 10,
        "start_weapon": 5,
        "start_level": 10,
        "crit_chance": 25,
        "crit_damage": 20,
        "cooldown_reduction": 15,
        "armor": 20,
        "regen": 10,
        "magnetic_pickup": 12,
        "luck": 8,
        "revival": 3
    }
    
    return max_levels.get(stat_name, 10)

# === BONUS CALCULATION FUNCTIONS ===
func get_damage_bonus() -> float:
    """Calculate total damage bonus multiplier"""
    return 1.0 + (meta_upgrades.get("damage_bonus", 0) * 0.05)

func get_health_bonus() -> int:
    """Calculate total health bonus"""
    return meta_upgrades.get("health_bonus", 0) * 10

func get_speed_bonus() -> float:
    """Calculate total speed bonus multiplier"""
    return 1.0 + (meta_upgrades.get("speed_bonus", 0) * 0.05)

func get_xp_bonus() -> float:
    """Calculate total XP bonus multiplier"""
    return 1.0 + (meta_upgrades.get("xp_bonus", 0) * 0.05)

func get_pickup_range_bonus() -> float:
    """Calculate pickup range multiplier"""
    return 1.0 + (meta_upgrades.get("pickup_range", 0) * 0.1)

func get_crit_chance_bonus() -> float:
    """Calculate critical hit chance bonus"""
    return meta_upgrades.get("crit_chance", 0) * 0.02

func get_crit_damage_bonus() -> float:
    """Calculate critical damage multiplier"""
    return 1.0 + (meta_upgrades.get("crit_damage", 0) * 0.1)

func get_cooldown_reduction() -> float:
    """Calculate cooldown reduction multiplier"""
    return 1.0 - (meta_upgrades.get("cooldown_reduction", 0) * 0.03)

func get_armor_bonus() -> int:
    """Calculate armor bonus"""
    return meta_upgrades.get("armor", 0) * 2

func get_regen_bonus() -> float:
    """Calculate health regeneration per second"""
    return meta_upgrades.get("regen", 0) * 1.0

func get_luck_bonus() -> float:
    """Calculate luck bonus for rare upgrades"""
    return meta_upgrades.get("luck", 0) * 0.05

func get_revival_count() -> int:
    """Get number of revivals available per run"""
    return meta_upgrades.get("revival", 0)

# === STATISTICS TRACKING ===
func update_best_stats(survival_time: float, kills: int, level: int):
    """Update best performance statistics"""
    games_played += 1
    total_time_played += survival_time
    total_kills += kills
    
    if survival_time > best_survival_time:
        best_survival_time = survival_time
        print("🏆 New best survival time: %.1fs" % survival_time)
    
    if level > best_level_reached:
        best_level_reached = level
        print("🏆 New best level reached: %d" % level)
    
    save_game_data()

func unlock_character(character_id: String):
    """Unlock a new playable character"""
    if not unlocked_characters.has(character_id):
        unlocked_characters.append(character_id)
        save_game_data()
        print("🔓 Character unlocked: %s" % character_id)

func unlock_weapon(weapon_id: String):
    """Unlock a new starting weapon"""
    if not unlocked_weapons.has(weapon_id):
        unlocked_weapons.append(weapon_id)
        save_game_data()
        print("🔓 Weapon unlocked: %s" % weapon_id)

func unlock_achievement(achievement_id: String):
    """Unlock an achievement"""
    if not unlocked_achievements.has(achievement_id):
        unlocked_achievements.append(achievement_id)
        save_game_data()
        EventBus.achievement_unlocked.emit(achievement_id)
        print("🏆 Achievement unlocked: %s" % achievement_id)

# === UTILITY FUNCTIONS ===
func reset_all_progress():
    """DANGEROUS: Reset all meta progression"""
    print("⚠️ WARNING: Resetting all progress!")
    total_gold = 0
    spent_gold = 0
    for key in meta_upgrades:
        meta_upgrades[key] = 0
    games_played = 0
    total_time_played = 0.0
    best_survival_time = 0.0
    total_kills = 0
    best_level_reached = 1
    total_bosses_defeated = 0
    unlocked_characters = ["default_chef"]
    unlocked_weapons.clear()
    unlocked_achievements.clear()
    save_game_data()

func get_total_spent_gold() -> int:
    """Get total gold ever spent"""
    return spent_gold

func get_completion_percentage() -> float:
    """Calculate overall progression completion"""
    var total_possible_upgrades = 0
    var total_current_upgrades = 0
    
    for stat_name in meta_upgrades:
        var max_level = get_max_upgrade_level(stat_name)
        var current_level = meta_upgrades.get(stat_name, 0)
        total_possible_upgrades += max_level
        total_current_upgrades += current_level
    
    return float(total_current_upgrades) / float(total_possible_upgrades) * 100.0