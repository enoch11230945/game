# WeaponEvolutionData.gd - Weapon evolution system (PRD5 Epic 1.1)
extends Resource
class_name WeaponEvolutionData

@export var base_weapon_name: String = ""
@export var required_level: int = 8
@export var required_passive: String = ""  # Required passive item name
@export var evolved_weapon_data: WeaponData
@export var evolution_name: String = ""
@export var evolution_description: String = ""

# Visual/Audio feedback
@export var evolution_effect: String = "weapon_evolution"
@export var evolution_sound: String = "weapon_evolution"

func can_evolve(weapon_level: int, owned_passives: Array[String]) -> bool:
    """Check if weapon can evolve"""
    if weapon_level < required_level:
        return false
    
    if required_passive != "" and not owned_passives.has(required_passive):
        return false
    
    return true