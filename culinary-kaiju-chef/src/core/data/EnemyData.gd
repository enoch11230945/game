# EnemyData.gd
extends Resource

class_name EnemyData

@export var name: String = ""
@export var description: String = ""
@export var health: int = 50
@export var speed: float = 100.0
@export var damage: int = 10
@export var xp_value: int = 10
@export var scene: PackedScene

# 敵人行為參數
@export var detection_range: float = 300.0
@export var attack_range: float = 50.0
@export var separation_strength: float = 0.5

func _init() -> void:
    resource_name = "EnemyData"
