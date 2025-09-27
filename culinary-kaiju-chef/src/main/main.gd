# Main.gd
extends Node

@export var player_scene: PackedScene
@export var debug_pools: bool = false
var _pool_debug_timer: float = 0.0

func _ready() -> void:
    # Setup environment
    _setup_game_environment()
    
    # Initialize object pools for performance
    _initialize_object_pools()
    
    # Spawn player
    if player_scene:
        var player_instance = player_scene.instantiate()
        add_child(player_instance)
        Game.player = player_instance
        
        print("Player spawned")
    else:
        print("ERROR: Player scene not set")
    
    # Setup enemy spawner with wave data
    var spawner = $EnemySpawner
    if spawner:
        var waves = []
        for i in range(1,8):
            var w = load("res://src/core/spawner/wave_%d.tres" % i)
            if w:
                waves.append(w)
        spawner.spawn_waves = waves
        print("Enemy spawner configured with ", waves.size(), " waves")
    
    # Connect game events
    EventBus.player_died.connect(_on_player_died)
    EventBus.player_leveled_up.connect(_on_player_leveled_up)

func _setup_game_environment() -> void:
    # Reset game state
    Game.reset_game_state()
    
    # Unpause in case we came from a paused state
    Game.unpause_game()

func _initialize_object_pools() -> void:
    # Pre-populate pools for performance
    var enemy_scene = preload("res://features/enemies/base_enemy/BaseEnemy.tscn")
    var projectile_scene = preload("res://features/weapons/base_weapon/BaseProjectile.tscn")
    var xp_gem_scene = preload("res://features/items/xp_gem/XPGem.tscn")
    
    ObjectPool.pre_populate(enemy_scene, 50)
    ObjectPool.pre_populate(projectile_scene, 100)
    ObjectPool.pre_populate(xp_gem_scene, 30)
    
    print("Object pools initialized")

func _on_player_died() -> void:
    print("Player died! Game Over")
    # Could transition to game over screen here
    Game.pause_game()

func _on_player_leveled_up(new_level: int) -> void:
    print("Player leveled up to level ", new_level)

func _process(delta: float) -> void:
    if debug_pools:
        _pool_debug_timer += delta
        if _pool_debug_timer >= 2.0:
            _pool_debug_timer = 0.0
            print("[POOL] ", ObjectPool.get_pool_stats(), " | Game=", Game.get_game_stats())