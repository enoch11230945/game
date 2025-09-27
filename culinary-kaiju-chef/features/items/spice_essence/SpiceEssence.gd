# SpiceEssence.gd - Delicious spice essence dropped by chopped ingredients
extends Area2D
class_name SpiceEssence

@export var xp_value: int = 5
var collection_speed: float = 100.0
var target: Node2D = null
var is_collecting: bool = false

@onready var sprite: Node2D = $SpiceSprite

func _ready():
    add_to_group("collectables")
    area_entered.connect(_on_area_entered)

func initialize_spice(value: int):
    xp_value = value
    
    # Different colors for different values
    var spice_color = Color.YELLOW
    if value >= 15:
        spice_color = Color.GOLD
    elif value >= 10:
        spice_color = Color.ORANGE
    
    if sprite:
        sprite.modulate = spice_color
        # Larger spice for more value
        var scale_factor = 1.0 + (value / 20.0)
        sprite.scale = Vector2(scale_factor, scale_factor)
    
    show()

func _physics_process(delta: float):
    if is_collecting and is_instance_valid(target):
        var distance = global_position.distance_to(target.global_position)
        if distance < 20:
            collect()
        else:
            var direction = (target.global_position - global_position).normalized()
            global_position += direction * collection_speed * delta
            collection_speed += 150 * delta  # Accelerate toward chef

func _on_area_entered(area: Area2D):
    # Check if this is the chef's collector
    var parent = area.get_parent()
    if parent and parent.is_in_group("player"):
        target = parent
        is_collecting = true

func collect():
    print("⭐ Chef collects delicious spice essence! +%d culinary power!" % xp_value)
    
    # Give XP to game system
    if Game:
        Game.gain_experience(xp_value)
    
    # Return to pool or free
    if ObjectPool:
        ObjectPool.reclaim(self)
    else:
        queue_free()

func reset_state():
    """Reset for object pooling"""
    xp_value = 5
    target = null
    is_collecting = false
    collection_speed = 100.0
    
    if sprite:
        sprite.scale = Vector2.ONE
        sprite.modulate = Color.YELLOW