# EnemySpawner.gd
extends Node

# An array of SpawnWave resources that defines the entire enemy timeline for the level.
# You must create SpawnWave resources in the editor and add them to this array.
@export var spawn_waves: Array[SpawnWave]

var time: float = 0.0
var current_wave_index: int = 0
var wave_spawn_timers: Dictionary = {} # Tracks spawning progress for active waves

func _process(delta: float) -> void:
    time += delta

    # --- Wave Triggering ---
    if current_wave_index < spawn_waves.size():
        var next_wave = spawn_waves[current_wave_index]
        if time >= next_wave.start_time:
            start_wave(next_wave)
            current_wave_index += 1

    # --- Active Wave Spawning ---
    var waves_to_process = wave_spawn_timers.keys()
    for wave in waves_to_process:
        var timer_data = wave_spawn_timers[wave]
        timer_data.time_since_last_spawn += delta
        
        if timer_data.time_since_last_spawn >= timer_data.spawn_interval:
            spawn_enemy(wave.enemy_data)
            timer_data.spawned_count += 1
            timer_data.time_since_last_spawn = 0
            
            if timer_data.spawned_count >= wave.count:
                # Wave complete, remove from active timers
                wave_spawn_timers.erase(wave)

func start_wave(wave: SpawnWave) -> void:
    if wave.count <= 0 or wave.duration <= 0:
        return

    var spawn_interval = wave.duration / wave.count
    wave_spawn_timers[wave] = {
        "spawn_interval": spawn_interval,
        "spawned_count": 0,
        "time_since_last_spawn": 0.0
    }

func spawn_enemy(enemy_data: EnemyData) -> void:
    var player = get_tree().get_first_node_in_group("player")
    if not is_instance_valid(player):
        return

    var spawn_radius = get_viewport().get_visible_rect().size.length() / 2 + 50
    var random_angle = randf_range(0, TAU)
    var spawn_position = player.global_position + Vector2.RIGHT.rotated(random_angle) * spawn_radius

    var enemy_instance = ObjectPool.request(enemy_data.scene) as BaseEnemy
    if enemy_instance:
        get_tree().get_root().add_child(enemy_instance)
        enemy_instance.initialize(spawn_position, enemy_data)