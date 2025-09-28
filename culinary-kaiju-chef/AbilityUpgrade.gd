# AbilityUpgrade.gd - Stub class for missing AbilityUpgrade
class_name AbilityUpgrade
extends Resource

@export var id: String = ""
@export var ability_name: String = ""
@export var level: int = 1
@export var description: String = ""

func apply_upgrade(target: Node):
    """Override in subclasses"""
    pass