# Minimal test to verify basic functionality
extends Node2D

@onready var player: CharacterBody2D = $Player

func _ready():
    print("=== MINIMAL GAME TEST STARTED ===")
    print("Player node: ", player)
    print("Autoloads check:")
    print("  - EventBus: ", "OK" if EventBus else "MISSING")
    print("  - Game: ", "OK" if Game else "MISSING") 
    print("  - ObjectPool: ", "OK" if ObjectPool else "MISSING")
    print("  - DataManager: ", "OK" if DataManager else "MISSING")
    
    # Test basic systems
    if EventBus:
        EventBus.player_health_changed.emit(100, 100)
        print("  - EventBus signal test: OK")
    
    if ObjectPool:
        print("  - ObjectPool stats: ", ObjectPool.get_pool_stats())
    
    print("=== Basic systems verified ===")
    print("Use WASD to move the green square")

func _process(delta):
    if player:
        var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
        player.velocity = input_dir * 300
        player.move_and_slide()
        
        if input_dir != Vector2.ZERO:
            print("Player moving: ", player.global_position)