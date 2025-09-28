# HitboxComponent.gd - Stub class for missing HitboxComponent
class_name HitboxComponent
extends Area2D

@export var damage: int = 10
signal hit_target(target: Node2D)

func _ready():
    area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
    hit_target.emit(area)