extends CanvasLayer
class_name UpgradeScreen

@onready var button_a: Button = $Panel/VBox/Options/ButtonA
@onready var button_b: Button = $Panel/VBox/Options/ButtonB
@onready var button_c: Button = $Panel/VBox/Options/ButtonC

var current_upgrades: Array[UpgradeData] = []
var pending_callback: Callable

func _ready() -> void:
	button_a.pressed.connect(func(): _select_index(0))
	button_b.pressed.connect(func(): _select_index(1))
	button_c.pressed.connect(func(): _select_index(2))

func show_choices(upgrades: Array[UpgradeData], callback: Callable) -> void:
	current_upgrades = upgrades
	pending_callback = callback
	if current_upgrades.size() != 3:
		return
	button_a.text = _format_upgrade_preview(current_upgrades[0])
	button_b.text = _format_upgrade_preview(current_upgrades[1])
	button_c.text = _format_upgrade_preview(current_upgrades[2])
	visible = true
	get_tree().paused = true

func _select_index(i: int) -> void:
	if i >= 0 and i < current_upgrades.size():
		var up = current_upgrades[i]
		EventBus.upgrade_selected.emit(up)
		if pending_callback and pending_callback.is_valid():
			pending_callback.call()
	visible = false
	get_tree().paused = false

func _format_upgrade(up: UpgradeData) -> String:
	var parts: Array[String] = []
	if up.add_projectiles != 0:
		parts.append("+%d proj" % up.add_projectiles)
	if up.damage_multiplier != 1.0:
		parts.append("dmg x%.2f" % up.damage_multiplier)
	if up.cooldown_multiplier != 1.0:
		parts.append("cd x%.2f" % up.cooldown_multiplier)
	if parts.is_empty():
		parts.append("(noop)")
	return "%s: %s" % [up.target_weapon_name, ", ".join(parts)]

func _format_upgrade_preview(up: UpgradeData) -> String:
	# 顯示 當前 -> 升級後 對比
	var weapon = DataManager.get_weapon(up.target_weapon_name)
	var base_proj = weapon.projectile_count if weapon else 0
	var proj_after = base_proj + up.add_projectiles
	var dmg_after = weapon.damage * (up.damage_multiplier if up.damage_multiplier != 1.0 else 1.0) if weapon else 0
	var cd_after = weapon.cooldown * (up.cooldown_multiplier if up.cooldown_multiplier != 1.0 else 1.0) if weapon else 0
	var parts: Array[String] = []
	if up.add_projectiles != 0:
		parts.append("proj %d->%d" % [base_proj, proj_after])
	if up.damage_multiplier != 1.0:
		parts.append("dmg %d->%d" % [weapon.damage, int(dmg_after)])
	if up.cooldown_multiplier != 1.0:
		parts.append("cd %.2f->%.2f" % [weapon.cooldown, cd_after])
	if parts.is_empty():
		parts.append("(noop)")
	return "%s | %s" % [up.target_weapon_name, ", ".join(parts)]

