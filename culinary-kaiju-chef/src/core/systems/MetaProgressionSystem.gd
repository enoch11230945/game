# MetaProgressionSystem.gd - "Just One More Run" System
extends Node

signal meta_currency_changed(new_amount: int)
signal permanent_upgrade_purchased(upgrade_name: String)

const SAVE_FILE_PATH = "user://meta_progression.tres"

# Meta currency (persists between runs)
var gold_coins: int = 0
var total_runs: int = 0
var best_time_survived: float = 0.0
var total_enemies_killed: int = 0

# Permanent upgrades (purchased with gold)
var permanent_upgrades: Dictionary = {
	"health_boost_1": 0,      # +5% max health per level (max 10)
	"health_boost_2": 0,      # +10% max health per level (max 5) 
	"damage_boost_1": 0,      # +3% damage per level (max 10)
	"damage_boost_2": 0,      # +5% damage per level (max 5)
	"speed_boost_1": 0,       # +2% movement speed per level (max 10)
	"speed_boost_2": 0,       # +5% movement speed per level (max 5)
	"pickup_boost_1": 0,      # +10% pickup radius per level (max 5)
	"pickup_boost_2": 0,      # +20% pickup radius per level (max 3)
	"xp_boost_1": 0,          # +5% XP gain per level (max 10)
	"xp_boost_2": 0,          # +10% XP gain per level (max 5)
	"crit_boost_1": 0,        # +1% crit chance per level (max 10)
	"crit_boost_2": 0,        # +2% crit chance per level (max 5)
	"starting_armor": 0,      # Start with +1 armor per level (max 3)
	"starting_weapon": 0,     # Start with random weapon (max 1)
	"luck_boost": 0,          # +5% better upgrade chances per level (max 5)
	"gold_boost": 0,          # +10% gold from runs per level (max 10)
}

func _ready():
	load_meta_progression()

func add_gold(amount: int):
	gold_coins += amount
	meta_currency_changed.emit(gold_coins)
	save_meta_progression()

func get_permanent_bonus(stat_name: String) -> float:
	var bonus: float = 0.0
	
	match stat_name:
		"max_health":
			bonus += permanent_upgrades["health_boost_1"] * 0.05
			bonus += permanent_upgrades["health_boost_2"] * 0.10
		"damage":
			bonus += permanent_upgrades["damage_boost_1"] * 0.03
			bonus += permanent_upgrades["damage_boost_2"] * 0.05
		"movement_speed":
			bonus += permanent_upgrades["speed_boost_1"] * 0.02
			bonus += permanent_upgrades["speed_boost_2"] * 0.05
		"pickup_radius":
			bonus += permanent_upgrades["pickup_boost_1"] * 0.10
			bonus += permanent_upgrades["pickup_boost_2"] * 0.20
		"xp_gain":
			bonus += permanent_upgrades["xp_boost_1"] * 0.05
			bonus += permanent_upgrades["xp_boost_2"] * 0.10
		"crit_chance":
			bonus += permanent_upgrades["crit_boost_1"] * 0.01
			bonus += permanent_upgrades["crit_boost_2"] * 0.02
		"starting_armor":
			bonus = permanent_upgrades["starting_armor"]
		"luck":
			bonus += permanent_upgrades["luck_boost"] * 0.05
		"gold_multiplier":
			bonus += permanent_upgrades["gold_boost"] * 0.10
	
	return bonus

func purchase_upgrade(upgrade_name: String) -> bool:
	# Implementation shortened for brevity
	return true

func save_meta_progression():
	var save_data = {}
	save_data["gold_coins"] = gold_coins
	save_data["permanent_upgrades"] = permanent_upgrades
	# Save to user:// directory

func load_meta_progression():
	# Load from user:// directory
	pass