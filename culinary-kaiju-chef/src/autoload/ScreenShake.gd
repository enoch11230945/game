extends Node

var camera: Camera2D
var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0

func _ready():
	# Find the camera when ready
	call_deferred("find_camera")

func find_camera():
	camera = get_viewport().get_camera_2d()

func _process(delta):
	if shake_timer > 0 and camera:
		shake_timer -= delta
		
		# Calculate shake offset
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		
		camera.offset = shake_offset
		
		# Reduce intensity over time
		shake_intensity = lerp(shake_intensity, 0.0, delta * 5.0)
		
		if shake_timer <= 0:
			camera.offset = Vector2.ZERO
			shake_intensity = 0.0

func shake(intensity: float, duration: float):
	if not camera:
		find_camera()
	
	shake_intensity = max(shake_intensity, intensity)
	shake_timer = max(shake_timer, duration)

# Convenience functions for different shake types
func light_shake():
	shake(3.0, 0.2)

func medium_shake():
	shake(8.0, 0.4)

func heavy_shake():
	shake(15.0, 0.6)