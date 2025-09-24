# player_state.gd
# Base class for all player states in the FSM.
class_name PlayerState
extends Node

# A reference to the player node.
var player: Player

# Virtual function to run when the state is entered.
func enter() -> void:
    pass

# Virtual function to run when the state is exited.
func exit() -> void:
    pass

# Virtual function for physics-based processing.
func physics_update(delta: float) -> void:
    pass
