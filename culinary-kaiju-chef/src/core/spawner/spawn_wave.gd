# src/core/spawner/spawn_wave.gd
extends Resource
class_name SpawnWave

# The type of enemy to spawn
@export var enemy_data: EnemyData
@export var enemy_data_path: String

# The number of enemies in this wave
@export var count: int = 10

# The time in the game (in seconds) when this wave should start
@export var start_time: float = 0.0

func get_enemy_data() -> EnemyData:
    if enemy_data:
        return enemy_data
    elif enemy_data_path:
        var data = load(enemy_data_path)
        return data as EnemyData
    return null