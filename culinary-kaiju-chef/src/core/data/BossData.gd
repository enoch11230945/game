# BossData.gd - Boss configuration resource
extends Resource
class_name BossData

@export var boss_name: String = "Generic Boss"
@export var description: String = "A powerful enemy"
@export var base_health: int = 1000
@export var base_damage: int = 50
@export var base_speed: float = 60.0
@export var base_xp_value: int = 200

# Boss-specific properties
@export var boss_type: String = "STANDARD" # STANDARD, SWARM_LORD, ARTILLERY, BERSERKER
@export var phase_count: int = 1
@export var sprite_texture_path: String = ""
@export var scale_factor: float = 2.0

# Attack patterns
@export var attack_patterns: Array[String] = []
@export var special_abilities: Array[String] = []
@export var phase_transitions: Array[float] = [0.5] # Health thresholds for phase changes

# Resistances and immunities
@export var damage_resistance: Dictionary = {}
@export var status_immunities: Array[String] = []

# Rewards
@export var guaranteed_drops: Array[String] = []
@export var drop_chances: Dictionary = {}
@export var meta_currency_reward: int = 100

# Audio/Visual
@export var boss_music_path: String = ""
@export var death_sound_path: String = ""
@export var spawn_effect_path: String = ""

# Spawn conditions
@export var spawn_time_minutes: int = 5
@export var spawn_wave_requirement: int = 0
@export var required_kills: int = 0