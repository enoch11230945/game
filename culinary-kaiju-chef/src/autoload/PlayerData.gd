# PlayerData.gd
extends Node

const SAVE_FILE_PATH = "user://player_data.save"

# Persistent player data
var coins: int = 0
var total_games_played: int = 0
var best_score: int = 0
var best_time: float = 0.0
var total_enemies_killed: int = 0
var last_run: Dictionary = {} # {score, level, time, kills, dps_snapshot: {weapon:dps}}

# Permanent upgrades - Enhanced
var permanent_upgrades: Dictionary = {}
var unlocked_characters: Array[String] = ["default_chef"]  # Available characters
var selected_character: String = "default_chef"

# Meta progression stats
var lifetime_stats: Dictionary = {
    "total_damage_dealt": 0,
    "total_time_played": 0.0,
    "highest_level_reached": 1,
    "bosses_defeated": 0,
    "weapons_evolved": 0
}

# Settings
var music_volume: float = 0.8
var sfx_volume: float = 0.8
var master_volume: float = 1.0

signal data_loaded
signal data_saved

func _ready() -> void:
    load_data()
    
    # Connect to EventBus for automatic saving
    EventBus.coins_changed.connect(_on_coins_changed)

func save_data() -> void:
    var save_dict = {
        "coins": coins,
        "total_games_played": total_games_played,
        "best_score": best_score,
        "best_time": best_time,
        "total_enemies_killed": total_enemies_killed,
        "last_run": last_run,
        "permanent_upgrades": permanent_upgrades,
        "music_volume": music_volume,
        "sfx_volume": sfx_volume,
        "master_volume": master_volume,
        "version": "1.0.0"
    }
    
    var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
    if save_file:
        save_file.store_string(JSON.stringify(save_dict))
        save_file.close()
        data_saved.emit()
        print("Player data saved successfully")
    else:
        print("Failed to save player data")

func load_data() -> void:
    if not FileAccess.file_exists(SAVE_FILE_PATH):
        print("No save file found, using default values")
        data_loaded.emit()
        return
    
    var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
    if save_file:
        var json_string = save_file.get_as_text()
        save_file.close()
        
        var json = JSON.new()
        var parse_result = json.parse(json_string)
        
        if parse_result == OK:
            var save_dict = json.data
            
            # Load data with defaults if missing
            coins = save_dict.get("coins", 0)
            total_games_played = save_dict.get("total_games_played", 0)
            best_score = save_dict.get("best_score", 0)
            best_time = save_dict.get("best_time", 0.0)
            total_enemies_killed = save_dict.get("total_enemies_killed", 0)
            last_run = save_dict.get("last_run", {})
            permanent_upgrades = save_dict.get("permanent_upgrades", {})
            music_volume = save_dict.get("music_volume", 0.8)
            sfx_volume = save_dict.get("sfx_volume", 0.8)
            master_volume = save_dict.get("master_volume", 1.0)
            
            print("Player data loaded successfully")
        else:
            print("Failed to parse save file")
        
        data_loaded.emit()
    else:
        print("Failed to open save file")
        data_loaded.emit()

func add_coins(amount: int) -> void:
    coins += amount
    EventBus.coins_changed.emit(coins)

func spend_coins(amount: int) -> bool:
    if coins >= amount:
        coins -= amount
        EventBus.coins_changed.emit(coins)
        return true
    return false

func update_game_stats(score: int, time: float, enemies_killed: int) -> void:
    total_games_played += 1
    total_enemies_killed += enemies_killed
    
    if score > best_score:
        best_score = score
    
    if time > best_time:
        best_time = time
    
    # Add coins based on performance
    var coins_earned = score / 100 # 1 coin per 100 points
    add_coins(coins_earned)
    
    save_data()

func purchase_permanent_upgrade(upgrade_id: String, cost: int) -> bool:
    if spend_coins(cost):
        permanent_upgrades[upgrade_id] = true
        EventBus.permanent_upgrade_purchased.emit(upgrade_id)
        save_data()
        return true
    return false

func has_permanent_upgrade(upgrade_id: String) -> bool:
    return permanent_upgrades.get(upgrade_id, false)

# Enhanced meta progression functions
func get_permanent_upgrade_level(upgrade_id: String) -> int:
    return permanent_upgrades.get(upgrade_id, 0)

func upgrade_permanent_stat(upgrade_id: String, cost: int) -> bool:
    if spend_coins(cost):
        var current_level = permanent_upgrades.get(upgrade_id, 0)
        permanent_upgrades[upgrade_id] = current_level + 1
        EventBus.permanent_upgrade_purchased.emit(upgrade_id)
        save_data()
        return true
    return false

func unlock_character(character_id: String, cost: int) -> bool:
    if character_id in unlocked_characters:
        return false
    
    if spend_coins(cost):
        unlocked_characters.append(character_id)
        save_data()
        return true
    return false

func select_character(character_id: String) -> bool:
    if character_id in unlocked_characters:
        selected_character = character_id
        save_data()
        return true
    return false

func update_lifetime_stats(stats: Dictionary) -> void:
    for key in stats:
        if key in lifetime_stats:
            match key:
                "total_damage_dealt", "bosses_defeated", "weapons_evolved":
                    lifetime_stats[key] += stats[key]
                "total_time_played":
                    lifetime_stats[key] += stats[key]
                "highest_level_reached":
                    lifetime_stats[key] = max(lifetime_stats[key], stats[key])

func get_permanent_bonuses() -> Dictionary:
    # Calculate bonuses from permanent upgrades
    var bonuses = {
        "health_bonus": get_permanent_upgrade_level("health") * 10,
        "damage_bonus": get_permanent_upgrade_level("damage") * 0.05,
        "speed_bonus": get_permanent_upgrade_level("speed") * 0.1,
        "coin_multiplier": 1.0 + get_permanent_upgrade_level("luck") * 0.1,
        "xp_multiplier": 1.0 + get_permanent_upgrade_level("wisdom") * 0.05
    }
    
    return bonuses

func _on_coins_changed(_new_amount: int) -> void:
    # Auto-save when coins change
    call_deferred("save_data")