# WeaponData.gd
extends Resource
class_name WeaponData

@export var name: String = "Weapon"
@export var damage: int = 10
@export var cooldown: float = 1.0
@export var speed: float = 200.0
@export var range: float = 400.0
@export var area_size: float = 1.0
@export var projectile_count: int = 1
@export var scene: PackedScene

# Visual properties
@export var projectile_texture: Texture2D
@export var projectile_scale: Vector2 = Vector2.ONE
@export var projectile_modulate: Color = Color.WHITE

# Advanced properties
@export var piercing: int = 0 # How many enemies it can pierce through
@export var lifetime: float = 3.0 # How long projectiles live
@export var spread_angle: float = 0.0 # Spread in degrees for multiple projectiles