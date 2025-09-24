# player.gd
extends CharacterBody2D
class_name Player

@export var speed: float = 300.0
@export var initial_state: PlayerState

var current_state: PlayerState

func _ready() -> void:
    # Set up the state machine by assigning the player reference to all child states.
    # Assumes all states are children of a node named "States".
    for child in get_node("States").get_children():
        if child is PlayerState:
            child.player = self

    if initial_state:
        switch_state(initial_state)

func _physics_process(delta: float) -> void:
    if current_state:
        current_state.physics_update(delta)

func switch_state(new_state: PlayerState) -> void:
    if current_state:
        current_state.exit()
    
    current_state = new_state
    
    if current_state:
        current_state.enter()