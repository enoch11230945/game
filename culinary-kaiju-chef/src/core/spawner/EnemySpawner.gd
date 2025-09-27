# EnemySpawner.gd
extends Node

@export var spawn_waves: Array
@export var spawn_radius: float = 600.0
@export var continuous_spawning: bool = false
@export var continuous_spawn_rate: float = 2.0

var time: float = 0.0
var current_wave_index: int = 0
var wave_spawn_timers: Dictionary = {}
var continuous_timer: float = 0.0

var player: Node2D = null

func _ready() -> void:
    # Find player reference
    call_deferred("find_player")
    
    # Connect to game events
    EventBus.enemy_spawned.connect(_on_enemy_spawned)
    EventBus.enemy_killed.connect(_on_enemy_killed)

func find_player() -> void:
    player = get_tree().get_first_node_in_group("player")
    if not player:
        print("Warning: Player not found for enemy spawning")

func _process(delta: float) -> void:
    if Game.is_paused or not player:
        return
    
    time += delta
    
    # Process wave spawning
    _process_wave_spawning()
    
    # Process continuous spawning
    if continuous_spawning:
        continuous_timer += delta
        if continuous_timer >= continuous_spawn_rate:
            continuous_timer = 0.0
            _spawn_continuous_enemy()

func _process_wave_spawning() -> void:
    # Check for new waves to start
    if current_wave_index < spawn_waves.size():
        var next_wave = spawn_waves[current_wave_index]
        if time >= next_wave.start_time and _wave_conditions_met(next_wave):
            start_wave(next_wave)
            current_wave_index += 1
    
    # Process active wave spawning
    var waves_to_process = wave_spawn_timers.keys()
    for wave in waves_to_process:
        var timer_data = wave_spawn_timers[wave]
        timer_data.time_since_last_spawn += get_process_delta_time()
        
        if timer_data.time_since_last_spawn >= timer_data.spawn_interval:
            spawn_enemy(wave.enemy_data)
            timer_data.spawned_count += 1
            timer_data.time_since_last_spawn = 0.0
            
            if timer_data.spawned_count >= wave.count:
                wave_spawn_timers.erase(wave)

func _wave_conditions_met(wave: Resource) -> bool:
    return Game.level >= wave.required_level and Game.total_enemies_killed >= wave.required_enemies_killed

func start_wave(wave: Resource) -> void:
    if wave.count <= 0 or wave.duration <= 0:
        return
    
    var spawn_interval = wave.duration / wave.count
    wave_spawn_timers[wave] = {
        "spawn_interval": spawn_interval,
        "spawned_count": 0,
        "time_since_last_spawn": 0.0
    }
    
    print("Started wave: ", wave.enemy_data.name, " x", wave.count)

func spawn_enemy(enemy_data: Resource, custom_position: Vector2 = Vector2.ZERO) -> void:
    if not enemy_data or not enemy_data.scene:
        print("Warning: Invalid enemy data for spawning")
        return
    
    var spawn_position: Vector2
    if custom_position != Vector2.ZERO:
        spawn_position = custom_position
    else:
        spawn_position = _get_spawn_position()
    
    var enemy_instance = ObjectPool.request(enemy_data.scene)
    if enemy_instance:
        get_tree().get_root().add_child(enemy_instance)
        
        # Initialize enemy
        if enemy_instance.has_method("initialize"):
            enemy_instance.initialize(spawn_position, enemy_data)
        else:
            enemy_instance.global_position = spawn_position
        
        Game.enemies_alive += 1
        EventBus.enemy_spawned.emit(enemy_instance)

func _get_spawn_position() -> Vector2:
    if not player:
        return Vector2.ZERO
    
    # Spawn in a circle around the player, but outside the screen
    var random_angle = randf_range(0, TAU)
    var spawn_distance = spawn_radius + randf_range(0, 100)
    return player.global_position + Vector2.RIGHT.rotated(random_angle) * spawn_distance

func _spawn_continuous_enemy() -> void:
    # Spawn a random enemy type from available waves
    if spawn_waves.is_empty():
        return
    
    var available_waves = spawn_waves.filter(func(w): return _wave_conditions_met(w))
    if available_waves.is_empty():
        return
    
    var random_wave = available_waves[randi() % available_waves.size()]
    spawn_enemy(random_wave.enemy_data)

func _on_enemy_spawned(enemy: Node) -> void:
    # Optional: Add enemy to a tracking group or perform other setup
    enemy.add_to_group("enemies")

func _on_enemy_killed(enemy: Node, xp_reward: int) -> void:
    # Optional: Handle enemy death effects or spawn replacements
    pass

# Public API for manual spawning
func spawn_enemy_at_position(enemy_data: Resource, position: Vector2) -> void:
    spawn_enemy(enemy_data, position)

func spawn_wave_immediately(wave: Resource) -> void:
    for i in range(wave.count):
        spawn_enemy(wave.enemy_data)

func clear_all_enemies() -> void:
    var enemies = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies:
        ObjectPool.reclaim(enemy)