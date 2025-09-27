extends Node2D

@export var orbital_radius: float = 80.0
@export var rotation_speed: float = 2.0
@export var damage: float = 10.0

@onready var hitbox_component = $HitboxComponent
@onready var sprite = $Sprite2D

var current_angle: float = 0.0
var player: Node2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	hitbox_component.area_entered.connect(_on_hitbox_area_entered)

func _process(delta):
	if not player:
		return
		
	current_angle += rotation_speed * delta
	
	var offset = Vector2(cos(current_angle), sin(current_angle)) * orbital_radius
	global_position = player.global_position + offset
	
	# Rotate sprite to face movement direction
	sprite.rotation = current_angle

func _on_hitbox_area_entered(area: Area2D):
	if area.has_method("damage"):
		area.damage(damage)

func _on_rotation_timer_timeout():
	# Additional smooth rotation if needed
	pass