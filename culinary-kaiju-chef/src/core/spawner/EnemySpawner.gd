# src/core/spawner/EnemySpawner.gd
extends Node

@export var spawn_waves: Array[SpawnWave]
@export var max_active_enemies: int = 50  # Performance limit
@export var spawn_delay: float = 0.1     # Delay between spawns
@export var difficulty_scaling: bool = true  # Enable difficulty scaling

var time: float = 0.0
var current_wave_index: int = 0
var enemies_spawned_this_wave: int = 0
var spawn_timer: float = 0.0
var active_enemies: Array = []
var total_enemies_defeated: int = 0
var current_difficulty_multiplier: float = 1.0

# Preload scenes for better performance
var preloaded_scenes: Dictionary = {}

func _ready():
    print("🔥 EnemySpawner ready - Total waves:", spawn_waves.size())
    print("⚙️  Max active enemies:", max_active_enemies)
    print("📈 Difficulty scaling:", difficulty_scaling)
    set_process(true)
    preload_enemy_scenes()

func preload_enemy_scenes():
    """Preload enemy scenes to avoid loading during gameplay"""
    for wave in spawn_waves:
        var enemy_data = wave.get_enemy_data()
        if enemy_data and enemy_data.scene_path:
            if not preloaded_scenes.has(enemy_data.scene_path):
                preloaded_scenes[enemy_data.scene_path] = load(enemy_data.scene_path)
                print("📦 Preloaded enemy scene:", enemy_data.scene_path)

func _process(delta: float) -> void:
    if current_wave_index >= spawn_waves.size():
        if active_enemies.is_empty():
            print("🎯 All waves completed and all enemies defeated!")
            set_process(false)
            emit_signal("all_waves_completed")
        return

    time += delta
    spawn_timer += delta

    var current_wave = spawn_waves[current_wave_index]

    # Clean up destroyed enemies
    active_enemies = active_enemies.filter(func(enemy): return is_instance_valid(enemy))

    if time >= current_wave.start_time and enemies_spawned_this_wave < current_wave.count:
        if active_enemies.size() < max_active_enemies and spawn_timer >= spawn_delay:
            spawn_single_enemy(current_wave)
            spawn_timer = 0.0

    # Move to next wave when current wave is complete
    if enemies_spawned_this_wave >= current_wave.count and active_enemies.is_empty():
        current_wave_index += 1
        enemies_spawned_this_wave = 0
        if difficulty_scaling:
            current_difficulty_multiplier += 0.1  # Increase difficulty by 10% each wave
            print("📈 Difficulty increased to:", current_difficulty_multiplier)
        print("📈 Moving to wave:", current_wave_index + 1)
        emit_signal("wave_completed", current_wave_index)

func spawn_single_enemy(wave: SpawnWave) -> void:
    var enemy_data = wave.get_enemy_data()
    if not enemy_data:
        print("❌ Failed to get enemy data")
        return

    # Use preloaded scene if available
    var enemy_scene = preloaded_scenes.get(enemy_data.scene_path)
    if not enemy_scene:
        enemy_scene = load(enemy_data.scene_path)
        preloaded_scenes[enemy_data.scene_path] = enemy_scene

    if not enemy_scene:
        print("❌ Failed to load enemy scene:", enemy_data.scene_path)
        return

    var enemy = enemy_scene.instantiate()
    print("✅ Spawned enemy:", enemies_spawned_this_wave + 1, "of", wave.count)

    # Get a random position outside the screen
    var spawn_position = _get_random_spawn_position()
    print("📍 Spawn position:", spawn_position)

    # Add to scene and initialize with scaled data
    get_tree().current_scene.add_child(enemy)
    active_enemies.append(enemy)

    # Apply difficulty scaling
    var scaled_data = {
        "health": int(enemy_data.health * current_difficulty_multiplier),
        "speed": enemy_data.speed * current_difficulty_multiplier,
        "damage": int(enemy_data.damage * current_difficulty_multiplier),
        "xp_value": int(enemy_data.xp_value * current_difficulty_multiplier)
    }

    enemy.initialize(spawn_position, scaled_data)
    print("⚡ Enemy initialized with scaled stats - HP:", scaled_data.health, "Speed:", scaled_data.speed)

    enemies_spawned_this_wave += 1

func on_enemy_destroyed(enemy):
    """Called when an enemy is destroyed"""
    active_enemies.erase(enemy)
    total_enemies_defeated += 1
    print("💀 Enemy defeated! Total defeated:", total_enemies_defeated)

    # Emit signal for other systems to listen to
    emit_signal("enemy_defeated", enemy)

func _get_random_spawn_position() -> Vector2:
    var viewport_rect = get_viewport().get_visible_rect()
    var spawn_position = Vector2.ZERO
    var spawn_margin = 150  # Increased margin for better gameplay

    match randi() % 4:
        0: # Top
            spawn_position = Vector2(randf_range(0, viewport_rect.size.x), -spawn_margin)
        1: # Bottom
            spawn_position = Vector2(randf_range(0, viewport_rect.size.x), viewport_rect.size.y + spawn_margin)
        2: # Left
            spawn_position = Vector2(-spawn_margin, randf_range(0, viewport_rect.size.y))
        3: # Right
            spawn_position = Vector2(viewport_rect.size.x + spawn_margin, randf_range(0, viewport_rect.size.y))

    return spawn_position

# Signals
signal wave_completed(wave_index: int)
signal enemy_defeated(enemy)
signal all_waves_completed
