extends Node
class_name UpgradeManager

signal upgrade_applied(upgrade: UpgradeData)

var auto_mode: bool = true
var _timer: float = 0.0
@export var interval: float = 12.0

func _process(delta: float) -> void:
	if not auto_mode:
		return
	_timer += delta
	if _timer >= interval:
		_timer = 0.0
		_apply_random_upgrade()

func _apply_random_upgrade():
	if not Game.player:
		return
	var weapons: Array = []
	for c in Game.player.get_children():
		if c is BaseWeapon:
			weapons.append(c)
	if weapons.is_empty():
		return
	var target: BaseWeapon = weapons[randi() % weapons.size()]
	var up := UpgradeData.new()
	up.target_weapon_name = target.weapon_data.name
	# 隨機類型：0=彈數,1=傷害,2=冷卻
	match randi() % 3:
		0:
			up.id = "proj+"
			up.add_projectiles = 1
		1:
			up.id = "dmg+"
			up.damage_multiplier = 1.15
		2:
			up.id = "cd-"
			up.cooldown_multiplier = 0.9
	EventBus.upgrade_selected.emit(up)
	upgrade_applied.emit(up)
