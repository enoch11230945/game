# spawn_wave.gd
# A resource that defines a single wave of enemies to be spawned.
extends Resource
class_name SpawnWave

# The EnemyData resource for the enemies in this wave.
@export var enemy_data: EnemyData

# The number of enemies to spawn in this wave.
@export var count: int = 10

# The time in seconds (from the start of the game) when this wave should begin.
@export var start_time: float = 0.0

# The duration over which the enemies of this wave should be spawned.
@export var duration: float = 5.0
