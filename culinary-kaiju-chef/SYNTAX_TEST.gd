# SYNTAX_TEST.gd - Simple syntax validation
extends Node

func _ready() -> void:
    print("Basic syntax test started")
    
    # Test basic GDScript functionality
    var test_array: Array = []
    var test_dict: Dictionary = {}
    
    print("GDScript basics: OK")
    
    # Test if we can access autoloads without calling methods
    if EventBus:
        print("EventBus: ACCESSIBLE")
    else:
        print("EventBus: FAILED")
    
    if Game:
        print("Game: ACCESSIBLE") 
    else:
        print("Game: FAILED")
        
    if ObjectPool:
        print("ObjectPool: ACCESSIBLE")
    else:
        print("ObjectPool: FAILED")
        
    print("Syntax test complete")