# EnemyData.gd - Data-driven enemy system as required by Linus
# "Good programmers worry about data structures" - Linus Torvalds
extends Resource
class_name EnemyData

@export var enemy_name: String = "Basic Enemy"
@export var max_health: int = 50
@export var movement_speed: float = 80.0
@export var damage: int = 10
@export var experience_reward: int = 15
@export var enemy_type: String = "melee"  # "melee", "ranged", "boss"

# Visual data
@export var enemy_color: Color = Color.RED
@export var enemy_size: Vector2 = Vector2(40, 40)
@export var enemy_scene: PackedScene

# Behavior data
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 2.0
@export var follow_distance: float = 600.0
@export var separation_radius: float = 30.0

# Scaling with level
@export var health_per_level: int = 8
@export var speed_per_level: float = 3.0
@export var damage_per_level: int = 2
@export var xp_per_level: int = 2

# Special abilities
@export var can_shoot: bool = false
@export var projectile_speed: float = 180.0
@export var projectile_damage: int = 12