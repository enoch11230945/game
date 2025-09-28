extends Node

var weapons_by_name: Dictionary = {}
var enemies_by_name: Dictionary = {}

func _ready() -> void:
	_load_weapon_data()
	_load_enemy_data()

func _load_weapon_data():
	weapons_by_name.clear()
	var dir = DirAccess.open("res://features/weapons/weapon_data")
	if dir:
		dir.list_dir_begin()
		var f = dir.get_next()
		while f != "":
			if not dir.current_is_dir() and f.ends_with(".tres"):
				var res = load("res://features/weapons/weapon_data/" + f)
				if res and res.has_method("get_class"):
					weapons_by_name[res.name] = res
			f = dir.get_next()
		dir.list_dir_end()

func _load_enemy_data():
	enemies_by_name.clear()
	var dir = DirAccess.open("res://features/enemies/enemy_data")
	if dir:
		dir.list_dir_begin()
		var f = dir.get_next()
		while f != "":
			if not dir.current_is_dir() and f.ends_with(".tres"):
				var res = load("res://features/enemies/enemy_data/" + f)
				if res and res.has_method("get_class"):
					enemies_by_name[res.name] = res
			f = dir.get_next()
		dir.list_dir_end()

func get_weapon(weapon_name: String):
	return weapons_by_name.get(weapon_name, null)

func get_enemy(enemy_name: String):
	return enemies_by_name.get(enemy_name, null)

func reload():
	_load_weapon_data()
	_load_enemy_data()
