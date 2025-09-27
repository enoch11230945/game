extends Node
class_name BossManager

@export var boss_enemy_scene: PackedScene
@export var arena_time_manager: ArenaTimeManager

@onready var boss_timer = Timer.new()

var boss_spawn_interval: float = 300.0  # 5 minutes
var has_spawned_boss: bool = false

func _ready():
	add_child(boss_timer)
	boss_timer.wait_time = boss_spawn_interval
	boss_timer.timeout.connect(_on_boss_timer_timeout)
	boss_timer.start()
	
	# Connect to boss defeat event
	if EventBus.has_signal("boss_defeated"):
		EventBus.boss_defeated.connect(_on_boss_defeated)

func _on_boss_timer_timeout():
	spawn_boss()
	boss_timer.wait_time = boss_spawn_interval  # Reset for next boss
	boss_timer.start()

func spawn_boss():
	if not boss_enemy_scene:
		return
		
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var boss = boss_enemy_scene.instantiate()
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	
	if entities_layer:
		entities_layer.add_child(boss)
		# Spawn boss at edge of screen
		var spawn_distance = 400
		var random_angle = randf() * TAU
		var spawn_offset = Vector2(cos(random_angle), sin(random_angle)) * spawn_distance
		boss.global_position = player.global_position + spawn_offset
		
		# Announce boss spawn
		EventBus.emit("boss_spawned")
		has_spawned_boss = true

func _on_boss_defeated():
	has_spawned_boss = false
	# Could add rewards, special effects, etc.