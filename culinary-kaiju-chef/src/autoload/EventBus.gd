# EventBus.gd - Global signal bus as demanded by Linus
# "Decouple systems to avoid spaghetti code" - Linus philosophy
extends Node

# === SCENE MANAGEMENT ===
signal main_scene_ready()

# === PLAYER EVENTS ===
signal player_health_changed(new_health: int, max_health: int)
signal player_level_up(new_level: int)
signal player_xp_gained(amount: int)
signal player_died()
signal player_position_changed(position: Vector2)
signal player_damaged()
signal player_move_speed_changed(new_speed: float)

# === ENEMY EVENTS ===
signal enemy_spawned(enemy: Node2D, enemy_data: EnemyData)
signal enemy_died(enemy: Node2D, position: Vector2, xp_reward: int)
signal enemy_damaged(enemy: Node2D, damage: int)
signal enemy_killed(enemy: Node, xp_reward: int)

# === WEAPON EVENTS ===
signal weapon_fired(weapon_type: String, origin: Vector2, target: Vector2)
signal weapon_hit(weapon: Node2D, target: Node2D, damage: int)
signal weapon_upgraded(weapon_type: String, upgrade_type: String)
signal projectile_hit(projectile: Node, enemy: Node, damage: int)

# === XP AND UPGRADE EVENTS ===
signal xp_gained(amount: int)
signal experience_vial_collected(number: float)
signal upgrade_selected(upgrade_data: Resource)
signal upgrade_applied(upgrade_data: Resource)
signal ability_upgrade_added(upgrade: Resource, current_upgrades: Dictionary)
signal level_up_screen_opened()
signal level_up_screen_closed()

# === GAME EVENTS ===
signal game_started()
signal game_paused(is_paused: bool)
signal game_over(final_score: int, time_survived: float)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal score_changed(new_score: int)

# === UI EVENTS ===
signal show_upgrade_screen(upgrade_options: Array)
signal health_bar_update_requested(current: int, max: int)
signal xp_bar_update_requested(current: int, required: int, level: int)

# === VFX EVENTS ===
signal screen_shake_requested(intensity: float, duration: float)
signal spawn_particle_effect(effect_name: String, position: Vector2)

# === AUDIO EVENTS ===
signal play_sound(sound_name: String)
signal play_music(track_name: String)
signal stop_music()

# === MONETIZATION EVENTS ===
signal ad_requested(ad_type: String)
signal ad_watched_successfully(ad_type: String, reward_data: Dictionary)
signal ad_failed(ad_type: String, reason: String)
signal iap_requested(product_id: String)
signal iap_completed(product_id: String, success: bool)
signal player_revived_by_ad()

# === ACHIEVEMENT EVENTS ===
signal achievement_unlocked(achievement_id: String)

# === COMPATIBILITY LAYER FOR SURVIVOR TUTORIAL ===
# These functions maintain compatibility with survivor-tutorial patterns

func emit_experience_vial_collected(number: float):
    experience_vial_collected.emit(number)

func emit_ability_upgrade_added(upgrade: Resource, current_upgrades: Dictionary):
    ability_upgrade_added.emit(upgrade, current_upgrades)

func emit_player_damaged():
    player_damaged.emit()
    
signal hide_upgrade_screen()
signal update_hud(health: int, level: int, xp: int, xp_required: int)
signal show_damage_number(position: Vector2, damage: int, color: Color)

# === ITEM EVENTS ===
signal item_collected(item_type: String, position: Vector2)
signal xp_gem_spawned(position: Vector2, value: int)

# === BOSS EVENTS ===
signal boss_spawn_requested(boss_data: BossData)
signal boss_spawned(boss: Node2D)
signal boss_phase_changed(boss: Node2D, new_phase: int)
signal boss_defeated(boss: Node2D, boss_data: BossData)

# === UPGRADE EVENTS ===
# NOTE: upgrade_applied already defined above at line 33
signal passive_effect_applied(effect_name: String)
signal weapon_evolved(old_weapon: String, new_weapon: String)

# === META PROGRESSION EVENTS ===
signal gold_collected(amount: int)
signal meta_upgrade_purchased(upgrade_name: String, level: int)
# NOTE: achievement_unlocked already defined above at line 69
signal character_unlocked(character_id: String)

# === MONETIZATION EVENTS ===
# NOTE: All monetization signals already defined above at lines 61-66

# === SCREEN TRANSITION EVENTS ===
signal scene_change_requested(scene_path: String)
signal main_menu_requested()
signal game_restart_requested()

# === PARTICLE/EFFECT EVENTS ===
# NOTE: spawn_particle_effect already defined above at line 53
# NOTE: screen_shake_requested already defined above at line 52
signal screen_flash_requested(color: Color, duration: float)

# Debugging function
func emit_debug(event_name: String, data = null):
    print("[EventBus] %s: %s" % [event_name, str(data)])

# Helper functions for common patterns
func emit_player_stat_change(health: int, max_health: int, level: int, xp: int, xp_required: int):
    player_health_changed.emit(health, max_health)
    update_hud.emit(health, level, xp, xp_required)

func emit_enemy_death_effects(position: Vector2, xp_value: int):
    """Emit all effects related to enemy death"""
    xp_gem_spawned.emit(position, xp_value)
    spawn_particle_effect.emit("enemy_death", position)
    play_sound.emit("enemy_death")

func emit_player_level_up_effects(new_level: int):
    """Emit all effects related to level up"""
    player_level_up.emit(new_level)
    spawn_particle_effect.emit("level_up", Vector2.ZERO)
    play_sound.emit("level_up")
    screen_flash_requested.emit(Color.YELLOW, 0.3)
    # Note: update_hud should be called separately with actual values

func emit_enemy_death(enemy: Node2D, enemy_data: EnemyData, position: Vector2):
    var xp_reward = enemy_data.experience_reward
    enemy_died.emit(enemy, position, xp_reward)
    xp_gem_spawned.emit(position, xp_reward)