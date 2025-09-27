# CarrotTank.gd - 胡蘿蔔坦克：慢速、高血量、高傷害
extends BaseEnemy
class_name CarrotTank

func _ready() -> void:
	super._ready()
	
	# 胡蘿蔔坦克特有的特性
	connect("area_entered", _on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		# 造成額外傷害（因為它是坦克）
		EventBus.emit_signal("player_hit", data.damage * 1.5)
		# 播放撞擊音效 
		AudioManager.play_weapon_hit()

func take_damage(amount: int) -> void:
	super.take_damage(amount)
	
	# 胡蘿蔔坦克受到傷害時發出特殊音效
	AudioManager.play_sfx("impactMining_002", 0.8)
	
	# 造成輕微的螢幕振動效果（如果有相機系統的話）
	if get_viewport().has_method("add_camera_shake"):
		get_viewport().add_camera_shake(2.0)