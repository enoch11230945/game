# PROPER_main.gd - Linus-approved MINIMAL main scene
# "Good code does ONE thing and does it well" - Linus
extends Node2D

# === SINGLE RESPONSIBILITY: Scene Loading Only ===
func _ready():
    print("🎯 Main scene started - Loading game systems...")
    
    # ONLY job: Load the player scene
    _load_player()
    
    # ONLY job: Signal that main scene is ready
    EventBus.main_scene_ready.emit()
    
    print("✅ Main scene ready - Systems take over from here")

func _load_player():
    """ONLY loads player scene - does NOT manage it"""
    var player_scene = preload("res://features/player/Player.tscn")
    var player = player_scene.instantiate()
    player.global_position = Vector2(400, 300)
    add_child(player)
    
    # That's it. Player manages itself from here.

func _input(event):
    """ONLY handles scene switching"""
    if event.is_action_pressed("ui_cancel"):
        SceneLoader.load_scene("res://src/ui/screens/main_menu/simple_main_menu.tscn")