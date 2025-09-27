# SystemManager.gd - SINGLE RESPONSIBILITY: System Initialization Only
extends Node

func _ready() -> void:
    print("🔧 SystemManager initialized - System coordination only")
    
    # Connect to main scene ready
    EventBus.main_scene_ready.connect(_on_main_scene_ready)

func _on_main_scene_ready() -> void:
    """Initialize all game systems when main scene is ready"""
    _initialize_enemy_spawner()
    _initialize_vfx_manager()
    _initialize_ui_systems()
    
    print("✅ All systems initialized")

func _initialize_enemy_spawner() -> void:
    """ONLY initializes enemy spawner"""
    var spawner = preload("res://src/core/EnemySpawner.gd").new()
    spawner.name = "EnemySpawner"
    get_tree().get_root().add_child(spawner)
    
    if spawner.has_method("setup_event_connections"):
        spawner.setup_event_connections()

func _initialize_vfx_manager() -> void:
    """ONLY initializes VFX manager"""
    var vfx_manager = preload("res://src/vfx/VFXManager.gd").new()
    vfx_manager.name = "VFXManager"
    get_tree().get_root().add_child(vfx_manager)

func _initialize_ui_systems() -> void:
    """ONLY initializes UI systems"""
    # Load HUD
    var hud_scene = preload("res://src/ui/hud/GameHUD.tscn")
    var hud = hud_scene.instantiate()
    get_tree().get_root().add_child(hud)
    
    # Load upgrade screen
    var upgrade_screen_scene = preload("res://src/ui/upgrade_selection/UpgradeSelectionScreen.tscn")
    if upgrade_screen_scene:
        var upgrade_screen = upgrade_screen_scene.instantiate()
        get_tree().get_root().add_child(upgrade_screen)