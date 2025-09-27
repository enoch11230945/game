# BroccoliSplitterData.gd - 青花菜分裂者：死亡時分裂成小青花菜
extends Resource
class_name BroccoliSplitterData

@export var enemy_name: String = "Broccoli Splitter"
@export var health: int = 120
@export var speed: float = 75.0
@export var damage: int = 18
@export var xp_reward: int = 12

# 視覺屬性
@export var sprite_texture: Texture2D
@export var sprite_scale: Vector2 = Vector2(1.0, 1.0)
@export var sprite_modulate: Color = Color.GREEN

# 物理屬性
@export var separation_radius: float = 40.0
@export var separation_strength: float = 0.4

# 分裂特性
@export var split_count: int = 3  # 分裂成3個小青花菜
@export var split_health: int = 30  # 小青花菜的血量
@export var split_speed: float = 100.0  # 小青花菜的速度

# 不搖擺，不衝鋒
@export var wobble_amplitude: float = 0.0
@export var wobble_frequency: float = 0.0
@export var charge_interval: float = 0.0
@export var charge_duration: float = 0.0
@export var charge_multiplier: float = 1.0