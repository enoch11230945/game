# GarlicSwarmerData.gd - 蒜頭蜂群：快速、低血量、群體出現
extends Resource
class_name GarlicSwarmerData

@export var enemy_name: String = "Garlic Swarmer"
@export var health: int = 15  # 很低血量
@export var speed: float = 140.0  # 很快速度
@export var damage: int = 8  # 低傷害
@export var xp_reward: int = 3  # 少經驗

# 視覺屬性
@export var sprite_texture: Texture2D
@export var sprite_scale: Vector2 = Vector2(0.6, 0.6)  # 小體型
@export var sprite_modulate: Color = Color.WHITE

# 物理屬性 - 緊密聚集
@export var separation_radius: float = 20.0
@export var separation_strength: float = 0.1  # 低分離力，形成群體

# 蜂群特性：搖擺移動
@export var wobble_amplitude: float = 30.0
@export var wobble_frequency: float = 4.0

# 不衝鋒
@export var charge_interval: float = 0.0
@export var charge_duration: float = 0.0
@export var charge_multiplier: float = 1.0