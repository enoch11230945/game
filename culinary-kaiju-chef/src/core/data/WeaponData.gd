# WeaponData.gd
extends Resource

class_name WeaponData

@export var name: String = ""
@export var description: String = ""
@export var damage: int = 25
@export var speed: float = 300.0
@export var cooldown: float = 0.5
@export var range: float = 200.0
@export var projectile_scene: PackedScene

# 武器特殊效果
@export var special_effects: Array[String] = []
@export var piercing: bool = false
@export var homing: bool = false

func _init() -> void:
    resource_name = "WeaponData"
