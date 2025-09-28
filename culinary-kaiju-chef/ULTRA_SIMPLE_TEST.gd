# ULTRA_SIMPLE_TEST.gd - Minimal validation
extends Node

func _ready() -> void:
    print("ULTRA SIMPLE TEST")
    print("Game loading...")
    await get_tree().process_frame
    print("Test complete")
    get_tree().quit()