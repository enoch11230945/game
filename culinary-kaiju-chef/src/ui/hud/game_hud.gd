extends Control

# 游戏内HUD界面
# Removed conflicting class_name GameHUD

@onready var health_bar: ProgressBar = $TopBar/HealthBar
@onready var experience_bar: ProgressBar = $TopBar/ExperienceBar
@onready var timer_label: Label = $TopBar/TimerLabel
@onready var level_label: Label = $TopBar/LevelLabel
@onready var kill_count_label: Label = $TopBar/KillCountLabel

# UI数值
var current_health: int = 100
var max_health: int = 100
var current_experience: int = 0
var experience_to_next_level: int = 100
var current_level: int = 1
var game_time: float = 0.0
var kill_count: int = 0

func _ready():
	# 初始化HUD
	_update_health_bar()
	_update_experience_bar()
	_update_level_display()
	_update_kill_count()
	_update_timer()

func _process(delta):
	# 更新游戏时间
	game_time += delta
	_update_timer()

# 更新生命值显示
func update_health(health: int, max_hp: int):
	current_health = health
	max_health = max_hp
	_update_health_bar()

func _update_health_bar():
	if health_bar:
		health_bar.value = (float(current_health) / float(max_health)) * 100
		health_bar.get_child(0).text = str(current_health) + "/" + str(max_health)

# 更新经验值显示
func update_experience(exp: int, exp_needed: int):
	current_experience = exp
	experience_to_next_level = exp_needed
	_update_experience_bar()

func _update_experience_bar():
	if experience_bar:
		experience_bar.value = (float(current_experience) / float(experience_to_next_level)) * 100

# 更新等级显示
func update_level(level: int):
	current_level = level
	_update_level_display()

func _update_level_display():
	if level_label:
		level_label.text = "Lv." + str(current_level)

# 更新击杀计数
func update_kill_count(count: int):
	kill_count = count
	_update_kill_count()

func _update_kill_count():
	if kill_count_label:
		kill_count_label.text = "击杀: " + str(kill_count)

# 更新计时器
func _update_timer():
	if timer_label:
		var minutes = int(game_time) / 60
		var seconds = int(game_time) % 60
		timer_label.text = "%02d:%02d" % [minutes, seconds]

# 显示伤害数字（可选功能）
func show_damage_number(damage: int, position: Vector2, is_critical: bool = false):
	var damage_label = Label.new()
	damage_label.text = str(damage)
	damage_label.position = position
	
	# 设置伤害数字样式
	if is_critical:
		damage_label.add_theme_color_override("font_color", Color.RED)
		damage_label.add_theme_font_size_override("font_size", 24)
	else:
		damage_label.add_theme_color_override("font_color", Color.WHITE)
		damage_label.add_theme_font_size_override("font_size", 18)
	
	add_child(damage_label)
	
	# 动画效果
	var tween = create_tween()
	tween.parallel().tween_property(damage_label, "position", position + Vector2(0, -50), 1.0)
	tween.parallel().tween_property(damage_label, "modulate", Color.TRANSPARENT, 1.0)
	tween.tween_callback(damage_label.queue_free)

# 显示治疗数字
func show_heal_number(heal: int, position: Vector2):
	var heal_label = Label.new()
	heal_label.text = "+" + str(heal)
	heal_label.position = position
	heal_label.add_theme_color_override("font_color", Color.GREEN)
	heal_label.add_theme_font_size_override("font_size", 18)
	
	add_child(heal_label)
	
	# 动画效果
	var tween = create_tween()
	tween.parallel().tween_property(heal_label, "position", position + Vector2(0, -30), 0.8)
	tween.parallel().tween_property(heal_label, "modulate", Color.TRANSPARENT, 0.8)
	tween.tween_callback(heal_label.queue_free)