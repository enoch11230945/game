# CLEAN_MAIN.gd - Linus-approved clean main scene
extends Node2D

# === DATA RESOURCES (No hardcoding!) ===
@export var cleaver_data: WeaponData = preload("res://src/core/data/cleaver_weapon.tres")
@export var onion_data: EnemyData = preload("res://src/core/data/onion_enemy.tres")

# === CORE NODES ===
var player: CharacterBody2D
var enemy_spawner: Node
var ui_manager: Control

func _ready():
    print("🎯 LINUS-APPROVED CLEAN MAIN SCENE")
    
    # Setup game
    RenderingServer.set_default_clear_color(Color(0.1, 0.1, 0.15))
    EventBus.game_started.emit()
    
    # Create player using proper scene
    create_player()
    setup_enemy_spawning()
    setup_game_systems()
    
    print("✅ Clean game ready!")

func setup_game_systems():
    """Setup all game systems"""
    # Add VFX Manager
    var vfx_manager = preload("res://src/vfx/VFXManager.gd").new()
    vfx_manager.name = "VFXManager"
    add_child(vfx_manager)
    
    # Add Platform Manager
    var platform_manager = preload("res://src/platform/PlatformManager.gd").new()
    platform_manager.name = "PlatformManager"
    add_child(platform_manager)
    
    # Add Game HUD
    var hud_scene = preload("res://src/ui/hud/GameHUD.tscn")
    var hud = hud_scene.instantiate()
    add_child(hud)
    
    print("✅ Game systems initialized")

func create_player():
    """Create player using proper Player scene"""
    var player_scene = preload("res://features/player/Player.tscn")
    player = player_scene.instantiate()
    player.global_position = Vector2(400, 300)  # Center screen
    add_child(player)
    
    # Setup upgrade screen
    setup_upgrade_ui()
    
    print("✅ Player created from scene")

func setup_upgrade_ui():
    """Setup upgrade selection screen"""
    var upgrade_screen_scene = preload("res://src/ui/upgrade_selection/UpgradeSelectionScreen.tscn")
    if upgrade_screen_scene:
        var upgrade_screen = upgrade_screen_scene.instantiate()
        add_child(upgrade_screen)
        print("✅ Upgrade screen ready")
    else:
        print("⚠️ Upgrade screen scene not found")

func setup_enemy_spawning():
    """Setup enemy spawner"""
    var spawner_script = preload("res://src/core/EnemySpawner.gd")
    enemy_spawner = spawner_script.new()
    enemy_spawner.name = "EnemySpawner"
    add_child(enemy_spawner)
    
    # Connect events
    if enemy_spawner.has_method("setup_event_connections"):
        enemy_spawner.setup_event_connections()
    
    print("✅ Enemy spawner ready")

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        SceneLoader.load_scene("res://src/ui/screens/main_menu/simple_main_menu.tscn")