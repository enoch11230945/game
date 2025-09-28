# WeaponEvolutionManager.gd
# Implements Epic 1.1: Weapon Evolution System
# Linus principle: "Eliminate special cases" - One clean evolution checker
extends Node
class_name WeaponEvolutionManager

# Evolution rules database - data-driven approach
var evolution_rules: Array[Dictionary] = [
	{
		"base_weapon": "Throwing Knife",
		"required_passive": "Garlic Aura", 
		"evolved_weapon": "Vampiric Blade",
		"description": "Throwing knives gain life steal from garlic power"
	},
	{
		"base_weapon": "Whisk",
		"required_passive": "Speed Boost",
		"evolved_weapon": "Tornado Whisk", 
		"description": "Speed-enhanced whisk creates devastating tornadoes"
	}
]

# Check if any equipped weapons can evolve
func check_for_evolutions(player_weapons: Array, player_passives: Array) -> Array:
	var available_evolutions: Array = []
	
	for weapon in player_weapons:
		if not weapon.has_method("get_level") or weapon.get_level() < 8:
			continue  # Only max-level weapons can evolve
			
		var weapon_name = weapon.weapon_data.name
		var evolution = _find_evolution_for_weapon(weapon_name, player_passives)
		
		if evolution:
			available_evolutions.append(evolution)
	
	return available_evolutions

# Private: Find evolution rule for weapon if requirements met
func _find_evolution_for_weapon(weapon_name: String, player_passives: Array) -> Dictionary:
	for rule in evolution_rules:
		if rule.base_weapon != weapon_name:
			continue
			
		# Check if player has required passive
		for passive in player_passives:
			if passive.name == rule.required_passive:
				return rule
	
	return {}

# Execute evolution: Remove base weapon + passive, add evolved weapon
func execute_evolution(player: Node, evolution_rule: Dictionary) -> void:
	if evolution_rule.is_empty():
		return
		
	print("🌟 EVOLUTION: ", evolution_rule.base_weapon, " → ", evolution_rule.evolved_weapon)
	
	# Remove base weapon and required passive
	_remove_weapon_by_name(player, evolution_rule.base_weapon)
	_remove_passive_by_name(player, evolution_rule.required_passive)
	
	# Add evolved weapon
	var evolved_weapon_data = DataManager.get_weapon(evolution_rule.evolved_weapon)
	if evolved_weapon_data:
		player.equip_weapon(evolved_weapon_data)
		
	# Emit evolution event for VFX/SFX
	EventBus.emit_signal("weapon_evolved", evolution_rule)

func _remove_weapon_by_name(player: Node, weapon_name: String) -> void:
	if not player.has_method("remove_weapon_by_name"):
		print("WARNING: Player missing remove_weapon_by_name method")
		return
	player.remove_weapon_by_name(weapon_name)

func _remove_passive_by_name(player: Node, passive_name: String) -> void:
	if not player.has_method("remove_passive_by_name"):  
		print("WARNING: Player missing remove_passive_by_name method")
		return
	player.remove_passive_by_name(passive_name)