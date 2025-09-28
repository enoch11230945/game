# EnemySpawner.gd - Data-driven enemy spawning system (Linus approved)
extends Node2D
class_name EnemySpawner

# === DATA RESOURCES (No hardcoding!) ===
@export var spawn_waves: Array[SpawnWave] = []  # Array of SpawnWave resources

# === SPAWNING STATE ===
var game_time: float = 0.0
var current_wave_index: int = 0
var current_wave: SpawnWave = null
var wave_spawn_timer: float = 0.0
var wave_spawn_count: int = 0

# === SPAWN TIMING (for compatibility) ===
var base_spawn_interval: float = 2.0
var current_spawn_interval: float = 2.0

# === ENEMY POOL REFERENCES ===
var enemy_scenes: Dictionary = {}

# === SPAWN AREA CONFIGURATION ===
var spawn_distance: float = 600.0  # Distance from player to spawn
var despawn_distance: float = 800.0  # Distance to despawn enemies

func _ready() -> void:
    print("🏭 EnemySpawner initialized - Data-driven spawning")
    _preload_enemy_scenes()
    _setup_spawn_waves()

func _preload_enemy_scenes() -> void:
    """Preload all enemy scenes for performance"""
    enemy_scenes["onion"] = preload("res://features/enemies/base_enemy/BaseEnemy.tscn")
    enemy_scenes["broccoli"] = preload("res://features/enemies/broccoli_splitter/BroccoliSplitter.tscn")
    enemy_scenes["carrot"] = preload("res://features/enemies/carrot_tank/CarrotTank.tscn")
    enemy_scenes["potato"] = preload("res://features/enemies/potato_bomber/PotatoBomber.tscn")
    
    print("✅ Enemy scenes preloaded: %d types" % enemy_scenes.size())

func _setup_spawn_waves() -> void:
    """Setup default spawn waves if none configured"""
    if spawn_waves.is_empty():
        print("⚠️ No spawn waves configured, creating defaults")
        _create_default_waves()

func _create_default_waves() -> void:
    """Create default wave progression"""
    # Early wave - basic enemies only
    var wave1 = SpawnWave.new()
    wave1.wave_name = "Opening Assault"
    wave1.start_time = 0.0
    wave1.duration = 60.0
    wave1.spawn_interval = 2.0
    wave1.enemy_count = 1
    wave1.enemy_types = [load("res://src/core/data/onion_enemy.tres")]
    spawn_waves.append(wave1)
    
    # Mid wave - mixed enemies
    var wave2 = SpawnWave.new()
    wave2.wave_name = "Vegetable Uprising"
    wave2.start_time = 60.0
    wave2.duration = 120.0
    wave2.spawn_interval = 1.5
    wave2.enemy_count = 2
    wave2.enemy_types = [
        load("res://src/core/data/onion_enemy.tres"),
        load("res://features/enemies/enemy_data/speed_demon.tres")
    ]
    wave2.enemy_weights = [0.7, 0.3]  # 70% onions, 30% speed demons
    spawn_waves.append(wave2)
    
    print("✅ Created %d default waves" % spawn_waves.size())

func _process(delta: float) -> void:
    game_time += delta
    
    # Update current wave
    _update_current_wave()
    
    # Process wave spawning
    if current_wave:
        _process_wave_spawning(delta)
    
    # Clean up distant enemies (performance optimization)
    _cleanup_distant_enemies()

func _update_current_wave() -> void:
    """Update which wave is currently active"""
    var target_wave: SpawnWave = null
    
    # Find the appropriate wave for current time
    for i in range(spawn_waves.size() - 1, -1, -1):  # Check from latest to earliest
        var wave = spawn_waves[i]
        if game_time >= wave.start_time:
            target_wave = wave
            current_wave_index = i
            break
    
    # Switch to new wave if needed
    if target_wave != current_wave:
        current_wave = target_wave
        if current_wave:
            wave_spawn_timer = 0.0
            wave_spawn_count = 0
            print("🌊 Wave changed: %s" % current_wave.wave_name)

func _process_wave_spawning(delta: float) -> void:
    """Process spawning for current wave"""
    if not current_wave:
        return
    
    # Check if wave is still active
    var wave_elapsed = game_time - current_wave.start_time
    if wave_elapsed > current_wave.duration:
        return
    
    # Check spawn limits
    if current_wave.total_spawns > 0 and wave_spawn_count >= current_wave.total_spawns:
        return
    
    # Update spawn timer
    wave_spawn_timer += delta
    
    if wave_spawn_timer >= current_wave.spawn_interval:
        wave_spawn_timer = 0.0
        _spawn_wave_enemies()
        wave_spawn_count += 1

func _spawn_wave_enemies() -> void:
    """Spawn enemies for current wave"""
    var player = get_tree().get_first_node_in_group("player")
    if not player or not current_wave:
        return
    
    for i in range(current_wave.enemy_count):
        var enemy_data = current_wave.get_random_enemy_data()
        if enemy_data:
            _spawn_single_enemy_from_data(enemy_data, player.global_position)

func _spawn_single_enemy_from_data(enemy_data: EnemyData, player_pos: Vector2) -> void:
    """Spawn enemy from EnemyData resource"""
    if enemy_data.scene:
        var enemy = ObjectPool.get_enemy(enemy_data.scene)
        if enemy:
            var spawn_pos = get_spawn_position_around_player(player_pos)
            enemy.global_position = spawn_pos
            enemy.initialize(enemy_data)
            get_tree().current_scene.add_child(enemy)

func _spawn_single_enemy(enemy_type: String, player_pos: Vector2) -> void:
    """Spawn a single enemy using ObjectPool - Linus approved"""
    if not enemy_scenes.has(enemy_type):
        print("❌ Unknown enemy type: %s" % enemy_type)
        return
    
    var enemy_scene = enemy_scenes[enemy_type]
    var enemy = ObjectPool.get_enemy(enemy_scene)
    if not enemy:
        print("❌ Failed to get enemy from pool")
        return
    
    # Calculate spawn position (around player, outside view)
    var spawn_pos = _get_spawn_position(player_pos)
    
    # Add to scene tree
    get_tree().get_root().add_child(enemy)
    
    # Load enemy data and initialize
    var enemy_data = _load_enemy_data(enemy_type)
    if enemy.has_method("initialize"):
        enemy.initialize(spawn_pos, enemy_data)
    
    print("✅ Spawned %s enemy at %s" % [enemy_type, spawn_pos])

func _get_spawn_position(player_pos: Vector2) -> Vector2:
    """Calculate spawn position outside player view"""
    var angle = randf() * 2 * PI
    var distance = spawn_distance + randf() * 100.0  # Add some randomness
    
    var spawn_pos = player_pos + Vector2(cos(angle), sin(angle)) * distance
    return spawn_pos

func _load_enemy_data(enemy_type: String) -> Resource:
    """Load enemy data resource based on type"""
    match enemy_type:
        "onion":
            return load("res://src/core/data/onion_enemy.tres")
        "broccoli":
            return load("res://features/enemies/enemy_data/BroccoliSplitterData.tres")
        "carrot":
            return load("res://features/enemies/enemy_data/CarrotTankData.tres")
        "potato":
            return load("res://features/enemies/enemy_data/PotatoBomberData.tres")
        _:
            print("❌ No data found for enemy type: %s" % enemy_type)
            return null

func _cleanup_distant_enemies() -> void:
    """Remove enemies that are too far from player (performance)"""
    var player = get_tree().get_first_node_in_group("player")
    if not player:
        return
    
    var enemies = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        
        var distance = player.global_position.distance_to(enemy.global_position)
        if distance > despawn_distance:
            # Return to pool instead of queue_free
            ObjectPool.return_enemy(enemy)

# === EVENT HANDLERS ===

func _on_game_started() -> void:
    """Reset spawner when game starts"""
    game_time = 0.0
    current_wave_index = 0
    wave_spawn_timer = 0.0
    current_spawn_interval = base_spawn_interval

func _on_game_paused(paused: bool) -> void:
    """Pause/resume spawning"""
    set_process(not paused)

# Connect to EventBus in main scene
func setup_event_connections() -> void:
    EventBus.game_started.connect(_on_game_started)
    EventBus.game_paused.connect(_on_game_paused)