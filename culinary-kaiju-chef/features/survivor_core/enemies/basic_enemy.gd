extends CharacterBody2D

@onready var visuals := $Visuals
# Replaced VelocityComponent with simple movement
var movement_speed: float = 80.0
var target_velocity: Vector2 = Vector2.ZERO


func _ready():
	$HurtboxComponent.hit.connect(on_hit)


func _process(delta):
    # Replace VelocityComponent with simple movement
    var player = get_tree().get_first_node_in_group("player")
    if player:
        var direction = (player.global_position - global_position).normalized()
        target_velocity = direction * movement_speed
        velocity = target_velocity
        move_and_slide()
    
    var move_sign = sign(velocity.x)
    if move_sign != 0:
        visuals.scale = Vector2(-move_sign, 1)


func on_hit():
	$HitRandomAudioPlayerComponent.play_random()
