# XPGem.gd
extends Area2D
class_name XPGem

@export var experience_value: int = 5

var target: Node2D = null
var collection_speed: float = 200.0
var is_collecting: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
    # Connect collection trigger
    area_entered.connect(_on_area_entered)
    
    # Add to collectables group
    add_to_group("collectables")

func initialize(xp_amount: int) -> void:
    experience_value = xp_amount
    
    # Visual feedback based on XP value
    var scale_factor = 1.0 + (xp_amount / 50.0) # Larger gems for more XP
    sprite.scale = Vector2(scale_factor, scale_factor)
    
    # Color coding
    if xp_amount >= 20:
        sprite.modulate = Color.GOLD
    elif xp_amount >= 10:
        sprite.modulate = Color.CYAN
    else:
        sprite.modulate = Color.BLUE
    
    show()

func _physics_process(delta: float) -> void:
    if is_collecting and is_instance_valid(target):
        # Move towards player with acceleration
        var distance = global_position.distance_to(target.global_position)
        if distance < 10:
            collect()
        else:
            var direction = (target.global_position - global_position).normalized()
            global_position += direction * collection_speed * delta
            collection_speed += 300 * delta # Accelerate towards player

func _on_area_entered(area: Area2D) -> void:
    # Check if this is the player's collector
    var parent = area.get_parent()
    if parent and parent.is_in_group("player"):
        target = parent
        is_collecting = true

func collect() -> void:
    # Give experience to game system
    Game.gain_experience(experience_value)
    
    # Optional: spawn collection effect
    _spawn_collection_effect()
    
    # Return to pool
    ObjectPool.reclaim(self)

func _spawn_collection_effect() -> void:
    # Could spawn a small particle effect or number popup
    # For now, just a simple flash
    pass

func reset_state() -> void:
    # Reset for object pooling
    experience_value = 5
    target = null
    is_collecting = false
    collection_speed = 200.0
    
    if sprite:
        sprite.scale = Vector2.ONE
        sprite.modulate = Color.BLUE