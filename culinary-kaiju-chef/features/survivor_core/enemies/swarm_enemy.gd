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
        velocity = direction * 120.0  # Swarm enemies are faster
        move_and_slide()

func on_died():
	EventBus.experience_gained.emit(5, global_position)
	queue_free()

func _on_area_entered(other_area: Area2D):
	health_component.damage(1)