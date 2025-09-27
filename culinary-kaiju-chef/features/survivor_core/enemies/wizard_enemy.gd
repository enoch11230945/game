extends Area2D

@onready var velocity_component = $VelocityComponent
@onready var health_component = $HealthComponent

func _ready():
	health_component.died.connect(on_died)

func _physics_process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)

func on_died():
	GameEvents.emit_experience_vial_dropped(global_position)
	queue_free()

func _on_area_entered(other_area: Area2D):
	health_component.damage(1)