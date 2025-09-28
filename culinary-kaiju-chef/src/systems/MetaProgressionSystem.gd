# MetaProgressionSystem.gd - 元进程管理器 (Epic 2.1)
extends Node

# === META UPGRADE DATA ===
var available_upgrades: Array[MetaUpgradeData] = []
var current_upgrade_levels: Dictionary = {}

func _ready() -> void:
    print("💰 MetaProgressionSystem initialized")
    _load_all_meta_upgrades()
    _connect_events()

func _load_all_meta_upgrades() -> void:
    """加载所有元升级数据"""
    var upgrade_paths = [
        "res://src/core/data/meta_upgrades/health_bonus.tres",
        "res://src/core/data/meta_upgrades/damage_bonus.tres", 
        "res://src/core/data/meta_upgrades/speed_bonus.tres"
    ]
    
    for path in upgrade_paths:
        if ResourceLoader.exists(path):
            var upgrade = load(path)
            if upgrade is MetaUpgradeData:
                available_upgrades.append(upgrade)
                current_upgrade_levels[upgrade.id] = PlayerData.meta_upgrades.get(upgrade.id, 0)
                print("✅ Loaded meta upgrade: %s" % upgrade.name)

func _connect_events() -> void:
    """连接相关事件"""
    EventBus.game_over.connect(_on_game_over)

func add_gold(amount: int) -> void:
    """添加金币并保存"""
    PlayerData.total_gold += amount
    print("💰 Gained %d gold (Total: %d)" % [amount, PlayerData.total_gold])
    save_progress()

func can_purchase_upgrade(upgrade_id: String) -> bool:
    """检查是否能购买升级"""
    var upgrade = get_upgrade_by_id(upgrade_id)
    if not upgrade:
        return false
    
    var current_level = current_upgrade_levels.get(upgrade_id, 0)
    if current_level >= upgrade.max_level:
        return false
    
    var cost = upgrade.get_cost_for_level(current_level + 1)
    return PlayerData.total_gold >= cost

func purchase_upgrade(upgrade_id: String) -> bool:
    """购买升级"""
    if not can_purchase_upgrade(upgrade_id):
        return false
    
    var upgrade = get_upgrade_by_id(upgrade_id)
    var current_level = current_upgrade_levels.get(upgrade_id, 0)
    var cost = upgrade.get_cost_for_level(current_level + 1)
    
    # 扣除金币
    PlayerData.total_gold -= cost
    PlayerData.spent_gold += cost
    
    # 提升等级
    current_level += 1
    current_upgrade_levels[upgrade_id] = current_level
    PlayerData.meta_upgrades[upgrade_id] = current_level
    
    # 应用升级效果
    apply_upgrade_effects()
    
    # 保存进度
    save_progress()
    
    print("⬆️ Purchased %s level %d for %d gold" % [upgrade.name, current_level, cost])
    return true

func apply_upgrade_effects() -> void:
    """应用所有永久升级效果"""
    # 重置修改器
    PlayerData.max_health_modifier = 0.0
    PlayerData.damage_modifier = 0.0
    PlayerData.speed_modifier = 0.0
    PlayerData.pickup_range_modifier = 0.0
    PlayerData.xp_gain_modifier = 0.0
    PlayerData.gold_gain_modifier = 0.0
    
    # 应用每个升级的效果
    for upgrade in available_upgrades:
        var level = current_upgrade_levels.get(upgrade.id, 0)
        if level > 0:
            var total_value = upgrade.get_total_value_at_level(level)
            match upgrade.stat_to_modify:
                "max_health_modifier":
                    PlayerData.max_health_modifier += total_value
                "damage_modifier":
                    PlayerData.damage_modifier += total_value
                "speed_modifier":
                    PlayerData.speed_modifier += total_value
                "pickup_range_modifier":
                    PlayerData.pickup_range_modifier += total_value
                "xp_gain_modifier":
                    PlayerData.xp_gain_modifier += total_value
                "gold_gain_modifier":
                    PlayerData.gold_gain_modifier += total_value
    
    print("🔧 Applied meta upgrades: HP+%.0f, DMG+%.0f%%, SPD+%.0f%%" % [
        PlayerData.max_health_modifier,
        PlayerData.damage_modifier * 100,
        PlayerData.speed_modifier * 100
    ])

func get_upgrade_by_id(upgrade_id: String) -> MetaUpgradeData:
    """根据ID获取升级数据"""
    for upgrade in available_upgrades:
        if upgrade.id == upgrade_id:
            return upgrade
    return null

func get_upgrade_level(upgrade_id: String) -> int:
    """获取升级当前等级"""
    return current_upgrade_levels.get(upgrade_id, 0)

func get_upgrade_cost(upgrade_id: String) -> int:
    """获取升级下一等级的成本"""
    var upgrade = get_upgrade_by_id(upgrade_id)
    if not upgrade:
        return -1
    
    var current_level = get_upgrade_level(upgrade_id)
    if current_level >= upgrade.max_level:
        return -1
    
    return upgrade.get_cost_for_level(current_level + 1)

func save_progress() -> void:
    """保存永久进度"""
    var save_data = {
        "total_gold": PlayerData.total_gold,
        "spent_gold": PlayerData.spent_gold,
        "games_played": PlayerData.games_played,
        "meta_upgrades": PlayerData.meta_upgrades,
        "unlocked_characters": PlayerData.unlocked_characters,
        "selected_character": PlayerData.selected_character
    }
    
    var file = FileAccess.open(PlayerData.SAVE_FILE, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data))
        file.close()
        print("💾 Progress saved")
    else:
        print("❌ Failed to save progress")

func load_progress() -> void:
    """加载永久进度"""
    if not FileAccess.file_exists(PlayerData.SAVE_FILE):
        print("📁 No save file found, starting fresh")
        return
    
    var file = FileAccess.open(PlayerData.SAVE_FILE, FileAccess.READ)
    if not file:
        print("❌ Failed to load save file")
        return
    
    var json_text = file.get_as_text()
    file.close()
    
    var json = JSON.new()
    var result = json.parse(json_text)
    if result != OK:
        print("❌ Failed to parse save file")
        return
    
    var save_data = json.data
    
    # 恢复数据
    PlayerData.total_gold = save_data.get("total_gold", 0)
    PlayerData.spent_gold = save_data.get("spent_gold", 0) 
    PlayerData.games_played = save_data.get("games_played", 0)
    PlayerData.meta_upgrades = save_data.get("meta_upgrades", {})
    PlayerData.unlocked_characters = save_data.get("unlocked_characters", ["default_chef"])
    PlayerData.selected_character = save_data.get("selected_character", "default_chef")
    
    # 同步升级等级
    for upgrade_id in PlayerData.meta_upgrades:
        current_upgrade_levels[upgrade_id] = PlayerData.meta_upgrades[upgrade_id]
    
    # 应用升级效果
    apply_upgrade_effects()
    
    print("📂 Progress loaded: %d gold, %d games played" % [PlayerData.total_gold, PlayerData.games_played])

# === EVENT HANDLERS ===
func _on_game_over(final_score: int, time_survived: float) -> void:
    """游戏结束时统计并保存"""
    PlayerData.games_played += 1
    
    # 根据游戏表现奖励金币
    var base_gold = int(time_survived / 10.0)  # 每10秒1金币
    var score_bonus = int(final_score / 100.0)  # 每100分1金币
    var total_gold_reward = base_gold + score_bonus
    
    # 应用金币加成
    if PlayerData.gold_gain_modifier > 0:
        total_gold_reward = int(total_gold_reward * (1.0 + PlayerData.gold_gain_modifier))
    
    add_gold(total_gold_reward)
    
    print("🎮 Game ended: %.1fs, %d score → %d gold reward" % [time_survived, final_score, total_gold_reward])

# === UTILITY FUNCTIONS ===
func get_all_upgrades_info() -> Array[Dictionary]:
    """获取所有升级信息用于UI显示"""
    var upgrades_info: Array[Dictionary] = []
    
    for upgrade in available_upgrades:
        var current_level = get_upgrade_level(upgrade.id)
        var info = {
            "id": upgrade.id,
            "name": upgrade.name,
            "description": upgrade.description,
            "current_level": current_level,
            "max_level": upgrade.max_level,
            "next_cost": get_upgrade_cost(upgrade.id),
            "can_purchase": can_purchase_upgrade(upgrade.id),
            "category": upgrade.upgrade_category
        }
        upgrades_info.append(info)
    
    return upgrades_info