# UpgradeData.gd - Upgrade configuration resource
extends Resource
class_name UpgradeData

@export var upgrade_name: String = "Generic Upgrade"
@export var description: String = "Improves something"
@export var icon_texture_path: String = ""
@export var upgrade_type: String = "STAT" # STAT, WEAPON, UNLOCK, EVOLUTION, PASSIVE

# Effect properties
@export var stat_effects: Dictionary = {} # {"damage": 0.1, "speed": 20}
@export var weapon_effects: Dictionary = {} # {"weapon_name": {"damage": 0.2}}
@export var passive_effects: Array[String] = [] # ["magnetic_pickup", "health_regen"]

# Requirements and rarity
@export var rarity: String = "COMMON" # COMMON, RARE, EPIC, LEGENDARY
@export var requirements: Array[String] = [] # ["weapon_cleaver_level_5", "kill_count_100"]
@export var max_stack: int = 1
@export var weight: float = 1.0 # Probability weight in selection

# Exclusions and synergies
@export var exclusive_with: Array[String] = [] # Cannot be picked with these
@export var synergy_bonus: Dictionary = {} # Extra effects when combined with other upgrades

# Visual/Audio
@export var pickup_sound_path: String = "res://assets/audio/ui/upgrade_pickup.ogg"
@export var upgrade_effect_path: String = ""

# Meta information
@export var unlock_condition: String = "" # Condition to make this upgrade available