# CarrotTankData.gd
extends Resource
class_name CarrotTankData

@export var enemy_name: String = "Carrot Tank"
@export var health: int = 150  # 高血量
@export var speed: float = 60.0  # 慢速
@export var damage: int = 25  # 高傷害
@export var xp_reward: int = 15  # 高經驗獎勵

# 視覺屬性
@export var sprite_texture: Texture2D
@export var sprite_scale: Vector2 = Vector2(1.2, 1.2)  # 更大的體型
@export var sprite_modulate: Color = Color.ORANGE

# 物理屬性
@export var separation_radius: float = 45.0
@export var separation_strength: float = 0.3

# 特殊行為 - 胡蘿蔔坦克有衝鋒能力
@export var charge_interval: float = 3.0  # 每3秒衝鋒一次
@export var charge_duration: float = 0.5  # 衝鋒持續0.5秒
@export var charge_multiplier: float = 2.5  # 衝鋒速度倍率

# 不搖擺
@export var wobble_amplitude: float = 0.0
@export var wobble_frequency: float = 0.0