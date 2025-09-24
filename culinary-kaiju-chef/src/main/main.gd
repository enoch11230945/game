# main.gd
extends Node

# You must assign the Player scene to this variable in the Godot editor.
@export var player_scene: PackedScene

func _ready() -> void:
    # Check if a player scene has been assigned.
    if not player_scene:
        print("ERROR: Player scene not set in main.gd")
        return

    # Instantiate the player and add it to the scene.
    var player_instance = player_scene.instantiate()
    player_instance.name = "Player"
    add_child(player_instance)
    
    # Add the player to the "player" group so enemies can find it.
    # This is a crucial step for the enemy AI.
    player_instance.add_to_group("player")