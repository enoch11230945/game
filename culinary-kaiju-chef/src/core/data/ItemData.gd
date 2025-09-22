# ItemData.gd
extends Resource

class_name ItemData

@export var name: String = ""
@export var description: String = ""
@export var type: String = "passive"  # passive, weapon_upgrade, character_upgrade
@export var rarity: String = "common"  # common, rare, epic, legendary

# 被動物品屬性
@export var stat_modifiers: Dictionary = {}

# 武器升級屬性
@export var weapon_modifiers: Dictionary = {}

# 角色升級屬性
@export var character_modifiers: Dictionary = {}

func _init() -> void:
    resource_name = "ItemData"
