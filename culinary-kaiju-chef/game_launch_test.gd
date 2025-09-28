# Launch the actual game to test everything
extends SceneTree

func _init():
    print("=== Launching Culinary Kaiju Chef ===")
    print("Loading main scene...")
    change_scene_to_file("res://src/main/main.tscn")
    
    # Allow 10 seconds for gameplay test
    create_timer(10.0).timeout.connect(_test_complete)

func _test_complete():
    print("=== Game Test Complete ===")
    quit()