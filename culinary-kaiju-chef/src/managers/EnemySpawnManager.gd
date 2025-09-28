# EnemySpawnManager.gd - Pure enemy spawning logic (Linus refactor)
# "Do one thing and do it well" - Linus Philosophy
extends Node

# === SPAWN CONFIGURATION ===
var base_spawn_interval: float = 2.0
var spawn_interval_reduction: float = 0.05  # Faster spawning over time
var max_enemies: int = 200
var spawn_distance: float = 600.0

# === SPAWN STATE ===
var spawn_timer: float = 0.0
var current_spawn_interval: float = 2.0
var active_enemies: Array[Node2D] = []

# === ENEMY SCENES ===
var enemy_scenes: Dictionary = {}

# === WAVE SYSTEM ===
var current_wave: int = 1
var enemies_spawned_this_wave: int = 0
var enemies_per_wave: int = 10

func _ready() -> void:
    print("👹 EnemySpawnManager initialized")
    _preload_enemy_scenes()
    _connect_events()
    
    # Initialize spawn timer
    spawn_timer = base_spawn_interval

func _preload_enemy_scenes() -> void:
    """Preload all enemy scenes for performance"""
    enemy_scenes["basic"] = preload("res://features/enemies/base_enemy/BaseEnemy.tscn")
    enemy_scenes["broccoli"] = preload("res://features/enemies/broccoli_splitter/BroccoliSplitter.tscn")
    enemy_scenes["carrot"] = preload("res://features/enemies/carrot_tank/CarrotTank.tscn")
    enemy_scenes["potato"] = preload("res://features/enemies/potato_bomber/PotatoBomber.tscn")
    
    print("✅ Enemy scenes preloaded: %d types" % enemy_scenes.size())

func _connect_events() -> void:
    """Connect to relevant events"""
    EventBus.enemy_died.connect(_on_enemy_died)
    EventBus.game_started.connect(_on_game_started)
    EventBus.game_over.connect(_on_game_over)

func _process(delta: float) -> void:
    if Game and Game.is_paused:
        return
    if Game and Game.is_game_over:
        return
    
    # Update spawn timer
    spawn_timer -= delta
    
    # Spawn enemies if timer reached
    if spawn_timer <= 0 and can_spawn_enemy():
        spawn_random_enemy()
        reset_spawn_timer()
    
    # Clean up invalid enemies
    cleanup_enemies()

func can_spawn_enemy() -> bool:
    """Check if we can spawn a new enemy"""
    return active_enemies.size() < max_enemies

func spawn_random_enemy() -> void:
    """Spawn a random enemy type"""
    var enemy_types = enemy_scenes.keys()
    var random_type = enemy_types[randi() % enemy_types.size()]
    spawn_enemy_of_type(random_type)

func spawn_enemy_of_type(enemy_type: String) -> void:
    """Spawn specific enemy type"""
    if not enemy_scenes.has(enemy_type):
        print("⚠️ Unknown enemy type: %s" % enemy_type)
        return
    
    var enemy_scene = enemy_scenes[enemy_type]
    var enemy = enemy_scene.instantiate()
    if not enemy:
        print("❌ Failed to instantiate enemy: %s" % enemy_type)
        return
    
    # Get spawn position
    var spawn_pos = get_spawn_position()
    
    # Add to scene
    get_tree().get_first_node_in_group("main").add_child(enemy)
    enemy.global_position = spawn_pos
    
    # Create enemy data based on current difficulty
    var enemy_data = create_enemy_data(enemy_type)
    
    # Initialize enemy
    if enemy.has_method("initialize"):
        enemy.initialize(spawn_pos, enemy_data)
    
    # Add to tracking
    enemy.add_to_group("enemies")
    active_enemies.append(enemy)
    
    # Update statistics
    enemies_spawned_this_wave += 1
    
    # Emit spawn event
    EventBus.enemy_spawned.emit(enemy, enemy_data)
    
    print("👹 Spawned %s enemy at %s (Active: %d)" % [enemy_type, spawn_pos, active_enemies.size()])

func get_spawn_position() -> Vector2:
    """Get random spawn position around player"""
    var player = get_tree().get_first_node_in_group("player")
    var player_pos = player.global_position if player else Vector2(400, 300)
    
    # Random angle around player
    var angle = randf() * TAU
    var spawn_pos = player_pos + Vector2.from_angle(angle) * spawn_distance
    
    # Keep within reasonable bounds
    spawn_pos.x = clamp(spawn_pos.x, -1000, 2000)
    spawn_pos.y = clamp(spawn_pos.y, -1000, 2000)
    
    return spawn_pos

func create_enemy_data(enemy_type: String) -> EnemyData:
    """Create scaled enemy data based on current game state"""
    var data = EnemyData.new()
    
    # Base stats by type
    match enemy_type:
        "basic":
            data.enemy_name = "Basic Enemy"
            data.health = 50
            data.speed = 80.0
            data.damage = 10
            data.experience_reward = 15
        "broccoli":
            data.enemy_name = "Broccoli Splitter"
            data.health = 75
            data.speed = 60.0
            data.damage = 15
            data.experience_reward = 25
        "carrot":
            data.enemy_name = "Carrot Tank"
            data.health = 120
            data.speed = 50.0
            data.damage = 20
            data.experience_reward = 35
        "potato":
            data.enemy_name = "Potato Bomber"
            data.health = 60
            data.speed = 70.0
            data.damage = 25
            data.experience_reward = 30
        _:
            # Default fallback
            data.enemy_name = "Unknown Enemy"
            data.health = 50
            data.speed = 80.0
            data.damage = 10
            data.experience_reward = 15
    
    # Apply difficulty scaling
    if Game:
        data.health = int(data.health * Game.get_enemy_health_multiplier())
        data.damage = int(data.damage * Game.get_enemy_damage_multiplier())
        data.experience_reward += Game.current_level
    
    return data

func reset_spawn_timer() -> void:
    """Reset spawn timer with current interval"""
    current_spawn_interval = base_spawn_interval
    
    # Reduce interval over time for increased difficulty
    if Game:
        var time_reduction = Game.game_time * spawn_interval_reduction
        current_spawn_interval = max(0.5, base_spawn_interval - time_reduction)
        
        # Apply spawn rate multiplier
        current_spawn_interval /= Game.get_spawn_rate_multiplier()
    
    spawn_timer = current_spawn_interval

func cleanup_enemies() -> void:
    """Remove invalid enemies from tracking"""
    for i in range(active_enemies.size() - 1, -1, -1):
        if not is_instance_valid(active_enemies[i]):
            active_enemies.remove_at(i)

# === EVENT HANDLERS ===
func _on_enemy_died(enemy: Node2D, position: Vector2, xp_reward: int) -> void:
    """Handle enemy death - spawn gold coins (Epic 2.1)"""
    active_enemies.erase(enemy)
    
    # 金币掉落几率 (Epic 2.1)
    var gold_drop_chance = 0.3  # 30% 几率掉落金币
    if randf() < gold_drop_chance:
        spawn_gold_coin(position)

func _on_game_started() -> void:
    """Reset spawn manager for new game"""
    current_wave = 1
    enemies_spawned_this_wave = 0
    active_enemies.clear()
    spawn_timer = base_spawn_interval

func _on_game_over(final_score: int, time_survived: float) -> void:
    """Handle game over"""
    # Stop all spawning
    pass

# === WAVE MANAGEMENT ===
func advance_wave() -> void:
    """Advance to next wave"""
    current_wave += 1
    enemies_spawned_this_wave = 0
    enemies_per_wave = int(enemies_per_wave * 1.2)  # 20% more enemies per wave
    
    EventBus.wave_started.emit(current_wave)
    print("🌊 Wave %d started - Target: %d enemies" % [current_wave, enemies_per_wave])

func get_spawn_statistics() -> Dictionary:
    """Get current spawn statistics"""
    return {
        "active_enemies": active_enemies.size(),
        "current_wave": current_wave,
        "enemies_spawned": enemies_spawned_this_wave,
        "spawn_interval": current_spawn_interval,
        "max_enemies": max_enemies
    }

func spawn_gold_coin(position: Vector2) -> void:
    """生成金币 (Epic 2.1)"""
    var gold_scene = preload("res://features/items/gold_coin/GoldCoin.tscn")
    var gold_coin = gold_scene.instantiate()
    
    if not gold_coin:
        return
    
    # 添加到场景
    get_tree().get_first_node_in_group("main").add_child(gold_coin)
    gold_coin.global_position = position
    
    # 随机金币价值 (基于游戏进度)
    var base_value = 1
    if Game:
        base_value += Game.current_level / 5  # 每5级增加1基础金币
    
    var gold_value = base_value + randi() % 3  # 1-3额外金币
    gold_coin.initialize(gold_value)
    
    print("💰 Spawned gold coin worth %d at %s" % [gold_value, position])