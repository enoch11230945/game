# EnemyData.gd - Data-driven enemy system as required by Linus
# "Good programmers worry about data structures" - Linus Torvalds
extends Resource
class_name EnemyData

@export var enemy_name: String = "Basic Enemy"
@export var max_health: int = 50
@export var health: int = 50  # Alias for max_health (compatibility)
@export var movement_speed: float = 80.0
@export var speed: float = 80.0  # Alias for movement_speed (compatibility)
@export var damage: int = 10
@export var experience_reward: int = 15
@export var xp_reward: int = 15  # Alias for experience_reward (compatibility)
@export var enemy_type: String = "melee"  # "melee", "ranged", "boss"

# Visual data
@export var enemy_color: Color = Color.RED
@export var enemy_size: Vector2 = Vector2(40, 40)
@export var enemy_scene: PackedScene
@export var sprite_texture: Texture2D
@export var sprite_scale: Vector2 = Vector2.ONE
@export var sprite_modulate: Color = Color.WHITE

# Behavior data
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 2.0
@export var follow_distance: float = 600.0
@export var separation_radius: float = 30.0
@export var separation_strength: float = 0.5

# Special movement patterns
@export var wobble_amplitude: float = 0.0
@export var wobble_frequency: float = 2.0
@export var charge_interval: float = 0.0
@export var charge_duration: float = 0.5
@export var charge_multiplier: float = 2.0

# Scaling with level
@export var health_per_level: int = 8
@export var speed_per_level: float = 3.0
@export var damage_per_level: int = 2
@export var xp_per_level: int = 2

# Special abilities
@export var can_shoot: bool = false
@export var projectile_speed: float = 180.0
@export var projectile_damage: int = 12
@export var shoot_cooldown: float = 2.0

# Death effects
@export var death_effect: String = ""  # "explode", "split", "spawn", etc.
@export var death_value: int = 0       # Explosion radius, split count, etc.

# Compatibility functions for various property access patterns
func get(property: String, default_value = null):
    match property:
        "wobble_amplitude": return wobble_amplitude
        "wobble_frequency": return wobble_frequency
        "charge_interval": return charge_interval
        "charge_duration": return charge_duration
        "charge_multiplier": return charge_multiplier
        "separation_radius": return separation_radius
        "separation_strength": return separation_strength
        _: return default_value

func has_method(method_name: String) -> bool:
    return method_name == "get"