# CharacterData.gd
extends Resource

class_name CharacterData

@export var name: String = ""
@export var description: String = ""
@export var health: int = 100
@export var speed: float = 200.0
@export var sprite_path: String = ""

# 角色特殊能力
@export var special_abilities: Array[String] = []

func _init() -> void:
    resource_name = "CharacterData"
