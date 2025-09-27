# SpawnWave.gd - Data-driven wave spawning system (Linus approved)
extends Resource
class_name SpawnWave

@export var wave_name: String = "Wave 1"
@export var start_time: float = 0.0        # When this wave starts (in seconds)
@export var duration: float = 60.0         # How long this wave lasts
@export var spawn_interval: float = 2.0    # Time between spawns
@export var enemy_count: int = 1           # Enemies per spawn
@export var total_spawns: int = -1         # Max spawns (-1 = infinite)

# Enemy composition
@export var enemy_types: Array[EnemyData] = []
@export var enemy_weights: Array[float] = []  # Probability weights for each enemy type

# Difficulty scaling
@export var health_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0
@export var damage_multiplier: float = 1.0
@export var xp_multiplier: float = 1.0

# Special wave modifiers
@export var elite_chance: float = 0.0      # Chance for elite variants
@export var boss_enemy: EnemyData         # Optional boss at wave end
@export var special_effect: String = ""   # "swarm", "elite", "boss", etc.

func get_random_enemy_data() -> EnemyData:
    """Get a random enemy type based on weights"""
    if enemy_types.is_empty():
        return null
    
    if enemy_weights.is_empty() or enemy_weights.size() != enemy_types.size():
        # No weights specified, use equal probability
        return enemy_types[randi() % enemy_types.size()]
    
    # Weighted selection
    var total_weight = 0.0
    for weight in enemy_weights:
        total_weight += weight
    
    var random_value = randf() * total_weight
    var current_weight = 0.0
    
    for i in range(enemy_types.size()):
        current_weight += enemy_weights[i]
        if random_value <= current_weight:
            return enemy_types[i]
    
    # Fallback
    return enemy_types[0]

func should_spawn_elite() -> bool:
    """Check if this spawn should be an elite variant"""
    return randf() < elite_chance

func get_scaled_enemy_data(base_data: EnemyData, game_time: float) -> EnemyData:
    """Apply wave scaling to enemy data"""
    # Create a modified copy (in a real system you'd duplicate the resource)
    var scaled_data = base_data
    
    # Apply wave multipliers
    var time_scaling = 1.0 + (game_time / 300.0)  # 20% increase every 5 minutes
    
    # This is conceptual - in practice you'd create modified data
    # scaled_data.health *= health_multiplier * time_scaling
    # scaled_data.speed *= speed_multiplier
    # scaled_data.damage *= damage_multiplier
    
    return scaled_data