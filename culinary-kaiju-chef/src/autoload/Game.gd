# Game.gd
extends Node

# 遊戲狀態
var current_score: int = 0
var current_level: int = 1
var game_time: float = 0.0
var is_paused: bool = false
var is_game_over: bool = false

# 遊戲參數
@export var max_game_time: float = 1800.0  # 30分鐘

func _ready() -> void:
    # 連接事件總線
    EventBus.enemy_died.connect(_on_enemy_died)
    EventBus.game_paused.connect(_on_game_paused)
    EventBus.game_resumed.connect(_on_game_resumed)

func _process(delta: float) -> void:
    if is_game_over or is_paused:
        return

    game_time += delta

    # 檢查遊戲時間限制
    if game_time >= max_game_time:
        _end_game(true)  # 勝利

func _on_enemy_died(position: Vector2, xp_value: int) -> void:
    current_score += xp_value

func _on_game_paused() -> void:
    is_paused = true

func _on_game_resumed() -> void:
    is_paused = false

func pause_game() -> void:
    EventBus.emit_game_paused()
    get_tree().paused = true

func resume_game() -> void:
    EventBus.emit_game_resumed()
    get_tree().paused = false

func _end_game(victory: bool = false) -> void:
    is_game_over = true
    get_tree().paused = true

    if victory:
        EventBus.emit_game_victory()
    else:
        EventBus.emit_game_over()

func reset_game() -> void:
    current_score = 0
    current_level = 1
    game_time = 0.0
    is_paused = false
    is_game_over = false
    get_tree().paused = false

func get_game_stats() -> Dictionary:
    return {
        "score": current_score,
        "level": current_level,
        "time": game_time,
        "is_paused": is_paused,
        "is_game_over": is_game_over
    }
