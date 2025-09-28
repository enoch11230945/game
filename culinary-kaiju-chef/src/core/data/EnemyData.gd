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

# Compatibility properties for direct access (Linus: eliminate special cases)
func get_wobble_amplitude() -> float:
    return wobble_amplitude

func get_wobble_frequency() -> float:
    return wobble_frequency

func get_charge_interval() -> float:
    return charge_interval

func get_charge_duration() -> float:
    return charge_duration

func get_charge_multiplier() -> float:
    return charge_multiplier

func get_separation_radius() -> float:
    return separation_radius

func get_separation_strength() -> float:
    return separation_strength