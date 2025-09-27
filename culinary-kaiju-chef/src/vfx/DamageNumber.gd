# DamageNumber.gd - Floating damage numbers (ObjectPool compatible)
extends Control
class_name DamageNumber

@onready var label: Label = $Label
var move_speed: float = 100.0
var fade_duration: float = 1.5

func initialize(pos: Vector2, damage_value: int, color: Color = Color.WHITE) -> void:
    """Initialize damage number with position and value"""
    global_position = pos
    
    # Set damage text
    label.text = str(damage_value)
    label.modulate = color
    
    # Scale based on damage value
    var scale_factor = 1.0 + (damage_value / 100.0)
    scale = Vector2(scale_factor, scale_factor)
    
    # Start animation
    _animate_damage_number()

func _animate_damage_number() -> void:
    """Animate floating and fading"""
    var tween = create_tween()
    tween.set_parallel(true)
    
    # Float upward
    tween.tween_property(self, "global_position", global_position + Vector2(0, -move_speed), fade_duration)
    
    # Fade out
    tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_duration)
    
    # Return to pool when done
    tween.tween_callback(_return_to_pool)

func _return_to_pool() -> void:
    """Return to object pool"""
    ObjectPool.return_damage_number(self)

func reset() -> void:
    """Reset for object pool reuse"""
    modulate = Color.WHITE
    scale = Vector2.ONE
    if label:
        label.text = "0"
        label.modulate = Color.WHITE