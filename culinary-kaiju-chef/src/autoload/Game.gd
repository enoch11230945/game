# Game.gd - Core game state manager (Linus-approved)
# "A clean global state is the foundation of maintainable code" - Linus Philosophy
extends Node

# === GAME STATE ===
var current_level: int = 1
var current_experience: int = 0
var experience_cap: int = 100
var game_time: float = 0.0
var is_paused: bool = false
var is_game_over: bool = false

# === STATISTICS ===
var total_kills: int = 0
var total_damage_dealt: int = 0
var gold_collected: int = 0
var current_run_gold: int = 0

# === PLAYER STATS (Data-driven base values) ===
var base_health: int = 100
var base_damage_multiplier: float = 1.0
var base_speed_multiplier: float = 1.0
var base_pickup_range: float = 1.0

# === BOSS TRACKING ===
var bosses_defeated: Array[String] = []
var next_boss_time: float = 300.0  # 5 minutes

# === WAVE SYSTEM ===
var current_wave: int = 1
var enemies_spawned_this_wave: int = 0
var enemy_spawn_multiplier: float = 1.0

func _ready():
    print("🎮 Game State Manager initialized - Linus standards met")
    # Connect to key events
    EventBus.enemy_died.connect(_on_enemy_died)
    EventBus.player_level_up.connect(_on_player_level_up)

func _process(delta):
    if not is_paused and not is_game_over:
        game_time += delta
        check_boss_spawn_conditions()

func start_new_game():
    """Initialize a fresh game state"""
    current_level = 1
    current_experience = 0
    experience_cap = 100
    game_time = 0.0
    is_paused = false
    is_game_over = false
    total_kills = 0
    total_damage_dealt = 0
    current_run_gold = 0
    bosses_defeated.clear()
    current_wave = 1
    enemies_spawned_this_wave = 0
    next_boss_time = 300.0
    
    EventBus.game_started.emit()
    print("🚀 New game started - Clean slate achieved")

func add_experience(amount: int):
    """Linus-style XP system - no edge cases"""
    current_experience += amount
    
    while current_experience >= experience_cap:
        level_up()

func level_up():
    """Handle level progression - clean and simple"""
    current_level += 1
    current_experience -= experience_cap
    experience_cap = int(experience_cap * 1.2)  # 20% increase each level
    
    EventBus.player_level_up.emit(current_level)
    EventBus.show_upgrade_screen.emit(UpgradeManager.get_random_upgrades(3))
    
    print("📈 Level up! Now level %d" % current_level)

func end_game():
    """Clean game over handling"""
    is_game_over = true
    
    # Add current run gold to persistent total
    PlayerData.add_gold(current_run_gold)
    PlayerData.update_best_stats(game_time, total_kills, current_level)
    
    EventBus.game_over.emit(total_kills, game_time)
    print("🏁 Game Over - Time: %.1fs, Kills: %d, Level: %d" % [game_time, total_kills, current_level])

func check_boss_spawn_conditions():
    """Check if it's time for a boss battle"""
    if game_time >= next_boss_time and not is_boss_active():
        spawn_next_boss()
        next_boss_time += 300.0  # Next boss in 5 minutes

func spawn_next_boss():
    """Spawn appropriate boss based on game time"""
    var boss_data: BossData
    
    if game_time < 600:  # 0-10 minutes
        boss_data = load("res://src/core/data/king_onion_boss.tres")
    elif game_time < 1200:  # 10-20 minutes
        boss_data = load("res://src/core/data/pepper_artillery_boss.tres")
    else:  # 20+ minutes
        boss_data = load("res://src/core/data/final_feast_boss.tres")
    
    if boss_data:
        EventBus.boss_spawn_requested.emit(boss_data)
        print("👑 Boss spawned: %s" % boss_data.boss_name)

func is_boss_active() -> bool:
    """Check if a boss is currently alive"""
    return get_tree().get_nodes_in_group("bosses").size() > 0

func _on_enemy_died(enemy: Node2D, position: Vector2, xp_reward: int):
    """Handle enemy death - update stats"""
    total_kills += 1
    add_experience(xp_reward)
    
    # Gold reward (data-driven later)
    var gold_reward = randi_range(1, 3)
    current_run_gold += gold_reward
    gold_collected += gold_reward

func _on_player_level_up(new_level: int):
    """Respond to level up events"""
    # Apply level-based bonuses
    enemy_spawn_multiplier = 1.0 + (new_level - 1) * 0.1
    
    # Update wave system
    if new_level % 5 == 0:
        advance_wave()

func advance_wave():
    """Progress to next wave with increased difficulty"""
    current_wave += 1
    enemies_spawned_this_wave = 0
    EventBus.wave_started.emit(current_wave)
    print("🌊 Wave %d started" % current_wave)

# === UTILITY FUNCTIONS ===
func get_total_damage_multiplier() -> float:
    """Calculate total damage multiplier from all sources"""
    var multiplier = base_damage_multiplier
    # Add meta progression bonuses
    multiplier *= PlayerData.get_damage_bonus()
    # Add temporary bonuses from upgrades
    return multiplier

func get_total_speed_multiplier() -> float:
    """Calculate total speed multiplier from all sources"""
    var multiplier = base_speed_multiplier
    multiplier *= PlayerData.get_speed_bonus()
    return multiplier

func get_total_health() -> int:
    """Calculate total health from all sources"""
    var health = base_health
    health += PlayerData.get_health_bonus()
    return health

func pause_game():
    """Pause/unpause game state"""
    is_paused = not is_paused
    get_tree().paused = is_paused
    EventBus.game_paused.emit(is_paused)