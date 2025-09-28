# game_hud.gd - Game HUD displaying player stats
extends CanvasLayer
class_name GameHUD

# UI Elements
@onready var health_bar: ProgressBar
@onready var xp_bar: ProgressBar
@onready var level_label: Label
@onready var timer_label: Label
@onready var kills_label: Label

# Stats
var current_health: int = 100
var max_health: int = 100
var current_xp: int = 0
var required_xp: int = 100
var level: int = 1
var game_time: float = 0.0
var kills: int = 0

func _ready() -> void:
	# Create UI elements dynamically for now
	_create_hud_elements()
	
	# Connect to EventBus signals
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.player_experience_gained.connect(_on_xp_gained)
	EventBus.player_leveled_up.connect(_on_level_up)
	EventBus.enemy_killed.connect(_on_enemy_killed)
	
	print("GameHUD initialized")

func _create_hud_elements() -> void:
	# Top panel for stats
	var top_panel = Panel.new()
	top_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top_panel.size.y = 60
	add_child(top_panel)
	
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 20)
	top_panel.add_child(hbox)
	
	# Health
	var health_container = VBoxContainer.new()
	hbox.add_child(health_container)
	
	var health_title = Label.new()
	health_title.text = "Health"
	health_container.add_child(health_title)
	
	health_bar = ProgressBar.new()
	health_bar.custom_minimum_size = Vector2(150, 20)
	health_bar.value = 100
	health_container.add_child(health_bar)
	
	# XP
	var xp_container = VBoxContainer.new()
	hbox.add_child(xp_container)
	
	var xp_title = Label.new()
	xp_title.text = "Experience"
	xp_container.add_child(xp_title)
	
	xp_bar = ProgressBar.new()
	xp_bar.custom_minimum_size = Vector2(200, 20)
	xp_bar.value = 0
	xp_container.add_child(xp_bar)
	
	# Level
	level_label = Label.new()
	level_label.text = "Level: 1"
	level_label.add_theme_font_size_override("font_size", 24)
	hbox.add_child(level_label)
	
	# Timer
	timer_label = Label.new()
	timer_label.text = "Time: 0:00"
	timer_label.add_theme_font_size_override("font_size", 18)
	hbox.add_child(timer_label)
	
	# Kills
	kills_label = Label.new()
	kills_label.text = "Kills: 0"
	kills_label.add_theme_font_size_override("font_size", 18)
	hbox.add_child(kills_label)

func _process(delta: float) -> void:
	game_time += delta
	_update_timer()

func _update_timer() -> void:
	var minutes = int(game_time) / 60
	var seconds = int(game_time) % 60
	timer_label.text = "Time: %d:%02d" % [minutes, seconds]

func _on_health_changed(health: int, max_hp: int) -> void:
	current_health = health
	max_health = max_hp
	health_bar.max_value = max_health
	health_bar.value = current_health

func _on_xp_gained(_xp: int, total_xp: int, required: int) -> void:
	current_xp = total_xp
	required_xp = required
	xp_bar.max_value = required_xp
	xp_bar.value = current_xp

func _on_level_up(new_level: int) -> void:
	level = new_level
	level_label.text = "Level: %d" % level
	current_xp = 0
	xp_bar.value = 0

func _on_enemy_killed() -> void:
	kills += 1
	kills_label.text = "Kills: %d" % kills

# Public methods to update stats directly (for current main.tscn script)
func update_stats(health: int, max_hp: int, xp: int, req_xp: int, player_level: int, kill_count: int) -> void:
	current_health = health
	max_health = max_hp
	current_xp = xp
	required_xp = req_xp
	level = player_level
	kills = kill_count
	
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
	
	if xp_bar:
		xp_bar.max_value = required_xp
		xp_bar.value = current_xp
	
	if level_label:
		level_label.text = "Level: %d" % level
	
	if kills_label:
		kills_label.text = "Kills: %d" % kills