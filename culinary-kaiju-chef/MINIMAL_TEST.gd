# MINIMAL_TEST.gd - Basic system validation
extends Node2D

func _ready() -> void:
    print("=== MINIMAL TEST STARTED ===")
    print("Testing autoload systems...")
    
    # Test EventBus
    if EventBus:
        print("✅ EventBus loaded")
        EventBus.game_started.emit()
    else:
        print("❌ EventBus failed")
    
    # Test ObjectPool
    if ObjectPool:
        print("✅ ObjectPool loaded")
    else:
        print("❌ ObjectPool failed")
    
    # Test AudioManager
    if AudioManager:
        print("✅ AudioManager loaded")
        # Skip function call to avoid compilation issues
    else:
        print("❌ AudioManager failed")
    
    # Test Game
    if Game:
        print("✅ Game loaded")
    else:
        print("❌ Game failed")
    
    # Test PlayerData
    if PlayerData:
        print("✅ PlayerData loaded")
    else:
        print("❌ PlayerData failed")
        
    # Test DataManager
    if DataManager:
        print("✅ DataManager loaded")
    else:
        print("❌ DataManager failed")
        
    # Test UpgradeManager  
    if UpgradeManager:
        print("✅ UpgradeManager loaded")
    else:
        print("❌ UpgradeManager failed")
    
    print("=== MINIMAL TEST COMPLETE ===")

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):  # SPACE key
        print("SPACE pressed - Testing basic functionality")
        EventBus.play_sound.emit("test_sound")
        EventBus.xp_gained.emit(10)