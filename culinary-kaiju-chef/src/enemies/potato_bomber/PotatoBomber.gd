# PotatoBomber.gd - 土豆炸彈敵人，死亡時會爆炸
extends BaseEnemy
class_name PotatoBomber

func die() -> void:
	# 播放爆炸音效
	AudioManager.play_sfx("impactMining_003", 1.2)
	
	# 爆炸邏輯：對範圍內的玩家和其他敵人造成傷害
	explode()
	
	# 正常的死亡流程
	super.die()

func explode():
	if not data:
		return
		
	# 創建爆炸範圍查詢
	var space_state = get_world_2d().direct_space_state
	var explosion_shape = CircleShape2D.new()
	explosion_shape.radius = data.explosion_radius
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape_rid = explosion_shape.get_rid()
	query.transform = global_transform
	query.collision_mask = 0b00000110  # 檢測玩家和敵人層
	
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var target = result.get("collider")
		if is_instance_valid(target) and target != self:
			if target.is_in_group("player"):
				# 對玩家造成爆炸傷害
				EventBus.player_hit.emit(data.explosion_damage)
			elif target.has_method("take_damage"):
				# 對其他敵人也造成傷害（連鎖爆炸效果）
				target.take_damage(data.explosion_damage / 2)
	
	# 創建視覺爆炸效果（如果有粒子系統的話）
	create_explosion_effect()

func create_explosion_effect():
	# 簡單的爆炸效果：放大並淡出
	if sprite:
		var tween = create_tween()
		tween.parallel().tween_property(sprite, "scale", sprite.scale * 2.0, 0.2)
		tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.2)