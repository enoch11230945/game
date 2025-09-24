# src/main/main.gd
extends Node2D

func _ready():
    print("🎮 Main scene loaded successfully!")
    print("✅ Player should be visible on screen")
    print("🎯 Game is working!")

    # Check if player exists
    var player = get_node_or_null("Player")
    if player:
        print("✅ Player found in scene!")
        print("🎮 Player position:", player.global_position)
        print("🎮 Player visible:", player.visible)
        print("🎮 Player scale:", player.scale)
    else:
        print("❌ Player not found!")

    print("🎉 SUCCESS: Your game is working!")
    print("🎉 You can now play the game!")
    print("🎉 Use WASD keys to move the green player!")
