# PhysicsHelper.gd - 修复physics查询冲突的工具类
# Linus principle: "Fix the root cause, not the symptom"
extends Node

# 安全地设置Area2D状态，避免physics查询冲突
static func safe_set_area_monitoring(area: Area2D, enabled: bool) -> void:
	if area and is_instance_valid(area):
		area.call_deferred("set_monitoring", enabled)

static func safe_set_shape_disabled(collision: CollisionShape2D, disabled: bool) -> void:
	if collision and is_instance_valid(collision):
		collision.call_deferred("set_disabled", disabled)

# 安全地创建并添加节点到场景
static func safe_spawn_node(parent: Node, scene: PackedScene, spawn_pos: Vector2) -> Node:
	var instance = scene.instantiate()
	parent.call_deferred("add_child", instance)
	instance.call_deferred("set_global_position", spawn_pos)
	return instance

# 安全地从ObjectPool获取并设置节点
static func safe_pool_spawn(parent: Node, scene: PackedScene, spawn_pos: Vector2) -> Node:
	var instance = ObjectPool.request(scene)
	parent.call_deferred("add_child", instance)
	instance.call_deferred("set_global_position", spawn_pos)
	return instance