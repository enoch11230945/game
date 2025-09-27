# SpawnWave.gd
extends Resource
class_name SpawnWave

# The EnemyData resource for the enemies in this wave.
@export var enemy_data: Resource

# The number of enemies to spawn in this wave.
@export var count: int = 10

# The time in seconds (from the start of the game) when this wave should begin.
@export var start_time: float = 0.0

# The duration over which the enemies of this wave should be spawned.
@export var duration: float = 5.0

# Optional: spawn position override (if empty, uses default spawning logic)
@export var spawn_positions: Array[Vector2] = []

# Optional: conditions for this wave to trigger
@export var required_level: int = 1
@export var required_enemies_killed: int = 0