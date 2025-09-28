# PlayerData.gd - Epic 2 & 3 統一元進程與商業化系統
extends Node

const SAVE_FILE_PATH = "user://player_data.save"

# === Epic 2: 長期留存系統 ===
# 永久貨幣
var gold: int = 0                       # 主要永久貨幣
var gems: int = 0                       # 高級貨幣（可購買）

# 元進程升級 (Meta-Progression)
var meta_upgrades: Dictionary = {}      # e.g., {"health_bonus": 2, "damage_bonus": 1}

# 角色解鎖系統
var unlocked_characters: Array[String] = ["default_chef"]
var selected_character: String = "default_chef"

# === Epic 3: 商業化數據 ===
# 廣告相關
var ads_removed: bool = false           # 是否購買了去廣告
var daily_ad_rewards_claimed: int = 0   # 今日看廣告次數
var last_daily_reset: String = ""      # 上次每日重置時間

# 統計數據
var total_games_played: int = 0
var best_score: int = 0
var best_time: float = 0.0
var total_enemies_killed: int = 0
var last_run: Dictionary = {}

# 生涯統計
var lifetime_stats: Dictionary = {
    "total_damage_dealt": 0,
    "total_time_played": 0.0,
    "highest_level_reached": 1,
    "bosses_defeated": 0,
    "weapons_evolved": 0,
    "ads_watched": 0,
    "money_spent": 0.0
}

# 設定
var music_volume: float = 0.8
var sfx_volume: float = 0.8
var master_volume: float = 1.0

# 信號
signal data_loaded
signal data_saved
signal gold_changed(new_amount: int)
signal meta_upgrade_purchased(upgrade_id: String, new_level: int)
signal character_unlocked(character_id: String)

func _ready() -> void:
    load_data()
    _reset_daily_data_if_needed()
    
    # 連接事件總線
    if EventBus.has_signal("coins_changed"):
        EventBus.coins_changed.connect(_on_coins_changed)
    
    # 自動保存系統
    var auto_save_timer = Timer.new()
    auto_save_timer.wait_time = 30.0  # 每30秒自動保存
    auto_save_timer.timeout.connect(save_data)
    auto_save_timer.autostart = true
    add_child(auto_save_timer)

# === Epic 2 & 3: 元進程與商業化核心功能 ===

# 每日重置檢查
func _reset_daily_data_if_needed() -> void:
    var current_date = Time.get_date_string_from_system()
    if last_daily_reset != current_date:
        daily_ad_rewards_claimed = 0
        last_daily_reset = current_date
        save_data()

# Epic 2: 元進程核心功能
func add_gold(amount: int) -> void:
    gold += amount
    gold_changed.emit(gold)
    save_data()

func spend_gold(amount: int) -> bool:
    if gold >= amount:
        gold -= amount
        gold_changed.emit(gold)
        save_data()
        return true
    return false

func purchase_meta_upgrade(upgrade_data: MetaUpgradeData) -> bool:
    var current_level = get_meta_upgrade_level(upgrade_data.id)
    if current_level >= upgrade_data.max_level:
        return false  # 已達最大等級
    
    var cost = upgrade_data.get_cost_for_level(current_level)
    if cost < 0 or not spend_gold(cost):
        return false  # 金幣不足或等級錯誤
    
    meta_upgrades[upgrade_data.id] = current_level + 1
    meta_upgrade_purchased.emit(upgrade_data.id, current_level + 1)
    save_data()
    return true

func get_meta_upgrade_level(upgrade_id: String) -> int:
    return meta_upgrades.get(upgrade_id, 0)

func get_meta_upgrade_bonus(upgrade_id: String) -> float:
    var level = get_meta_upgrade_level(upgrade_id)
    if level <= 0:
        return 0.0
    # 這裡需要從 DataManager 獲取升級數據
    # 暫時返回基礎計算
    return level * 5.0  # 臨時實現

# 角色解鎖系統
func unlock_character(character_id: String, cost: int = 0) -> bool:
    if character_id in unlocked_characters:
        return false  # 已解鎖
    
    if cost > 0 and not spend_gold(cost):
        return false  # 金幣不足
    
    unlocked_characters.append(character_id)
    character_unlocked.emit(character_id)
    save_data()
    return true

func select_character(character_id: String) -> bool:
    if character_id in unlocked_characters:
        selected_character = character_id
        save_data()
        return true
    return false

# Epic 3: 商業化功能
func remove_ads() -> void:
    ads_removed = true
    save_data()

func can_watch_daily_ad() -> bool:
    return daily_ad_rewards_claimed < 3  # 每日限制3次

func watch_rewarded_ad() -> void:
    if can_watch_daily_ad():
        daily_ad_rewards_claimed += 1
        lifetime_stats.ads_watched += 1
        save_data()

# 存檔系統
func save_data() -> void:
    var save_dict = {
        # Epic 2: 元進程數據
        "gold": gold,
        "gems": gems,
        "meta_upgrades": meta_upgrades,
        "unlocked_characters": unlocked_characters,
        "selected_character": selected_character,
        
        # Epic 3: 商業化數據
        "ads_removed": ads_removed,
        "daily_ad_rewards_claimed": daily_ad_rewards_claimed,
        "last_daily_reset": last_daily_reset,
        
        # 基礎數據
        "total_games_played": total_games_played,
        "best_score": best_score,
        "best_time": best_time,
        "total_enemies_killed": total_enemies_killed,
        "last_run": last_run,
        "lifetime_stats": lifetime_stats,
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
            
            # Epic 2: 元進程數據
            gold = save_dict.get("gold", 0)
            gems = save_dict.get("gems", 0)
            meta_upgrades = save_dict.get("meta_upgrades", {})
            
            # 修復類型轉換問題
            var loaded_characters = save_dict.get("unlocked_characters", ["default_chef"])
            unlocked_characters.clear()
            for char in loaded_characters:
                unlocked_characters.append(str(char))
            
            selected_character = save_dict.get("selected_character", "default_chef")
            
            # Epic 3: 商業化數據
            ads_removed = save_dict.get("ads_removed", false)
            daily_ad_rewards_claimed = save_dict.get("daily_ad_rewards_claimed", 0)
            last_daily_reset = save_dict.get("last_daily_reset", "")
            
            # 基礎數據
            total_games_played = save_dict.get("total_games_played", 0)
            best_score = save_dict.get("best_score", 0)
            best_time = save_dict.get("best_time", 0.0)
            total_enemies_killed = save_dict.get("total_enemies_killed", 0)
            last_run = save_dict.get("last_run", {})
            lifetime_stats = save_dict.get("lifetime_stats", lifetime_stats)
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

# 更新遊戲統計
func update_game_stats(score: int, time: float, enemies_killed: int) -> void:
    total_games_played += 1
    total_enemies_killed += enemies_killed
    
    if score > best_score:
        best_score = score
    
    if time > best_time:
        best_time = time
    
    # 基於表現給予金幣
    var gold_earned = score / 100  # 每100分獲得1金幣
    add_gold(gold_earned)
    
    save_data()

func _on_coins_changed(_new_amount: int) -> void:
    # 金幣變化時自動保存
    call_deferred("save_data")