# features/items/xp_gem/xp_gem.gd
extends Area2D

var experience_amount: int = 5
var speed: float = 100.0
var acceleration: float = 2.5

var target: Node2D = null

@onready var pickup_radius = $PickupRadius

func _ready():
    # The main area detects the player for collection
    self.area_entered.connect(_on_area_entered)
    # The pickup radius detects the player to start homing in
    pickup_radius.area_entered.connect(_on_pickup_radius_area_entered)

func _physics_process(delta: float):
    if is_instance_valid(target):
        # Move towards the player
        var direction = (target.global_position - self.global_position).normalized()
        speed += acceleration
        global_position += direction * speed * delta

func _on_area_entered(area: Area2D):
    # This assumes the player has an area for collecting items
    if area.is_in_group("player_pickup_area"):
        Game.add_experience(experience_amount)
        # For now, just free. Later, reclaim to pool.
        queue_free()

func _on_pickup_radius_area_entered(area: Area2D):
    if area.is_in_group("player_pickup_area"):
        # Once a target is acquired, we don't need the pickup radius anymore
        target = area
        pickup_radius.queue_free() # Optimization