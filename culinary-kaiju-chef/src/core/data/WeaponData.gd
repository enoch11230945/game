# WeaponData.gd - Data-driven weapon system as required by Linus
# "Good programmers worry about data structures" - Linus Torvalds
extends Resource
class_name WeaponData

@export var weapon_name: String = "Basic Weapon"
@export var damage: int = 25
@export var attack_speed: float = 1.0
@export var projectile_count: int = 1
@export var projectile_speed: float = 300.0
@export var range: float = 400.0
@export var penetration: int = 1
@export var area_of_effect: float = 0.0
@export var weapon_type: String = "projectile"  # "projectile", "aoe", "orbiting"
@export var unlock_level: int = 1
@export var weapon_scene: PackedScene
@export var description: String = "A basic weapon"

# Visual data
@export var weapon_color: Color = Color.WHITE
@export var weapon_size: Vector2 = Vector2(20, 10)
@export var spin_speed: float = 0.0

# Upgrade scaling
@export var damage_per_level: int = 5
@export var speed_scaling: float = 0.1