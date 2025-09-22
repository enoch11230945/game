# EventBus.gd
extends Node

# 定義信號
signal player_took_damage(amount: int)
signal player_gained_xp(amount: int)
signal player_level_up(level: int)
signal enemy_died(position: Vector2, xp_value: int)
signal weapon_fired(weapon_data: WeaponData, position: Vector2, direction: Vector2)
signal game_paused
signal game_resumed
signal game_over
signal game_victory

# 發送事件的方法
func emit_player_took_damage(amount: int) -> void:
    player_took_damage.emit(amount)

func emit_player_gained_xp(amount: int) -> void:
    player_gained_xp.emit(amount)

func emit_player_level_up(level: int) -> void:
    player_level_up.emit(level)

func emit_enemy_died(position: Vector2, xp_value: int) -> void:
    enemy_died.emit(position, xp_value)

func emit_weapon_fired(weapon_data: WeaponData, position: Vector2, direction: Vector2) -> void:
    weapon_fired.emit(weapon_data, position, direction)

func emit_game_paused() -> void:
    game_paused.emit()

func emit_game_resumed() -> void:
    game_resumed.emit()

func emit_game_over() -> void:
    game_over.emit()

func emit_game_victory() -> void:
    game_victory.emit()
