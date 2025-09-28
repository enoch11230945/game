# CLEAN_MAIN.gd - Linus-approved clean main scene (No more spaghetti!)
# "Main should coordinate, not implement" - Linus Philosophy
extends Node2D

# === REFERENCES TO MANAGERS ===
var game_manager: Node
var enemy_spawn_manager: Node
var weapon_manager: Node

# === PLAYER ===
var player: CharacterBody2D

# === UI ===
var ui_layer: CanvasLayer

func _ready() -> void:
    print("=== CLEAN MAIN STARTED (Linus Refactor) ===")
    
    # Initialize managers
    setup_managers()
    
    # Create player
    setup_player()
    
    # Create UI
    setup_ui()
    
    # Start game
    start_game()
    
    print("✅ Clean main initialized - Each system handles its own domain")

func setup_managers() -> void:
    """Initialize all manager systems"""
    # GameManager
    game_manager = preload("res://src/managers/GameManager.gd").new()
    game_manager.name = "GameManager"
    add_child(game_manager)
    
    # MetaProgressionSystem (Epic 2.1)
    var meta_system = preload("res://src/systems/MetaProgressionSystem.gd").new()
    meta_system.name = "MetaProgressionSystem"
    add_child(meta_system)
    
    # Load saved progress
    if meta_system.has_method("load_progress"):
        meta_system.load_progress()
    
    # EnemySpawnManager
    enemy_spawn_manager = preload("res://src/managers/EnemySpawnManager.gd").new()
    enemy_spawn_manager.name = "EnemySpawnManager"
    add_child(enemy_spawn_manager)
    
    # WeaponManager
    weapon_manager = preload("res://src/managers/WeaponManager.gd").new()
    weapon_manager.name = "WeaponManager"
    add_child(weapon_manager)
    
    print("✅ All managers initialized")

func setup_player() -> void:
    """Create and setup player"""
    var player_scene = preload("res://features/player/Player.tscn")
    player = player_scene.instantiate()
    
    if not player:
        # Fallback: create basic player
        player = CharacterBody2D.new()
        player.name = "Player"
        
        # Add visual
        var sprite = Sprite2D.new()
        sprite.modulate = Color(0.2, 0.8, 1.0, 1.0)
        sprite.scale = Vector2(40, 40)
        player.add_child(sprite)
        
        # Add collision
        var collision = CollisionShape2D.new()
        var shape = CircleShape2D.new()
        shape.radius = 20.0
        collision.shape = shape
        player.add_child(collision)
    
    # Position and add to scene
    player.global_position = Vector2(400, 300)
    player.add_to_group("player")
    add_child(player)
    
    # Equip starting weapon
    if weapon_manager and weapon_manager.has_method("equip_weapon"):
        weapon_manager.equip_weapon("Throwing Knife", player)
    
    print("✅ Player created with starting weapon")

func setup_ui() -> void:
    """Create UI layer"""
    ui_layer = CanvasLayer.new()
    ui_layer.name = "UI"
    add_child(ui_layer)
    
    # Stats display
    var stats_label = Label.new()
    stats_label.name = "StatsLabel"
    stats_label.position = Vector2(20, 20)
    stats_label.size = Vector2(400, 100)
    stats_label.text = "Loading..."
    ui_layer.add_child(stats_label)
    
    # Instructions
    var help_label = Label.new()
    help_label.position = Vector2(20, get_viewport().get_visible_rect().size.y - 60)
    help_label.text = "WASD: Move | SPACE: Stats | ESC: Quit"
    help_label.modulate = Color(0.7, 0.7, 0.7, 1.0)
    ui_layer.add_child(help_label)
    
    print("✅ UI layer created")

func start_game() -> void:
    """Start the game"""
    EventBus.game_started.emit()
    
    # Add main group for managers to find
    add_to_group("main")
    
    print("🚀 Game started - Clean architecture active")

func _process(delta: float) -> void:
    # Handle player input (only movement - weapons handled by WeaponManager)
    handle_player_movement(delta)
    
    # Update UI
    update_ui()

func handle_player_movement(delta: float) -> void:
    """Handle player movement input"""
    if not player:
        return
    
    var input_dir = Vector2.ZERO
    if Input.is_key_pressed(KEY_A):
        input_dir.x -= 1
    if Input.is_key_pressed(KEY_D):
        input_dir.x += 1
    if Input.is_key_pressed(KEY_W):
        input_dir.y -= 1
    if Input.is_key_pressed(KEY_S):
        input_dir.y += 1
    
    if input_dir != Vector2.ZERO:
        player.velocity = input_dir.normalized() * 300.0
        player.move_and_slide()

func update_ui() -> void:
    """Update UI elements"""
    var stats_label = ui_layer.get_node_or_null("StatsLabel")
    if not stats_label or not game_manager:
        return
    
    var stats = game_manager.get_game_stats()
    stats_label.text = "Level: %d | XP: %d/%d | Time: %.1fs | Enemies: %d" % [
        stats.level,
        stats.xp,
        stats.xp_required,
        stats.game_time,
        get_tree().get_nodes_in_group("enemies").size()
    ]

func _input(event: InputEvent) -> void:
    """Handle input events"""
    if event.is_action_pressed("ui_accept"):  # SPACE
        print_system_stats()
    elif event.is_action_pressed("ui_cancel"):  # ESC
        print("👋 Thanks for playing!")
        get_tree().quit()

func print_system_stats() -> void:
    """Print statistics from all managers"""
    print("=== SYSTEM STATS ===")
    
    if game_manager and game_manager.has_method("get_game_stats"):
        var game_stats = game_manager.get_game_stats()
        print("Game: Level %d, Time %.1fs, Kills %d" % [
            game_stats.level, game_stats.game_time, game_stats.enemies_killed
        ])
    
    if enemy_spawn_manager and enemy_spawn_manager.has_method("get_spawn_statistics"):
        var spawn_stats = enemy_spawn_manager.get_spawn_statistics()
        print("Spawn: %d active, Wave %d, Interval %.2fs" % [
            spawn_stats.active_enemies, spawn_stats.current_wave, spawn_stats.spawn_interval
        ])
    
    if weapon_manager and weapon_manager.has_method("get_weapon_stats"):
        var weapon_stats = weapon_manager.get_weapon_stats()
        print("Weapons: %d active, %.2fs interval" % [
            weapon_stats.active_weapons, weapon_stats.attack_interval
        ])
    
    if player:
        print("Player: %s" % player.global_position)