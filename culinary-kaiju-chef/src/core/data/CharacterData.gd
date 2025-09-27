# CharacterData.gd
extends Resource
class_name CharacterData

@export var name: String = "Chef"
@export var description: String = "A skilled chef ready to battle"
@export var max_health: int = 100
@export var movement_speed: float = 300.0
@export var starting_weapon: WeaponData

# Character visual properties
@export var sprite_texture: Texture2D
@export var sprite_scale: Vector2 = Vector2.ONE
@export var sprite_modulate: Color = Color.WHITE

# Special abilities or modifiers
@export var damage_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0
@export var cooldown_multiplier: float = 1.0
@export var xp_multiplier: float = 1.0