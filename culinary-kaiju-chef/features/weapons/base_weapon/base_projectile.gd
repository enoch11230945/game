# features/weapons/base_weapon/base_projectile.gd
extends Area2D

@export var speed: float = 800.0
@export var damage: int = 10
var lifetime: float = 3.0 # in seconds

var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
    # Set collision layers as per todo.txt
    # Layer 4: player_weapons
    set_collision_layer_value(4, true)
    # Mask 3: enemies
    set_collision_mask_value(3, true)

    # Connect the area_entered signal to self
    self.area_entered.connect(_on_area_entered)

    # Start a timer to free the projectile after its lifetime expires
    var lifetime_timer = get_tree().create_timer(lifetime)
    lifetime_timer.timeout.connect(queue_free) # For now, just free it. Later, reclaim to pool.

func _physics_process(delta: float) -> void:
    # Move the projectile
    global_position += velocity * delta

func _on_area_entered(area: Area2D) -> void:
    # The area is the enemy's hurtbox
    if area.has_method("take_damage"):
        area.take_damage(damage)
    
    # The projectile should disappear after hitting an enemy
    queue_free() # For now, just free it. Later, reclaim to pool.
