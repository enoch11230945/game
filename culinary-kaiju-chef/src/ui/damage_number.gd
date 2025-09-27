extends Control

@onready var label = $Label

func _ready():
	# Start animation
	animate_damage_number()

func setup(damage_amount: int, is_critical: bool = false):
	label.text = str(damage_amount)
	
	if is_critical:
		label.modulate = Color.YELLOW
		label.add_theme_font_size_override("font_size", 24)
	else:
		label.modulate = Color.WHITE
		label.add_theme_font_size_override("font_size", 18)

func animate_damage_number():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move upward
	tween.tween_property(self, "position", position + Vector2(randf_range(-20, 20), -60), 0.8)
	
	# Fade out
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.8)
	
	# Scale effect
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.6).set_delay(0.2)
	
	# Remove after animation
	tween.tween_callback(queue_free).set_delay(0.8)

func show_damage(damage_amount: int, world_position: Vector2, is_critical: bool = false):
	setup(damage_amount, is_critical)
	
	# Convert world position to screen position
	var camera = get_viewport().get_camera_2d()
	if camera:
		global_position = world_position