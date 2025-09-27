# WeaponData.gd - Data-driven weapon system as required by Linus
# "Good programmers worry about data structures" - Linus Torvalds
extends Resource
class_name WeaponData

@export var weapon_name: String = "Basic Weapon"
@export var damage: int = 25
@export var attack_speed: float = 1.0
@export var cooldown: float = 1.0  # Cooldown in seconds
@export var projectile_count: int = 1
@export var projectile_speed: float = 300.0
@export var speed: float = 300.0  # Alias for projectile_speed (compatibility)
@export var range: float = 400.0
@export var lifetime: float = 2.0  # How long projectiles live
@export var penetration: int = 1
@export var piercing: int = 1  # Alias for penetration (compatibility)
@export var area_of_effect: float = 0.0
@export var weapon_type: String = "projectile"  # "projectile", "aoe", "orbiting"
@export var unlock_level: int = 1
@export var weapon_scene: PackedScene
@export var description: String = "A basic weapon"

# Spread pattern for multi-projectile weapons
@export var spread_angle: float = 45.0  # Degrees

# Visual data
@export var weapon_color: Color = Color.WHITE
@export var weapon_size: Vector2 = Vector2(20, 10)
@export var spin_speed: float = 0.0

# Projectile visuals
@export var projectile_texture: Texture2D
@export var projectile_scale: Vector2 = Vector2.ONE
@export var projectile_modulate: Color = Color.WHITE

# Upgrade scaling
@export var damage_per_level: int = 5
@export var speed_scaling: float = 0.1

# Evolution system
@export var evolution_requirement: Resource  # Required upgrade for evolution
@export var evolution_result: WeaponData     # What this weapon evolves into

func get_actual_speed() -> float:
    return speed if speed > 0 else projectile_speed

func get_actual_piercing() -> int:
    return piercing if piercing > 0 else penetration