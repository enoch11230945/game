# EnemyData.gd
extends Resource
class_name EnemyData

@export var name: String = "Enemy"
@export var health: int = 10
@export var speed: float = 50.0
@export var damage: int = 1
@export var xp_reward: int = 5
@export var scene: PackedScene
@export var sprite_texture: Texture2D

# Visual properties
@export var sprite_scale: Vector2 = Vector2.ONE
@export var sprite_modulate: Color = Color.WHITE

# Behavior properties
@export var separation_strength: float = 0.5
@export var separation_radius: float = 40.0
@export var wobble_amplitude: float = 0.0 # Speed Demon 偏移幅度
@export var wobble_frequency: float = 0.0 # 偏移頻率
@export var charge_interval: float = 0.0 # Tank charge 間隔
@export var charge_multiplier: float = 1.0 # charge 速度倍數
@export var charge_duration: float = 0.0 # charge 維持時間