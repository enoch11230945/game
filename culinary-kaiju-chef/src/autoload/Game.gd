# Game.gd
# Manages the overall game state for a single run.
extends Node

var score: int = 0
var level: int = 1
var current_xp: int = 0
var required_xp: int = 10

func gain_experience(amount: int) -> void:
    current_xp += amount
    if current_xp >= required_xp:
        level_up()

func level_up() -> void:
    current_xp -= required_xp
    level += 1
    required_xp = int(required_xp * 1.5) # Simple scaling
    
    # Pause the game and notify other systems that a level up occurred.
    get_tree().paused = true
    EventBus.emit("player_leveled_up")
