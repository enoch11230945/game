# AUTOLOAD_VALIDATION.gd - System validation (Linus-approved testing)
extends Node

func _ready() -> void:
    print("=== AUTOLOAD SYSTEM VALIDATION ===")
    
    # Test each autoload system individually
    test_eventbus()
    test_game()
    test_objectpool()
    test_playerdata()
    test_datamanager()
    test_upgrademanager()
    test_audiomanager()
    
    print("=== VALIDATION COMPLETE ===")
    
    # Test basic game cycle
    await get_tree().process_frame
    test_basic_game_cycle()
    
    await get_tree().create_timer(2.0).timeout
    get_tree().quit()

func test_eventbus() -> void:
    print("Testing EventBus...")
    if EventBus:
        print("✅ EventBus loaded successfully")
        # Test signal emission (should not crash)
        EventBus.game_started.emit()
        EventBus.xp_gained.emit(10)
        print("✅ EventBus signals working")
    else:
        print("❌ EventBus failed to load")

func test_game() -> void:
    print("Testing Game...")
    if Game:
        print("✅ Game loaded successfully")
        print("  - Current level: %d" % Game.current_level)
        print("  - Game time: %.2f" % Game.game_time)
    else:
        print("❌ Game failed to load")

func test_objectpool() -> void:
    print("Testing ObjectPool...")
    if ObjectPool:
        print("✅ ObjectPool loaded successfully")
        print("  - Pool count: %d" % ObjectPool.pools.size())
    else:
        print("❌ ObjectPool failed to load")

func test_playerdata() -> void:
    print("Testing PlayerData...")
    if PlayerData:
        print("✅ PlayerData loaded successfully")
        print("  - Total gold: %d" % PlayerData.total_gold)
    else:
        print("❌ PlayerData failed to load")

func test_datamanager() -> void:
    print("Testing DataManager...")
    if DataManager:
        print("✅ DataManager loaded successfully")
        print("  - Weapon cache: %d" % DataManager.weapon_data_cache.size())
        print("  - Enemy cache: %d" % DataManager.enemy_data_cache.size())
    else:
        print("❌ DataManager failed to load")

func test_upgrademanager() -> void:
    print("Testing UpgradeManager...")
    if UpgradeManager:
        print("✅ UpgradeManager loaded successfully")
        print("  - All upgrades: %d" % UpgradeManager.all_upgrades.size())
        print("  - All weapons: %d" % UpgradeManager.all_weapons.size())
    else:
        print("❌ UpgradeManager failed to load")

func test_audiomanager() -> void:
    print("Testing AudioManager...")
    if AudioManager:
        print("✅ AudioManager loaded successfully")
        print("  - Music library: %d" % AudioManager.music_library.size())
        print("  - SFX library: %d" % AudioManager.sfx_library.size())
    else:
        print("❌ AudioManager failed to load")

func test_basic_game_cycle() -> void:
    print("=== BASIC GAME CYCLE TEST ===")
    
    # Test data-driven systems
    print("Testing data resources...")
    
    # Try to load a weapon data
    var weapon_path = "res://src/core/data/cleaver_weapon.tres"
    if ResourceLoader.exists(weapon_path):
        var weapon_data = load(weapon_path)
        if weapon_data:
            print("✅ WeaponData loading: SUCCESS")
            print("  - Weapon name: %s" % weapon_data.weapon_name)
        else:
            print("❌ WeaponData loading: FAILED")
    else:
        print("⚠️ WeaponData file not found: %s" % weapon_path)
    
    # Try to load an enemy data  
    var enemy_path = "res://src/core/data/onion_enemy.tres"
    if ResourceLoader.exists(enemy_path):
        var enemy_data = load(enemy_path)
        if enemy_data:
            print("✅ EnemyData loading: SUCCESS")
            print("  - Enemy name: %s" % enemy_data.enemy_name)
            print("  - Health: %d" % enemy_data.health)
        else:
            print("❌ EnemyData loading: FAILED")
    else:
        print("⚠️ EnemyData file not found: %s" % enemy_path)
    
    # Test scene loading
    var player_path = "res://features/player/Player.tscn"
    if ResourceLoader.exists(player_path):
        print("✅ Player scene exists")
    else:
        print("❌ Player scene missing")
    
    var enemy_path2 = "res://features/enemies/base_enemy/BaseEnemy.tscn"
    if ResourceLoader.exists(enemy_path2):
        print("✅ BaseEnemy scene exists")
    else:
        print("❌ BaseEnemy scene missing")
    
    print("=== GAME CYCLE TEST COMPLETE ===")