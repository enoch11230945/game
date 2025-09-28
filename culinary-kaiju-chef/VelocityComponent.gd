# VelocityComponent.gd - Stub class for missing VelocityComponent
class_name VelocityComponent
extends Node

@export var max_speed: float = 100.0
var velocity: Vector2 = Vector2.ZERO

func accelerate_to_player():
    var player = get_tree().get_first_node_in_group("player")
    if player:
        var direction = (player.global_position - get_parent().global_position).normalized()
        velocity = direction * max_speed

func move(character_body: CharacterBody2D):
    character_body.velocity = velocity
    character_body.move_and_slide()