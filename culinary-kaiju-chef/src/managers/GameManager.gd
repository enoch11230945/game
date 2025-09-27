# GameManager.gd - SINGLE RESPONSIBILITY: Game State Only
extends Node

# === GAME STATE DATA ===
var game_time: float = 0.0
var is_paused: bool = false
var is_game_over: bool = false

func _ready() -> void:
    print("🎮 GameManager initialized - Game state management only")
    
    # Connect to main scene ready
    EventBus.main_scene_ready.connect(_on_main_scene_ready)
    EventBus.game_started.connect(_on_game_started)
    EventBus.player_died.connect(_on_player_died)

func _process(delta: float) -> void:
    if not is_paused and not is_game_over:
        game_time += delta

func _on_main_scene_ready() -> void:
    """Start game when main scene is loaded"""
    _start_game()

func _start_game() -> void:
    """Initialize new game state"""
    game_time = 0.0
    is_paused = false
    is_game_over = false
    
    EventBus.game_started.emit()
    print("🎯 Game started - State management active")

func _on_game_started() -> void:
    """Handle game start event"""
    # Game systems handle themselves, we just track state
    pass

func _on_player_died() -> void:
    """Handle player death"""
    is_game_over = true
    EventBus.game_over.emit(0, game_time)  # Systems calculate actual score
    print("💀 Game over - Final time: %.1fs" % game_time)

func pause_game() -> void:
    """Pause game state"""
    is_paused = true
    get_tree().paused = true
    EventBus.game_paused.emit(true)

func resume_game() -> void:
    """Resume game state"""
    is_paused = false
    get_tree().paused = false
    EventBus.game_paused.emit(false)