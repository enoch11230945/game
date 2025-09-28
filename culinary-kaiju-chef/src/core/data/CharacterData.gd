# CharacterData.gd - Character configuration resource
extends Resource
class_name CharacterData

@export var character_name: String = "Chef"
@export var description: String = "A skilled culinary warrior"

# Base stats
@export var max_health: int = 100
@export var movement_speed: float = 300.0
@export var starting_weapon: String = "cleaver"

# Visual properties
@export var sprite_texture: Texture2D
@export var sprite_scale: Vector2 = Vector2.ONE
@export var sprite_modulate: Color = Color.WHITE

# Special abilities
@export var special_abilities: Array[String] = []
@export var passive_bonuses: Dictionary = {}

# Unlock conditions
@export var unlock_condition: String = ""
@export var is_unlocked: bool = true