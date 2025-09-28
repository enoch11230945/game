# BossManager.gd - Epic 1.4 Boss战系统实现
# Linus principle: "Data-driven boss mechanics"
extends Node
class_name BossManager

# Boss数据库 - 数据驱动设计
var boss_data: Array[Dictionary] = [
	{
		"name": "Iron Chef Golem",
		"health": 500,
		"speed": 40.0,
		"damage": 25,
		"size_scale": 2.0,
		"spawn_time": 300.0,  # 5分钟
		"abilities": ["slam_attack", "minion_spawn"],
		"xp_reward": 100,
		"description": "巨大的厨具魔像，会召唤小型厨具攻击玩家"
	},
	{
		"name": "Dragon Chef Supreme",
		"health": 800, 
		"speed": 60.0,
		"damage": 35,
		"size_scale": 2.5,
		"spawn_time": 600.0,  # 10分钟
		"abilities": ["fire_breath", "charge_attack", "heal_minions"],
		"xp_reward": 200,
		"description": "终极厨师龙，拥有火焰吐息和治疗能力"
	}
]

var active_boss: Area2D = null
var boss_spawn_timer: float = 0.0
var next_boss_index: int = 0

# 检查是否该生成Boss
func _process(delta: float) -> void:
	if active_boss != null:
		return  # Boss还活着
		
	boss_spawn_timer += delta
	
	if next_boss_index < boss_data.size():
		var boss_info = boss_data[next_boss_index]
		if boss_spawn_timer >= boss_info.spawn_time:
			spawn_boss(boss_info)
			next_boss_index += 1

# 生成Boss
func spawn_boss(boss_info: Dictionary) -> void:
	print("🐉 BOSS INCOMING: ", boss_info.name, "!")
	
	# 创建Boss节点
	active_boss = Area2D.new()
	active_boss.name = boss_info.name
	active_boss.collision_layer = 4  # enemies
	active_boss.collision_mask = 8   # player_weapons
	
	# 添加Boss组件
	_setup_boss_visual(active_boss, boss_info)
	_setup_boss_collision(active_boss, boss_info)
	_setup_boss_behavior(active_boss, boss_info)
	
	# 添加到场景
	get_tree().current_scene.add_child(active_boss)
	
	# 设置Boss位置 (在玩家附近但不重叠)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var spawn_pos = player.global_position + Vector2(300, 200)
		active_boss.global_position = spawn_pos
	
	# 发布Boss出现事件
	EventBus.emit_signal("boss_spawned", active_boss, boss_info)

func _setup_boss_visual(boss: Area2D, boss_info: Dictionary) -> void:
	# 创建Boss视觉
	var sprite = ColorRect.new()
	sprite.size = Vector2(100, 100) * boss_info.size_scale
	sprite.position = -sprite.size / 2
	sprite.color = Color(0.8, 0.2, 0.2)  # 深红色Boss
	boss.add_child(sprite)
	
	# Boss标记
	var label = Label.new()
	label.text = boss_info.name
	label.position = Vector2(-50, -120) * boss_info.size_scale
	label.add_theme_color_override("font_color", Color.RED)
	boss.add_child(label)

func _setup_boss_collision(boss: Area2D, boss_info: Dictionary) -> void:
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 50 * boss_info.size_scale
	collision.shape = shape
	boss.add_child(collision)

func _setup_boss_behavior(boss: Area2D, boss_info: Dictionary) -> void:
	# 设置Boss数据
	boss.set_meta("boss_data", boss_info)
	boss.set_meta("health", boss_info.health)
	boss.set_meta("max_health", boss_info.health)
	boss.set_meta("speed", boss_info.speed)
	boss.set_meta("damage", boss_info.damage)
	boss.set_meta("last_ability_time", 0.0)
	
	# 添加Boss组
	boss.add_to_group("bosses")
	boss.add_to_group("enemies")
	
	# 连接受伤事件
	boss.area_entered.connect(_on_boss_hit_by_weapon.bind(boss))

func _on_boss_hit_by_weapon(boss: Area2D, weapon_area: Area2D) -> void:
	if not weapon_area.has_meta("damage"):
		return
		
	var damage = weapon_area.get_meta("damage", 10)
	var current_health = boss.get_meta("health", 0)
	var new_health = current_health - damage
	
	boss.set_meta("health", new_health)
	
	print("Boss health: ", new_health, "/", boss.get_meta("max_health"))
	
	# Boss击中特效
	_boss_hit_effect(boss)
	
	if new_health <= 0:
		_boss_defeated(boss)

func _boss_hit_effect(boss: Area2D) -> void:
	# 简单的击中闪烁
	var sprite = boss.get_child(0)  # 假设第一个子节点是sprite
	if sprite:
		sprite.modulate = Color.WHITE
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(0.8, 0.2, 0.2), 0.1)

func _boss_defeated(boss: Area2D) -> void:
	var boss_info = boss.get_meta("boss_data")
	print("🎉 BOSS DEFEATED: ", boss_info.name, "!")
	
	# 掉落大量经验
	EventBus.emit_signal("enemy_killed", boss, boss_info.xp_reward)
	
	# Boss死亡特效 (爆炸)
	_create_boss_death_effect(boss.global_position)
	
	# 清理Boss引用
	active_boss = null
	boss.queue_free()

func _create_boss_death_effect(pos: Vector2) -> void:
	# 创建爆炸效果
	for i in range(10):
		var particle = ColorRect.new()
		particle.size = Vector2(20, 20)
		particle.color = Color(1, 0.8, 0.2)  # 金色爆炸
		particle.global_position = pos + Vector2(randf_range(-100, 100), randf_range(-100, 100))
		
		get_tree().current_scene.add_child(particle)
		
		# 爆炸粒子动画
		var tween = create_tween()
		tween.parallel().tween_property(particle, "modulate:a", 0.0, 1.0)
		tween.parallel().tween_property(particle, "scale", Vector2(2, 2), 1.0)
		tween.tween_callback(particle.queue_free)

# 获取当前Boss信息 (供UI使用)
func get_current_boss_info() -> Dictionary:
	if active_boss:
		return active_boss.get_meta("boss_data", {})
	return {}

# 获取下一个Boss倒计时
func get_next_boss_countdown() -> float:
	if next_boss_index < boss_data.size():
		return boss_data[next_boss_index].spawn_time - boss_spawn_timer
	return -1  # 没有更多Boss了