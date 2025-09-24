# src/ui/hud/HUD.gd
extends CanvasLayer

@onready var health_label = $Control/TopLeftContainer/HealthLabel
@onready var score_label = $Control/TopLeftContainer/ScoreLabel
@onready var wave_label = $Control/TopLeftContainer/WaveLabel
@onready var fps_label = $Control/TopLeftContainer/FPSLabel

var player: CharacterBody2D = null
var score: int = 0
var current_wave: int = 1
var last_health: int = 100

func _ready():
    # Find the player
    player = get_tree().get_first_node_in_group("player")
    if player:
        print("🎮 HUD connected to player")
    else:
        print("⚠️ HUD: Player not found")

    # Connect to game events (safe connection)
    if Game:
        if Game.has_signal("score_changed"):
            Game.connect("score_changed", _on_score_changed)
        if Game.has_signal("level_up"):
            Game.connect("level_up", _on_level_up)

    update_display()

func _process(_delta):
    # Update FPS display
    fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

    # Simple health display for now - no player property access
    health_label.text = "Health: 100/100"

func update_display():
    """Update all HUD displays"""
    health_label.text = "Health: 100/100"
    score_label.text = "Score: " + str(score)
    wave_label.text = "Wave: " + str(current_wave)
    fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func _on_score_changed(new_score: int):
    """Called when score changes"""
    score = new_score
    score_label.text = "Score: " + str(score)

func _on_level_up():
    """Called when player levels up"""
    current_wave += 1
    wave_label.text = "Wave: " + str(current_wave)

func set_score(new_score: int):
    """Set score from external systems"""
    score = new_score
    update_display()

func set_wave(wave_number: int):
    """Set wave number from external systems"""
    current_wave = wave_number
    update_display()
