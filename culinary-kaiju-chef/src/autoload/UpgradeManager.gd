extends Node
# UpgradeManager: now coordinates deterministic upgrade UI instead of auto applying silently

class_name UpgradeManager

signal upgrade_applied(upgrade: UpgradeData)

var auto_mode: bool = false # UI 模式下關閉自動升級
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

func present_upgrade_ui():
	# 生成三個候選升級
	if not Game.player:
		return
	var weapons: Array = []
	for c in Game.player.get_children():
		if c is BaseWeapon:
			weapons.append(c)
	if weapons.is_empty():
		return
	var candidates: Array[UpgradeData] = []
	for i in range(3):
		var up := UpgradeData.new()
		var target: BaseWeapon = weapons[randi() % weapons.size()]
		up.target_weapon_name = target.weapon_data.name
		match randi() % 3:
			0:
				up.add_projectiles = 1
				up.id = "choice_proj"
			1:
				up.damage_multiplier = 1.20
				up.id = "choice_dmg"
			2:
				up.cooldown_multiplier = 0.85
				up.id = "choice_cd"
		candidates.append(up)
	var ui = get_tree().get_first_node_in_group("upgrade_ui")
	if not ui:
		# 直接尋找節點
		ui = get_tree().get_root().find_child("UpgradeScreen", true, false)
	if ui and ui.has_method("show_choices"):
		ui.show_choices(candidates, Callable(self, "_on_ui_upgrade_done"))

func _on_ui_upgrade_done():
	upgrade_applied.emit(null)

		1:
			up.id = "dmg+"
			up.damage_multiplier = 1.15
		2:
			up.id = "cd-"
			up.cooldown_multiplier = 0.9
	EventBus.upgrade_selected.emit(up)
	upgrade_applied.emit(up)
