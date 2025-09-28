# EPIC2_TEST.gd - Epic 2.1 永久升级系统测试
extends Node2D

func _ready() -> void:
    print("=== EPIC 2.1 TEST: 永久升级系统 ===")
    
    # 测试元升级界面
    await get_tree().create_timer(1.0).timeout
    test_meta_upgrade_screen()

func test_meta_upgrade_screen() -> void:
    """测试元升级界面"""
    print("🧪 Testing Meta Upgrade Screen...")
    
    # 给玩家一些测试金币
    PlayerData.total_gold = 500
    
    # 加载元升级界面
    var meta_screen_scene = preload("res://src/ui/screens/meta_upgrade_screen/MetaUpgradeScreen.tscn")
    var meta_screen = meta_screen_scene.instantiate()
    
    if meta_screen:
        add_child(meta_screen)
        print("✅ Meta upgrade screen loaded")
        print("💰 Player has %d gold for testing" % PlayerData.total_gold)
        print("🖱️ Click upgrade buttons to test purchasing")
    else:
        print("❌ Failed to load meta upgrade screen")

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):  # SPACE
        print("=== META PROGRESSION STATUS ===")
        print("Gold: %d" % PlayerData.total_gold)
        print("Games played: %d" % PlayerData.games_played)
        print("Meta upgrades: %s" % PlayerData.meta_upgrades)
        
        # 测试添加金币
        PlayerData.total_gold += 100
        print("Added 100 test gold (Total: %d)" % PlayerData.total_gold)
    
    elif event.is_action_pressed("ui_cancel"):  # ESC
        print("👋 Epic 2.1 test complete!")
        get_tree().quit()