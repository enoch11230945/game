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
	up.id = "auto_projectile_up"
	up.target_weapon_name = target.weapon_data.name
	up.add_projectiles = 1
	EventBus.upgrade_selected.emit(up)
	upgrade_applied.emit(up)
