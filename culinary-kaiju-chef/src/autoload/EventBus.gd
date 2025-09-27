# EventBus.gd - Global signal bus as demanded by Linus
# "Decouple systems to avoid spaghetti code" - Linus philosophy
extends Node

# === PLAYER EVENTS ===
signal player_health_changed(new_health: int, max_health: int)
signal player_level_up(new_level: int)
signal player_xp_gained(amount: int)
signal player_died()
signal player_position_changed(position: Vector2)

# === ENEMY EVENTS ===
signal enemy_spawned(enemy: Node2D, enemy_data: EnemyData)
signal enemy_died(enemy: Node2D, position: Vector2, xp_reward: int)
signal enemy_damaged(enemy: Node2D, damage: int)

# === WEAPON EVENTS ===
signal weapon_fired(weapon_type: String, origin: Vector2, target: Vector2)
signal weapon_hit(weapon: Node2D, target: Node2D, damage: int)
signal weapon_upgraded(weapon_type: String, upgrade_type: String)

# === GAME EVENTS ===
signal game_started()
signal game_paused(is_paused: bool)
signal game_over(final_score: int, time_survived: float)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)

# === UI EVENTS ===
signal show_upgrade_screen(upgrade_options: Array)
signal hide_upgrade_screen()
signal update_hud(health: int, level: int, xp: int, xp_required: int)
signal show_damage_number(position: Vector2, damage: int, color: Color)

# === ITEM EVENTS ===
signal item_collected(item_type: String, position: Vector2)
signal xp_gem_spawned(position: Vector2, value: int)

# === AUDIO EVENTS ===
signal play_sound(sound_name: String)
signal play_music(music_name: String)
signal stop_music()

# Debugging function
func emit_debug(event_name: String, data = null):
    print("[EventBus] %s: %s" % [event_name, str(data)])

# Helper functions for common patterns
func emit_player_stat_change(health: int, max_health: int, level: int, xp: int, xp_required: int):
    player_health_changed.emit(health, max_health)
    update_hud.emit(health, level, xp, xp_required)

func emit_enemy_death(enemy: Node2D, enemy_data: EnemyData, position: Vector2):
    var xp_reward = enemy_data.experience_reward
    enemy_died.emit(enemy, position, xp_reward)
    xp_gem_spawned.emit(position, xp_reward)