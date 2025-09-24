# move_state.gd
# The state for handling player movement.
extends PlayerState
class_name MoveState

func physics_update(delta: float) -> void:
    if not player:
        return

    # Get the input direction and handle the movement/deceleration.
    var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    player.velocity = input_direction * player.speed
    player.move_and_slide()
