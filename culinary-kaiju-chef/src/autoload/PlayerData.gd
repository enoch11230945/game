extends Node

const SAVE_PATH = "user://player_data.save"

var coins: int = 0
# Dictionary for permanent upgrades, e.g. {"base_health": 10, "base_damage": 1}
var permanent_upgrades: Dictionary = {}

func save_data():
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    var data_to_save = {
        "coins": coins,
        "permanent_upgrades": permanent_upgrades
    }
    file.store_var(data_to_save)

func load_data():
    if not FileAccess.file_exists(SAVE_PATH):
        return

    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    var loaded_data = file.get_var()
    
    coins = loaded_data.get("coins", 0)
    permanent_upgrades = loaded_data.get("permanent_upgrades", {})