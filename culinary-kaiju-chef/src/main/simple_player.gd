# Simple player script for testing
extends CharacterBody2D

@export var speed: float = 350.0

func _ready():
    print("🎮 Player ready!")

func _physics_process(_delta):
    var direction = _get_input_direction()

    if direction != Vector2.ZERO:
        velocity = direction.normalized() * speed
        move_and_slide()
    else:
        velocity = Vector2.ZERO

func _get_input_direction() -> Vector2:
    var direction = Vector2.ZERO

    # Use Input.get_vector for better performance
    direction.x = Input.get_axis("move_left", "move_right")
    direction.y = Input.get_axis("move_up", "move_down")

    return direction
