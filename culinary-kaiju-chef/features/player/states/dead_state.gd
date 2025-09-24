# dead_state.gd
extends PlayerState
class_name DeadState

func enter() -> void:
    if not player:
        return
    
    # For now, just hide the player and disable physics.
    # Later, this will trigger a death animation and the game over screen.
    player.hide()
    player.set_physics_process(false)
    
    # In a real scenario, we would emit a global event
    # EventBus.emit("player_died")

func exit() -> void:
    # This state should typically not be exited, but for completeness...
    player.show()
    player.set_physics_process(true)
