# ItemData.gd - Data-driven passive item system (Linus approved)
extends Resource
class_name ItemData

@export var item_name: String = "Basic Item"
@export var description: String = "A basic passive item"
@export var item_type: String = "passive"  # "passive", "active", "consumable"
@export var rarity: String = "common"      # "common", "rare", "epic", "legendary"
@export var unlock_level: int = 1
@export var max_stack: int = 1            # How many times this item can be stacked

# Passive effects (applied continuously)
@export var health_bonus: int = 0
@export var speed_bonus: float = 0.0
@export var damage_multiplier: float = 1.0
@export var attack_speed_multiplier: float = 1.0
@export var range_multiplier: float = 1.0
@export var penetration_bonus: int = 0
@export var projectile_count_bonus: int = 0

# Special effects
@export var pickup_range_multiplier: float = 1.0
@export var xp_multiplier: float = 1.0
@export var cooldown_reduction: float = 0.0  # Percentage reduction (0.1 = 10% faster)
@export var crit_chance: float = 0.0         # Percentage (0.15 = 15% crit chance)
@export var crit_multiplier: float = 1.5

# Visual data
@export var item_color: Color = Color.WHITE
@export var item_icon: Texture2D
@export var particle_effect: String = ""

# Upgrade scaling
@export var health_per_stack: int = 0
@export var speed_per_stack: float = 0.0
@export var damage_per_stack: float = 0.0

# Evolution requirements (for item combinations)
@export var evolution_requirements: Array[ItemData] = []
@export var evolution_result: ItemData

# Special behaviors (implemented in code)
@export var special_effect: String = ""  # "vampire", "explosive", "freezing", etc.
@export var effect_chance: float = 0.0   # Chance for special effect to trigger
@export var effect_value: float = 0.0    # Magnitude of special effect

func get_total_bonus(stat_name: String, stack_count: int) -> float:
    """Calculate total bonus for a stat based on stack count"""
    match stat_name:
        "health":
            return health_bonus + (health_per_stack * (stack_count - 1))
        "speed":
            return speed_bonus + (speed_per_stack * (stack_count - 1))
        "damage":
            return damage_multiplier + (damage_per_stack * (stack_count - 1))
        _:
            return 0.0

func can_stack_with(other_item: ItemData) -> bool:
    """Check if this item can stack with another item"""
    return other_item.item_name == item_name and max_stack > 1