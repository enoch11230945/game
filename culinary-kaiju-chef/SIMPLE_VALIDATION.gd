# SIMPLE_VALIDATION.gd - Basic system check
extends Node

func _ready() -> void:
    print("=== SIMPLE VALIDATION START ===")
    
    # Test autoloads
    var autoloads = ["EventBus", "Game", "ObjectPool", "PlayerData", "DataManager", "UpgradeManager", "AudioManager"]
    var loaded_count = 0
    
    for autoload_name in autoloads:
        var autoload = get_node_or_null("/root/" + autoload_name)
        if autoload:
            print("✅ %s: LOADED" % autoload_name)
            loaded_count += 1
        else:
            print("❌ %s: MISSING" % autoload_name)
    
    print("📊 Autoloads loaded: %d/%d" % [loaded_count, autoloads.size()])
    
    # Test basic class creation
    print("--- Testing Class Creation ---")
    
    var weapon_data = WeaponData.new()
    weapon_data.weapon_name = "Test Weapon"
    print("✅ WeaponData created: %s" % weapon_data.weapon_name)
    
    var enemy_data = EnemyData.new() 
    enemy_data.enemy_name = "Test Enemy"
    print("✅ EnemyData created: %s" % enemy_data.enemy_name)
    
    var upgrade_data = UpgradeData.new()
    upgrade_data.upgrade_name = "Test Upgrade"
    print("✅ UpgradeData created: %s" % upgrade_data.upgrade_name)
    
    # Test EventBus signals
    print("--- Testing EventBus ---")
    EventBus.game_started.emit()
    EventBus.xp_gained.emit(10)
    print("✅ EventBus signals emitted successfully")
    
    print("=== SIMPLE VALIDATION COMPLETE ===")
    
    await get_tree().create_timer(1.0).timeout
    get_tree().quit()