# Ability.gd - Stub class for missing Ability
class_name Ability
extends Node

@export var ability_data: Resource
@export var ability_controller_scene: PackedScene

func initialize(data: Resource):
    ability_data = data