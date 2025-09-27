# ChiliSpeedsterData.gd - 辣椒極速：超快速度，會閃避
extends Resource
class_name ChiliSpeedsterData

@export var enemy_name: String = "Chili Speedster"
@export var health: int = 40
@export var speed: float = 180.0  # 極快
@export var damage: int = 12
@export var xp_reward: int = 8

# 視覺屬性
@export var sprite_texture: Texture2D
@export var sprite_scale: Vector2 = Vector2(0.7, 0.7)
@export var sprite_modulate: Color = Color.RED

# 物理屬性
@export var separation_radius: float = 30.0
@export var separation_strength: float = 0.6

# 特殊移動：高頻搖擺（模擬閃避）
@export var wobble_amplitude: float = 50.0
@export var wobble_frequency: float = 8.0

# 快速衝刺能力
@export var charge_interval: float = 2.0
@export var charge_duration: float = 0.3
@export var charge_multiplier: float = 2.0