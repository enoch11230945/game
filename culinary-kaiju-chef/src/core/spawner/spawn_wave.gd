# spawn_wave.gd
extends Resource

class_name SpawnWave

@export var start_time: float = 0.0
@export var count: int = 1
@export var enemy_data: EnemyData
@export var spawn_interval: float = 1.0

func _init() -> void:
    resource_name = "SpawnWave"
