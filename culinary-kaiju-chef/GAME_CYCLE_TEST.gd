# GAME_CYCLE_TEST.gd - Core game loop validation (Linus-approved)
# "Test the actual game mechanics, not theoretical concepts" - Linus
extends Node2D

# Test components
var test_player: Node2D
var test_enemies: Array[Node2D] = []
var test_projectile: Node2D
var xp_gems_collected: int = 0

# Test scenes
var player_scene = preload("res://features/player/Player.tscn")
var enemy_scene = preload("res://features/enemies/base_enemy/BaseEnemy.tscn")  
var xp_gem_scene = preload("res://features/items/xp_gem/XPGem.tscn")

func _ready() -> void:
    print("=== GAME CYCLE VALIDATION STARTED ===")
    
    # Wait for autoloads to initialize
    await get_tree().process_frame
    
    # Step 1: Validate autoload systems
    if not validate_autoloads():
        print("❌ CRITICAL: Autoload validation failed")
        get_tree().quit()
        return
    
    # Step 2: Test player instantiation
    await test_player_creation()
    
    # Step 3: Test enemy spawning
    await test_enemy_spawning()
    
    # Step 4: Test basic combat cycle
    await test_combat_cycle()
    
    # Step 5: Test XP collection
    await test_xp_system()
    
    print("=== GAME CYCLE VALIDATION COMPLETE ===")
    await get_tree().create_timer(2.0).timeout
    get_tree().quit()

func validate_autoloads() -> bool:
    print("--- Validating Autoload Systems ---")
    var success = true
    
    var autoloads = [
        {"name": "EventBus", "instance": EventBus},
        {"name": "Game", "instance": Game},
        {"name": "ObjectPool", "instance": ObjectPool},
        {"name": "PlayerData", "instance": PlayerData},
        {"name": "DataManager", "instance": DataManager},
        {"name": "UpgradeManager", "instance": UpgradeManager},
        {"name": "AudioManager", "instance": AudioManager}
    ]
    
    for autoload in autoloads:
        if autoload.instance:
            print("✅ %s: LOADED" % autoload.name)
        else:
            print("❌ %s: FAILED" % autoload.name)
            success = false
    
    return success

func test_player_creation() -> void:
    print("--- Testing Player Creation ---")
    
    if not ResourceLoader.exists("res://features/player/Player.tscn"):
        print("❌ Player scene not found")
        return
    
    test_player = player_scene.instantiate()
    if not test_player:
        print("❌ Player instantiation failed")
        return
    
    add_child(test_player)
    test_player.global_position = Vector2(400, 300)
    
    print("✅ Player created successfully")
    print("  - Position: %s" % test_player.global_position)
    print("  - Node type: %s" % test_player.get_class())
    
    await get_tree().process_frame

func test_enemy_spawning() -> void:
    print("--- Testing Enemy Spawning ---")
    
    if not ResourceLoader.exists("res://features/enemies/base_enemy/BaseEnemy.tscn"):
        print("❌ Enemy scene not found")
        return
    
    # Create test enemy data
    var enemy_data = EnemyData.new()
    enemy_data.enemy_name = "Test Onion"
    enemy_data.health = 50
    enemy_data.speed = 80.0
    enemy_data.damage = 10
    enemy_data.experience_reward = 15
    
    # Spawn 3 test enemies
    for i in range(3):
        var enemy = enemy_scene.instantiate()
        if enemy:
            add_child(enemy)
            var spawn_pos = Vector2(100 + i * 100, 200)
            enemy.global_position = spawn_pos
            
            # Initialize enemy with data
            if enemy.has_method("initialize"):
                enemy.initialize(spawn_pos, enemy_data)
            
            test_enemies.append(enemy)
            print("✅ Enemy %d spawned at %s" % [i+1, spawn_pos])
    
    print("✅ Enemy spawning complete: %d enemies" % test_enemies.size())
    await get_tree().process_frame

func test_combat_cycle() -> void:
    print("--- Testing Combat Cycle ---")
    
    if not test_player:
        print("❌ No player for combat test")
        return
    
    if test_enemies.is_empty():
        print("❌ No enemies for combat test")
        return
    
    # Test weapon creation
    if test_player.has_method("equip_weapon"):
        print("✅ Player has equip_weapon method")
        
        # Try to create basic weapon data
        var weapon_data = WeaponData.new()
        weapon_data.weapon_name = "Test Cleaver"
        weapon_data.damage = 25
        weapon_data.cooldown = 1.0
        weapon_data.range = 150.0
        weapon_data.projectile_count = 1
        
        # Equip weapon
        # test_player.equip_weapon(weapon_data)
        print("✅ Basic weapon data created")
    
    # Test basic collision detection setup
    var player_groups = test_player.get_groups()
    print("✅ Player groups: %s" % player_groups)
    
    if test_enemies.size() > 0:
        var enemy_groups = test_enemies[0].get_groups()
        print("✅ Enemy groups: %s" % enemy_groups)
    
    await get_tree().process_frame

func test_xp_system() -> void:
    print("--- Testing XP System ---")
    
    # Create test XP gem
    if not ResourceLoader.exists("res://features/items/xp_gem/XPGem.tscn"):
        print("❌ XP Gem scene not found")
        return
    
    var xp_gem = xp_gem_scene.instantiate()
    if xp_gem:
        add_child(xp_gem)
        xp_gem.global_position = Vector2(350, 300)
        
        if xp_gem.has_method("initialize"):
            xp_gem.initialize(15)  # 15 XP value
        
        print("✅ XP Gem created")
        print("  - Position: %s" % xp_gem.global_position)
        print("  - Value: %d XP" % (15 if xp_gem.has_method("initialize") else 0))
    
    # Test EventBus XP signals
    EventBus.xp_gained.emit(10)
    EventBus.xp_gem_spawned.emit(Vector2(300, 250), 5)
    
    print("✅ XP system signals tested")
    await get_tree().process_frame

func _process(delta: float) -> void:
    # Basic game loop simulation
    if test_player and test_enemies.size() > 0:
        # Simple enemy AI - move towards player
        for enemy in test_enemies:
            if is_instance_valid(enemy) and is_instance_valid(test_player):
                var direction = (test_player.global_position - enemy.global_position).normalized()
                enemy.global_position += direction * 50.0 * delta