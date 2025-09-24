# Ultra simple player script using Node2D
extends Node2D

@export var speed: float = 350.0

var player_square: ColorRect

func _ready():
    print("🎮 Simple player ready!")
    add_to_group("player")  # Add to player group so camera can find us
    # Create a green square
    player_square = ColorRect.new()
    player_square.color = Color(0, 1, 0, 1)  # Green
    player_square.size = Vector2(64, 64)
    player_square.position = Vector2(-32, -32)  # Center the square
    add_child(player_square)

func _process(delta):
    var direction = _get_input_direction()

    if direction != Vector2.ZERO:
        position += direction.normalized() * speed * delta
        # Keep player within screen bounds
        position.x = clamp(position.x, 32, 1248)
        position.y = clamp(position.y, 32, 688)

func _get_input_direction() -> Vector2:
    var direction = Vector2.ZERO

    # Use Input.get_vector for better performance
    direction.x = Input.get_axis("move_left", "move_right")
    direction.y = Input.get_axis("move_up", "move_down")

    return direction
