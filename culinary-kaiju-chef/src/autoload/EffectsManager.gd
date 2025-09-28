# EffectsManager.gd - Visual effects system for game juice
extends Node

# Effect pools for performance
var damage_number_pool: Array[Label] = []
var explosion_pool: Array[Control] = []
var flash_pool: Array[ColorRect] = []
var pool_size: int = 20
var current_damage_index: int = 0
var current_explosion_index: int = 0
var current_flash_index: int = 0

# Reference to main scene for adding effects
var main_scene: Node

func _ready() -> void:
	# Initialize effect pools
	_create_damage_number_pool()
	_create_explosion_pool()
	_create_flash_pool()
	
	# Connect to events
	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	
	print("EffectsManager initialized with pools")

func set_main_scene(scene: Node) -> void:
	main_scene = scene

func _create_damage_number_pool() -> void:
	for i in pool_size:
		var label = Label.new()
		label.name = "DamageNumber_%d" % i
		label.add_theme_font_size_override("font_size", 24)
		label.modulate = Color.RED
		label.z_index = 100
		label.visible = false
		damage_number_pool.append(label)

func _create_explosion_pool() -> void:
	for i in pool_size:
		var explosion = Control.new()
		explosion.name = "Explosion_%d" % i
		explosion.visible = false
		explosion_pool.append(explosion)

func _create_flash_pool() -> void:
	for i in pool_size:
		var flash = ColorRect.new()
		flash.name = "Flash_%d" % i
		flash.color = Color.WHITE
		flash.size = Vector2(100, 100)
		flash.visible = false
		flash_pool.append(flash)

func show_damage_number(position: Vector2, damage: int, color: Color = Color.RED) -> void:
	if not main_scene:
		return
	
	var label = damage_number_pool[current_damage_index]
	current_damage_index = (current_damage_index + 1) % pool_size
	
	# Setup label
	label.text = str(damage)
	label.modulate = color
	label.global_position = position
	label.visible = true
	
	# Add to scene if not already there
	if not label.get_parent():
		main_scene.add_child(label)
	
	# Animate
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move up and fade out
	var end_pos = position + Vector2(randf_range(-20, 20), -60)
	tween.tween_property(label, "global_position", end_pos, 0.8)
	tween.tween_property(label, "modulate", Color.TRANSPARENT, 0.8)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(label, "scale", Vector2.ONE, 0.7).set_delay(0.1)
	
	# Hide when done
	tween.finished.connect(func(): label.visible = false)

func show_explosion(position: Vector2, size: float = 1.0, color: Color = Color.ORANGE) -> void:
	if not main_scene:
		return
	
	var explosion = explosion_pool[current_explosion_index]
	current_explosion_index = (current_explosion_index + 1) % pool_size
	
	# Create explosion effect using multiple ColorRects
	explosion.position = position - Vector2(50, 50) * size
	explosion.scale = Vector2(size, size)
	explosion.visible = true
	
	# Clear previous children
	for child in explosion.get_children():
		child.queue_free()
	
	# Create explosion particles
	for i in range(8):
		var particle = ColorRect.new()
		particle.size = Vector2(20, 20)
		particle.color = color
		particle.position = Vector2.ZERO
		explosion.add_child(particle)
		
		# Animate particle outward
		var angle = (TAU / 8) * i
		var end_pos = Vector2.RIGHT.rotated(angle) * 80
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", end_pos, 0.6)
		tween.tween_property(particle, "modulate", Color.TRANSPARENT, 0.6)
		tween.tween_property(particle, "scale", Vector2.ZERO, 0.6)
	
	# Add to scene if not already there
	if not explosion.get_parent():
		main_scene.add_child(explosion)
	
	# Hide explosion after animation
	var cleanup_tween = create_tween()
	cleanup_tween.tween_callback(func(): explosion.visible = false).set_delay(0.7)

func screen_flash(color: Color = Color.WHITE, intensity: float = 0.3, duration: float = 0.1) -> void:
	if not main_scene:
		return
	
	var flash = flash_pool[current_flash_index]
	current_flash_index = (current_flash_index + 1) % pool_size
	
	# Setup full-screen flash
	flash.color = Color(color.r, color.g, color.b, intensity)
	flash.size = Vector2(2000, 2000)  # Large size to cover screen
	flash.position = Vector2(-1000, -1000)
	flash.z_index = 1000  # Above everything
	flash.visible = true
	
	# Add to scene if not already there
	if not flash.get_parent():
		main_scene.add_child(flash)
	
	# Fade out quickly
	var tween = create_tween()
	tween.tween_property(flash, "modulate", Color.TRANSPARENT, duration)
	tween.finished.connect(func(): 
		flash.visible = false
		flash.modulate = Color.WHITE
	)

func screen_shake(strength: float = 10.0, duration: float = 0.2) -> void:
	if not main_scene:
		return
	
	# Find camera
	var camera = _find_camera(main_scene)
	if not camera:
		return
	
	var original_offset = camera.offset
	var shake_tween = create_tween()
	
	# Shake effect
	var steps = int(duration / 0.02)  # 50 FPS shake
	for i in steps:
		var shake_offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		shake_tween.tween_property(camera, "offset", original_offset + shake_offset, 0.02)
	
	# Return to original position
	shake_tween.tween_property(camera, "offset", original_offset, 0.05)

func _find_camera(node: Node) -> Camera2D:
	if node is Camera2D:
		return node as Camera2D
	
	for child in node.get_children():
		var result = _find_camera(child)
		if result:
			return result
	
	return null

# Event handlers
func _on_damage_dealt() -> void:
	# This would need position parameter in real implementation
	pass

func _on_enemy_killed() -> void:
	# This would need position parameter in real implementation
	pass

func _on_player_leveled_up(level: int) -> void:
	screen_flash(Color.GOLD, 0.4, 0.3)
	screen_shake(15.0, 0.4)

# Public interface for direct effect calls
func damage_effect(position: Vector2, damage: int, is_critical: bool = false) -> void:
	var color = Color.YELLOW if is_critical else Color.RED
	var size = 1.5 if is_critical else 1.0
	
	show_damage_number(position, damage, color)
	if is_critical:
		screen_flash(Color.YELLOW, 0.2, 0.1)

func death_effect(position: Vector2, enemy_type: String = "default") -> void:
	var color = Color.ORANGE
	var size = 1.0
	
	match enemy_type:
		"tomato":
			color = Color.RED
			size = 1.2
		"onion":
			color = Color.PURPLE
			size = 0.8
	
	show_explosion(position, size, color)
	screen_shake(5.0, 0.1)

func pickup_effect(position: Vector2) -> void:
	show_damage_number(position, 0, Color.GREEN)  # Will show as "0" but green
	# Could show "+XP" instead with text modification