extends Area2D

@onready var velocity_component = $VelocityComponent
@onready var health_component = $HealthComponent

func _ready():
	health_component.died.connect(on_died)

func _physics_process(delta):
    # Replace VelocityComponent with simple movement
    var player = get_tree().get_first_node_in_group("player")
    if player:
        var direction = (player.global_position - global_position).normalized()
        velocity = direction * 60.0  # Tank enemies are slower
        move_and_slide()

func on_died():
	EventBus.experience_gained.emit(15, global_position)
	# Tank enemies drop more XP
	EventBus.experience_gained.emit(10, global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10)))
	EventBus.experience_gained.emit(10, global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10)))
	queue_free()

func _on_area_entered(other_area: Area2D):
	health_component.damage(1)