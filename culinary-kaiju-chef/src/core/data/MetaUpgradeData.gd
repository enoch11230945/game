# MetaUpgradeData.gd - Epic 2 實現：元進程系統數據結構
extends Resource
class_name MetaUpgradeData

@export var id: String                  # 唯一的英文 ID, e.g., "health_bonus"
@export var display_name: String        # 顯示名稱, e.g., "強身健體"
@export var description: String         # 描述文字模板, e.g., "最大生命值 +{value}%"
@export var icon: Texture2D             # 升級圖標
@export var max_level: int = 5
@export var costs: Array[int]           # 每一級的花費, e.g., [100, 250, 500, 1000, 2000]
@export var values: Array[float]        # 每一級的效果數值, e.g., [5.0, 10.0, 15.0, 20.0, 25.0]
@export var upgrade_type: UpgradeType = UpgradeType.STAT_BONUS

enum UpgradeType {
    STAT_BONUS,      # 屬性加成（血量、傷害等）
    ECONOMIC,        # 經濟相關（金幣獲取率等）
    GAMEPLAY         # 遊戲玩法改變
}

# 獲取當前等級的花費
func get_cost_for_level(current_level: int) -> int:
    if current_level >= costs.size():
        return -1  # 已達到最大等級
    return costs[current_level]

# 獲取當前等級的數值
func get_value_for_level(level: int) -> float:
    if level <= 0 or level > values.size():
        return 0.0
    return values[level - 1]

# 獲取格式化的描述文字
func get_formatted_description(level: int) -> String:
    var value = get_value_for_level(level)
    return description.format({"value": value})