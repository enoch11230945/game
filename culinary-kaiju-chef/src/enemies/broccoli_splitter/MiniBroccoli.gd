# MiniBroccoli.gd - 小青花菜（分裂產物）
extends BaseEnemy
class_name MiniBroccoli

func initialize_as_split(split_health: int, split_speed: float):
	"""初始化為分裂產物"""
	self.health = split_health
	self.speed = split_speed
	
	# 設置視覺屬性（更小的尺寸）
	if sprite:
		sprite.scale = Vector2(0.5, 0.5)
		sprite.modulate = Color.GREEN * 0.8
	
	# 找到玩家目標
	target = get_tree().get_first_node_in_group("player")
	
	# 添加到敵人組
	add_to_group("enemies")
	
	# 啟動處理
	set_physics_process(true)
	show()

func die() -> void:
	# 小青花菜死亡時只給少量經驗
	if xp_gem_scene:
		var gem = ObjectPool.request(xp_gem_scene)
		var collect_layer = get_tree().get_first_node_in_group("collectables_layer")
		if collect_layer:
			collect_layer.add_child(gem)
		else:
			get_tree().get_root().add_child(gem)
		gem.global_position = self.global_position
		
		if gem.has_method("initialize"):
			gem.initialize(2)  # 只給2點經驗
	
	# 通知遊戲系統
	EventBus.enemy_killed.emit(self, 2)
	Game.score += 2
	
	# 播放死亡音效
	AudioManager.play_enemy_death()
	
	# 回收到物件池
	ObjectPool.reclaim(self)