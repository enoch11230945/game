# WeaponData.gd
extends Resource
class_name WeaponData

@export var name: String = "Weapon"
@export var damage: int = 10
@export var cooldown: float = 1.0
@export var speed: float = 200.0
@export var weapon_range: float = 400.0  # Renamed from 'range' to avoid built-in conflict
@export var area_size: float = 1.0
@export var projectile_count: int = 1
@export var scene: PackedScene

# Visual properties
@export var projectile_texture: Texture2D
@export var projectile_scale: Vector2 = Vector2.ONE
@export var projectile_modulate: Color = Color.WHITE

# Weapon Evolution System (Epic 1.1 requirement)
@export var max_level: int = 8
@export var evolution_requirement: Resource  # UpgradeData required for evolution
@export var evolution_result: WeaponData     # What this weapon evolves into
@export var is_evolved: bool = false         # Is this an evolved weapon?

# Level-based scaling
@export var damage_per_level: int = 2
@export var cooldown_reduction_per_level: float = 0.05

# Advanced properties
@export var piercing: int = 0 # How many enemies it can pierce through
@export var lifetime: float = 3.0 # How long projectiles live
@export var spread_angle: float = 0.0 # Spread in degrees for multiple projectiles