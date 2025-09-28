# MetaUpgradeData.gd - 永久升级数据结构 (Epic 2.1)
extends Resource
class_name MetaUpgradeData

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var max_level: int = 10
@export var cost_per_level: Array[int] = []
@export var stat_to_modify: String = ""
@export var value_per_level: Array[float] = []

# Visual
@export var icon_path: String = ""
@export var upgrade_category: String = "COMBAT"  # COMBAT, SURVIVAL, UTILITY

func get_cost_for_level(level: int) -> int:
    """获取指定等级的升级成本"""
    if level <= 0 or level > max_level:
        return -1
    
    if level <= cost_per_level.size():
        return cost_per_level[level - 1]
    else:
        # 如果没有定义足够的等级，使用指数增长
        var base_cost = cost_per_level[-1] if not cost_per_level.is_empty() else 100
        return int(base_cost * pow(1.5, level - cost_per_level.size()))

func get_value_for_level(level: int) -> float:
    """获取指定等级的属性加成值"""
    if level <= 0 or level > max_level:
        return 0.0
    
    if level <= value_per_level.size():
        return value_per_level[level - 1]
    else:
        # 如果没有定义足够的等级，使用线性增长
        var base_value = value_per_level[-1] if not value_per_level.is_empty() else 0.1
        return base_value * level

func get_total_value_at_level(level: int) -> float:
    """获取指定等级的累计属性加成"""
    var total = 0.0
    for i in range(1, level + 1):
        total += get_value_for_level(i)
    return total