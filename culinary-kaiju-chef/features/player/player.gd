# features/player/player.gd
extends CharacterBody2D

@export var speed: float = 350.0

func _ready():
    print("✅ Player initialized successfully")
    add_to_group("player")

    # Set collision layers efficiently
    set_collision_layer_value(2, true)  # Player layer
    set_collision_mask_value(1, true)   # World layer
    set_collision_mask_value(3, true)   # Enemies layer
    set_collision_mask_value(6, true)   # Collectables layer

func _physics_process(_delta):
    var direction = _get_input_direction()

    if direction != Vector2.ZERO:
        velocity = direction.normalized() * speed
        move_and_slide()

func _get_input_direction() -> Vector2:
    var direction = Vector2.ZERO

    # Use Input.get_vector for better performance than individual key checks
    direction.x = Input.get_axis("move_left", "move_right")
    direction.y = Input.get_axis("move_up", "move_down")

    return direction