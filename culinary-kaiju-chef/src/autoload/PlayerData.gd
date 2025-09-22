# PlayerData.gd
extends Node

const SAVE_PATH = "user://player_data.save"

# 玩家元數據
var player_name: String = "Chef"
var total_score: int = 0
var highest_level: int = 1
var total_playtime: float = 0.0

# 永久性升級
var permanent_upgrades: Dictionary = {
    "health_bonus": 0,
    "speed_bonus": 0,
    "damage_bonus": 0,
    "xp_multiplier": 1.0
}

# 已解鎖的內容
var unlocked_characters: Array[String] = ["default_chef"]
var unlocked_weapons: Array[String] = ["throwing_knife"]
var unlocked_items: Array[String] = []

# 統計數據
var games_played: int = 0
var enemies_killed: int = 0
var total_xp_gained: int = 0

func _ready() -> void:
    load_data()

func save_data() -> void:
    var data = {
        "player_name": player_name,
        "total_score": total_score,
        "highest_level": highest_level,
        "total_playtime": total_playtime,
        "permanent_upgrades": permanent_upgrades,
        "unlocked_characters": unlocked_characters,
        "unlocked_weapons": unlocked_weapons,
        "unlocked_items": unlocked_items,
        "games_played": games_played,
        "enemies_killed": enemies_killed,
        "total_xp_gained": total_xp_gained
    }

    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_var(data)
        file.close()
        print("Player data saved successfully")

func load_data() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        print("No save file found, using defaults")
        return

    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file:
        var data = file.get_var()
        file.close()

        player_name = data.get("player_name", "Chef")
        total_score = data.get("total_score", 0)
        highest_level = data.get("highest_level", 1)
        total_playtime = data.get("total_playtime", 0.0)
        permanent_upgrades = data.get("permanent_upgrades", permanent_upgrades)
        unlocked_characters = data.get("unlocked_characters", unlocked_characters)
        unlocked_weapons = data.get("unlocked_weapons", unlocked_weapons)
        unlocked_items = data.get("unlocked_items", unlocked_items)
        games_played = data.get("games_played", 0)
        enemies_killed = data.get("enemies_killed", 0)
        total_xp_gained = data.get("total_xp_gained", 0)

        print("Player data loaded successfully")

func update_stats(score: int, level: int, playtime: float, xp_gained: int) -> void:
    total_score = max(total_score, score)
    highest_level = max(highest_level, level)
    total_playtime += playtime
    total_xp_gained += xp_gained
    games_played += 1

    save_data()

func add_permanent_upgrade(upgrade_type: String, value: float) -> void:
    if permanent_upgrades.has(upgrade_type):
        permanent_upgrades[upgrade_type] += value
        save_data()

func unlock_content(content_type: String, content_id: String) -> void:
    var array_key = "unlocked_" + content_type + "s"
    if has(array_key):
        var content_array = get(array_key)
        if not content_array.has(content_id):
            content_array.append(content_id)
            save_data()

func get_stat(key: String):
    return get(key)

func has(key: String) -> bool:
    return get(key) != null
