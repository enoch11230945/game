extends CanvasLayer
class_name HUD

@onready var level_label = $Stats/LevelLabel
@onready var xp_label = $Stats/XPLabel
@onready var kills_label = $Stats/KillsLabel
@onready var proj_label = $Stats/ProjectilesLabel

var _timer: float = 0.0
@export var update_interval: float = 0.5

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= update_interval:
		_timer = 0.0
		_update_stats()

func _update_stats():
	var gs = Game.get_game_stats()
	level_label.text = "Level: %d" % gs.level
	xp_label.text = "XP: %d/%d" % [gs.current_xp, gs.required_xp]
	kills_label.text = "Kills: %d" % gs.enemies_killed
	proj_label.text = _format_weapon_projectiles() + " | " + _format_dps()

func _format_weapon_projectiles() -> String:
	if not Game.player:
		return "Shots/Weapon: -"
	var arr: Array[String] = []
	for c in Game.player.get_children():
		if c is BaseWeapon:

func _format_dps() -> String:
	if not Game.player or Game.time_elapsed <= 0.1:
		return "DPS: -"
	var parts: Array[String] = []
	for c in Game.player.get_children():
		if c is BaseWeapon:
			var dps = int(float(c.total_damage_dealt) / Game.time_elapsed)
			parts.append("%s:%d" % [c.weapon_data.name, dps])
	return "DPS: " + ", ".join(parts)

			arr.append("%s=%d" % [c.weapon_data.name, c.weapon_data.projectile_count])
	return "Shots/Weapon: " + ", ".join(arr)
