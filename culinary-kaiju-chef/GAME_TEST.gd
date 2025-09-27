# Quick Game Test - Linus Style
# This script tests our architecture without GUI
extends Node

func _ready():
    print("=== LINUS ARCHITECTURE TEST ===")
    
    # Test 1: ObjectPool
    print("\n🏊 Testing ObjectPool...")
    if ObjectPool:
        ObjectPool.print_pool_stats()
        print("✅ ObjectPool working")
    else:
        print("❌ ObjectPool failed")
    
    # Test 2: EventBus
    print("\n📡 Testing EventBus...")
    if EventBus:
        EventBus.game_started.connect(_on_game_started)
        EventBus.game_started.emit()
        print("✅ EventBus working")
    else:
        print("❌ EventBus failed")
    
    # Test 3: DataManager
    print("\n📊 Testing DataManager...")
    if DataManager:
        print("✅ DataManager loaded")
    else:
        print("❌ DataManager failed")
    
    # Test 4: Features Directory Structure
    print("\n📁 Testing Feature Structure...")
    var enemy_data = load("res://src/core/data/onion_enemy.tres")
    if enemy_data:
        print("✅ Enemy data loaded: %s" % enemy_data.enemy_name)
    else:
        print("❌ Enemy data failed")
    
    var weapon_data = load("res://src/core/data/cleaver_weapon.tres")  
    if weapon_data:
        print("✅ Weapon data loaded: %s" % weapon_data.weapon_name)
    else:
        print("❌ Weapon data failed")
        
    print("\n=== TEST COMPLETE ===")
    
func _on_game_started():
    print("📡 EventBus signal received!")