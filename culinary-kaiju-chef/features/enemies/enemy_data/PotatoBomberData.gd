# PotatoBomberData.gd - 土豆炸彈：中等速度，死亡時爆炸
extends Resource
class_name PotatoBomberData

@export var enemy_name: String = "Potato Bomber"
@export var health: int = 80
@export var speed: float = 90.0
@export var damage: int = 15
@export var xp_reward: int = 10

# 視覺屬性
@export var sprite_texture: Texture2D
@export var sprite_scale: Vector2 = Vector2(0.9, 0.9)
@export var sprite_modulate: Color = Color.BROWN

# 物理屬性
@export var separation_radius: float = 35.0
@export var separation_strength: float = 0.4

# 特殊能力：爆炸
@export var explosion_radius: float = 80.0
@export var explosion_damage: int = 30

# 不搖擺，不衝鋒
@export var wobble_amplitude: float = 0.0
@export var wobble_frequency: float = 0.0
@export var charge_interval: float = 0.0
@export var charge_duration: float = 0.0
@export var charge_multiplier: float = 1.0