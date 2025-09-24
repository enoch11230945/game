# xp_gem.gd
extends Area2D
class_name XPGem

@export var experience_amount: int = 1

var target: Node2D
var speed: float = 100.0
var collecting: bool = false

func _ready() -> void:
    # When the player's collection area enters, start moving towards the player.
    # This assumes the player has a child Area2D for collection.
    area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
    if collecting and is_instance_valid(target):
        global_position = global_position.move_toward(target.global_position, speed * delta)
        speed += 200 * delta # Accelerate towards player
        # Check for collection
        if global_position.distance_to(target.global_position) < 10:
            collect()

func _on_area_entered(area: Area2D) -> void:
    # The player's gem collector area is expected to be on a specific collision layer/group
    # For now, we just check for a parent with the Player class_name
    if area.get_parent() is Player:
        target = area.get_parent()
        collecting = true

func collect() -> void:
    Game.gain_experience(experience_amount)
    ObjectPool.reclaim(self)

func reset_state() -> void:
    collecting = false
    target = null
    speed = 100.0
