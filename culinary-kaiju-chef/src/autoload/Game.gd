# Game.gd
# Manages the overall game state for a single run.
extends Node

var score: int = 0
var level: int = 1
var current_xp: int = 0
var required_xp: int = 10
var time_elapsed: float = 0.0
var is_paused: bool = false

# Game state
var player: Node = null
var enemies_alive: int = 0
var total_enemies_killed: int = 0

func _ready() -> void:
    # Connect to EventBus signals
    EventBus.player_experience_gained.connect(_on_experience_gained)
    EventBus.enemy_killed.connect(_on_enemy_killed)

func _process(delta: float) -> void:
    if not is_paused:
        time_elapsed += delta

func gain_experience(amount: int) -> void:
    current_xp += amount
    EventBus.player_experience_gained.emit(amount, current_xp, required_xp)
    
    if current_xp >= required_xp:
        level_up()

func level_up() -> void:
    current_xp -= required_xp
    level += 1
    required_xp = int(required_xp * 1.5)
    pause_game()
    EventBus.player_leveled_up.emit(level)
    _auto_apply_test_upgrade()
    unpause_game()

func pause_game() -> void:
    is_paused = true
    get_tree().paused = true

func unpause_game() -> void:
    is_paused = false
    get_tree().paused = false

func reset_game_state() -> void:
    score = 0
    level = 1
    current_xp = 0
    required_xp = 10
    time_elapsed = 0.0
    is_paused = false
    enemies_alive = 0
    total_enemies_killed = 0

func _on_experience_gained(amount: int, current: int, required: int) -> void:
    # This could trigger UI updates or other side effects
    pass

func _on_enemy_killed(enemy: Node, xp_reward: int) -> void:
    enemies_alive -= 1
    total_enemies_killed += 1
    score += xp_reward
    gain_experience(xp_reward)

func get_game_stats() -> Dictionary:
    return {
        "score": score,
        "level": level,
        "time_elapsed": time_elapsed,
        "enemies_killed": total_enemies_killed,
        "current_xp": current_xp,
        "required_xp": required_xp
    }

func _auto_apply_test_upgrade() -> void:
    if not player:
        return
    for child in player.get_children():
        if child is BaseWeapon:
            var up := UpgradeData.new()
            up.id = "auto_projectile_up"
            up.target_weapon_name = child.weapon_data.name
            up.add_projectiles = 1
            child.apply_upgrade(up)
