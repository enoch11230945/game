# Camera follow script for Godot 4.5
extends Camera2D

@export var target_path: NodePath = ""
@export var follow_speed: float = 5.0
@export var deadzone: Vector2 = Vector2(50, 50)

var target: Node2D = null
var follow_enabled: bool = true

func _ready():
    if not target_path.is_empty():
        target = get_node(target_path)
    else:
        # Try to find player automatically
        target = get_tree().get_first_node_in_group("player")

    if target:
        print("📷 Camera found target:", target.name)
    else:
        print("⚠️ Camera: No target found!")

func _process(delta):
    if not target or not follow_enabled:
        return

    # Calculate desired position
    var desired_position = target.global_position

    # Apply deadzone
    var camera_position = global_position
    var offset = desired_position - camera_position

    if abs(offset.x) > deadzone.x:
        camera_position.x = lerp(camera_position.x, desired_position.x, follow_speed * delta)

    if abs(offset.y) > deadzone.y:
        camera_position.y = lerp(camera_position.y, desired_position.y, follow_speed * delta)

    # Update camera position
    global_position = camera_position

func set_target(new_target: Node2D):
    """Set the target for the camera to follow"""
    target = new_target
    if target:
        print("📷 Camera target set to:", target.name)

func enable_follow():
    """Enable camera following"""
    follow_enabled = true

func disable_follow():
    """Disable camera following"""
    follow_enabled = false
