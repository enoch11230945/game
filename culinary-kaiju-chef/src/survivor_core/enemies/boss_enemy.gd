extends Area2D

@onready var velocity_component = $VelocityComponent
@onready var health_component = $HealthComponent
@onready var attack_timer = $AttackTimer

var attack_scenes = []  # Will hold different attack patterns

func _ready():
	health_component.died.connect(on_died)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)

func on_died():
	# Boss drops lots of XP
	for i in range(10):
		var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		GameEvents.emit_experience_vial_dropped(global_position + offset)
	
	# Signal boss defeat
	EventBus.emit("boss_defeated")
	queue_free()

func _on_area_entered(other_area: Area2D):
	health_component.damage(1)

func _on_attack_timer_timeout():
	# Spawn projectiles in a circle around the boss
	spawn_circular_attack()

func spawn_circular_attack():
	var projectile_count = 8
	var angle_step = TAU / projectile_count
	
	for i in range(projectile_count):
		var angle = i * angle_step
		var direction = Vector2(cos(angle), sin(angle))
		
		# Create a simple projectile (you might want to create a proper projectile scene)
		var projectile = preload("res://src/weapons/base_weapon/BaseProjectile.tscn").instantiate()
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = global_position
		projectile.direction = direction
		projectile.speed = 150.0