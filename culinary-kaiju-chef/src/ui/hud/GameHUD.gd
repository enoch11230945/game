# GameHUD.gd - Professional game HUD (Linus approved)
extends Control
class_name GameHUD

# === UI COMPONENTS ===
@onready var health_bar: ProgressBar = $VBox/HealthContainer/HealthBar
@onready var health_label: Label = $VBox/HealthContainer/HealthLabel
@onready var xp_bar: ProgressBar = $VBox/XPContainer/XPBar
@onready var level_label: Label = $VBox/XPContainer/LevelLabel
@onready var timer_label: Label = $VBox/TopContainer/TimerLabel
@onready var score_label: Label = $VBox/TopContainer/ScoreLabel
@onready var fps_label: Label = $VBox/DebugContainer/FPSLabel

# === STATE TRACKING ===
var game_start_time: float = 0.0

func _ready() -> void:
    print("🖥️ GameHUD initialized - Professional UI")
    
    # Connect to game events
    EventBus.player_health_changed.connect(_on_player_health_changed)
    EventBus.xp_gained.connect(_on_xp_gained)
    EventBus.player_level_up.connect(_on_player_level_up)
    EventBus.score_changed.connect(_on_score_changed)
    EventBus.game_started.connect(_on_game_started)
    
    # Initialize display
    _update_display()
    game_start_time = Time.get_ticks_msec() / 1000.0

func _process(delta: float) -> void:
    # Update timer
    var elapsed_time = (Time.get_ticks_msec() / 1000.0) - game_start_time
    var minutes = int(elapsed_time / 60)
    var seconds = int(elapsed_time) % 60
    timer_label.text = "%02d:%02d" % [minutes, seconds]
    
    # Update FPS (debug info)
    fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _update_display() -> void:
    """Update all display elements"""
    _update_health_display()
    _update_xp_display()
    _update_level_display()
    _update_score_display()

func _update_health_display() -> void:
    """Update health bar and label"""
    if health_bar and health_label:
        var current_health = Game.get_player_health()
        var max_health = Game.get_player_max_health()
        
        health_bar.value = (float(current_health) / float(max_health)) * 100.0
        health_label.text = "%d / %d" % [current_health, max_health]
        
        # Color coding based on health percentage
        var health_percent = float(current_health) / float(max_health)
        if health_percent > 0.6:
            health_bar.modulate = Color.GREEN
        elif health_percent > 0.3:
            health_bar.modulate = Color.YELLOW
        else:
            health_bar.modulate = Color.RED

func _update_xp_display() -> void:
    """Update XP bar"""
    if xp_bar:
        var current_xp = Game.current_xp
        var required_xp = Game.xp_required
        
        if required_xp > 0:
            xp_bar.value = (float(current_xp) / float(required_xp)) * 100.0
        else:
            xp_bar.value = 0.0

func _update_level_display() -> void:
    """Update level label"""
    if level_label:
        level_label.text = "LV %d" % Game.player_level

func _update_score_display() -> void:
    """Update score label"""
    if score_label:
        score_label.text = "Score: %d" % Game.score

# === EVENT HANDLERS ===

func _on_player_health_changed(current: int, max_health: int) -> void:
    """Handle player health change"""
    _update_health_display()

func _on_xp_gained(amount: int) -> void:
    """Handle XP gain"""
    _update_xp_display()

func _on_player_level_up(new_level: int) -> void:
    """Handle level up"""
    _update_level_display()
    _update_xp_display()
    
    # Show level up effect
    _show_level_up_effect()

func _on_score_changed(new_score: int) -> void:
    """Handle score change"""
    _update_score_display()

func _on_game_started() -> void:
    """Handle game start"""
    game_start_time = Time.get_ticks_msec() / 1000.0
    _update_display()

func _show_level_up_effect() -> void:
    """Show visual feedback for level up"""
    if level_label:
        # Scale animation
        var original_scale = level_label.scale
        var tween = create_tween()
        tween.set_parallel(true)
        tween.tween_property(level_label, "scale", original_scale * 1.3, 0.2)
        tween.tween_property(level_label, "modulate", Color.YELLOW, 0.2)
        tween.tween_delay(0.3)
        tween.tween_property(level_label, "scale", original_scale, 0.2)
        tween.tween_property(level_label, "modulate", Color.WHITE, 0.2)

# === PUBLIC API ===

func show_damage_taken() -> void:
    """Show visual feedback for damage taken"""
    # Red screen flash
    var flash = ColorRect.new()
    flash.color = Color(1, 0, 0, 0.3)
    flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(flash)
    
    var tween = create_tween()
    tween.tween_property(flash, "modulate", Color.TRANSPARENT, 0.3)
    tween.tween_callback(flash.queue_free)

func show_healing_received() -> void:
    """Show visual feedback for healing"""
    # Green screen flash
    var flash = ColorRect.new()
    flash.color = Color(0, 1, 0, 0.2)
    flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(flash)
    
    var tween = create_tween()
    tween.tween_property(flash, "modulate", Color.TRANSPARENT, 0.3)
    tween.tween_callback(flash.queue_free)