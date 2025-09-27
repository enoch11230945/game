# Quick architecture test
extends Node

func _ready():
    print("=== Culinary Kaiju Chef Architecture Test ===")
    
    # Test 1: Check autoloads
    print("1. Testing Autoloads:")
    print("   - EventBus: ", "✓" if EventBus else "✗")
    print("   - Game: ", "✓" if Game else "✗") 
    print("   - ObjectPool: ", "✓" if ObjectPool else "✗")
    print("   - DataManager: ", "✓" if DataManager else "✗")
    
    # Test 2: Check DataManager
    print("2. Testing DataManager:")
    var throwing_knife = DataManager.get_weapon("Throwing Knife")
    var fan_knife = DataManager.get_weapon("Fan Knife")
    var onion_grunt = DataManager.get_enemy("Onion Grunt")
    print("   - Throwing Knife: ", "✓" if throwing_knife else "✗")
    print("   - Fan Knife: ", "✓" if fan_knife else "✗")
    print("   - Onion Grunt: ", "✓" if onion_grunt else "✗")
    
    # Test 3: Check object pool
    print("3. Testing ObjectPool:")
    var enemy_scene = preload("res://features/enemies/base_enemy/BaseEnemy.tscn")
    var projectile_scene = preload("res://features/weapons/base_weapon/BaseProjectile.tscn")
    var xp_gem_scene = preload("res://features/items/xp_gem/XPGem.tscn")
    
    ObjectPool.pre_populate(enemy_scene, 5)
    ObjectPool.pre_populate(projectile_scene, 10)
    ObjectPool.pre_populate(xp_gem_scene, 3)
    
    var enemy_instance = ObjectPool.request(enemy_scene)
    print("   - Enemy spawning: ", "✓" if enemy_instance else "✗")
    if enemy_instance:
        ObjectPool.reclaim(enemy_instance)
        print("   - Enemy reclaim: ✓")
    
    # Test 4: Check EventBus signals
    print("4. Testing EventBus:")
    EventBus.player_health_changed.emit(100, 100)
    EventBus.enemy_spawned.emit(null)
    print("   - EventBus signals: ✓")
    
    print("=== Architecture Test Complete ===")
    get_tree().quit()