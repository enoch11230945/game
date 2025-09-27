# BroccoliSplitter.gd - 青花菜分裂者，死亡時分裂成多個小敵人
extends BaseEnemy
class_name BroccoliSplitter

# 小青花菜場景
var mini_broccoli_scene: PackedScene

func _ready() -> void:
	super._ready()
	# 預載小青花菜場景
	mini_broccoli_scene = preload("res://src/enemies/broccoli_splitter/MiniBroccoli.tscn")

func die() -> void:
	# 播放分裂音效
	AudioManager.play_sfx("impactMining_004", 0.9)
	
	# 分裂邏輯
	split_into_mini_broccoli()
	
	# 正常的死亡流程
	super.die()

func split_into_mini_broccoli():
	if not data or not mini_broccoli_scene:
		return
	
	# 在周圍生成小青花菜
	for i in range(data.split_count):
		var mini = ObjectPool.request(mini_broccoli_scene)
		
		# 找到敵人層來添加小青花菜
		var enemies_layer = get_tree().get_first_node_in_group("enemies_layer")
		if enemies_layer:
			enemies_layer.add_child(mini)
		else:
			get_parent().add_child(mini)
		
		# 設置小青花菜的位置（隨機分散）
		var angle = (i * PI * 2) / data.split_count
		var offset = Vector2(cos(angle), sin(angle)) * 40.0
		mini.global_position = self.global_position + offset
		
		# 初始化小青花菜的數據
		if mini.has_method("initialize_as_split"):
			mini.initialize_as_split(data.split_health, data.split_speed)