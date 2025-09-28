# WeaponEvolutionSystem.gd - Handle weapon evolution (PRD5 Epic 1.1)
extends Node

# === EVOLUTION DATA ===
var evolution_data: Array[WeaponEvolutionData] = []
var weapon_levels: Dictionary = {}  # weapon_name -> level
var owned_passives: Array[String] = []

func _ready() -> void:
    print("🔄 WeaponEvolutionSystem initialized")
    _load_evolution_data()
    _connect_events()

func _load_evolution_data() -> void:
    """Load all weapon evolution configurations"""
    var evolution_paths = [
        "res://src/core/data/cleaver_evolution.tres"
    ]
    
    for path in evolution_paths:
        if ResourceLoader.exists(path):
            var evolution = load(path)
            if evolution is WeaponEvolutionData:
                evolution_data.append(evolution)
                print("✅ Loaded evolution: %s -> %s" % [evolution.base_weapon_name, evolution.evolution_name])

func _connect_events() -> void:
    """Connect to relevant events"""
    EventBus.weapon_upgraded.connect(_on_weapon_upgraded)
    EventBus.upgrade_applied.connect(_on_upgrade_applied)

func check_all_evolutions() -> Array[WeaponEvolutionData]:
    """Check which weapons can evolve"""
    var available_evolutions: Array[WeaponEvolutionData] = []
    
    for evolution in evolution_data:
        var weapon_level = weapon_levels.get(evolution.base_weapon_name, 0)
        
        if evolution.can_evolve(weapon_level, owned_passives):
            available_evolutions.append(evolution)
    
    return available_evolutions

func evolve_weapon(evolution: WeaponEvolutionData, player: Node2D) -> bool:
    """Evolve a weapon"""
    if not evolution or not player:
        return false
    
    # Find the weapon to evolve
    var weapon_to_evolve = find_weapon_by_name(player, evolution.base_weapon_name)
    if not weapon_to_evolve:
        print("❌ Weapon not found for evolution: %s" % evolution.base_weapon_name)
        return false
    
    # Remove old weapon
    weapon_to_evolve.queue_free()
    
    # Create evolved weapon
    var weapon_scene = preload("res://features/weapons/base_weapon/BaseWeapon.tscn")
    var evolved_weapon = weapon_scene.instantiate()
    
    if not evolved_weapon:
        print("❌ Failed to create evolved weapon")
        return false
    
    # Add to player
    player.add_child(evolved_weapon)
    
    # Initialize with evolved data
    if evolved_weapon.has_method("initialize"):
        evolved_weapon.initialize(player, evolution.evolved_weapon_data)
    
    # Reset weapon level tracking
    weapon_levels[evolution.base_weapon_name] = 0
    weapon_levels[evolution.evolution_name] = 1
    
    # Visual/Audio feedback
    show_evolution_effects(player.global_position, evolution)
    
    # Emit event
    EventBus.weapon_evolved.emit(evolution.base_weapon_name, evolution.evolution_name)
    
    print("🎉 Weapon evolved: %s -> %s" % [evolution.base_weapon_name, evolution.evolution_name])
    return true

func find_weapon_by_name(player: Node2D, weapon_name: String) -> Node2D:
    """Find weapon node by name"""
    for child in player.get_children():
        if child.has_method("get_weapon_name"):
            if child.get_weapon_name() == weapon_name:
                return child
        elif child.has_meta("weapon_name"):
            if child.get_meta("weapon_name") == weapon_name:
                return child
    
    return null

func show_evolution_effects(position: Vector2, evolution: WeaponEvolutionData) -> void:
    """Show visual and audio effects for evolution"""
    # Visual effect
    EventBus.spawn_particle_effect.emit(evolution.evolution_effect, position)
    EventBus.screen_flash_requested.emit(Color.GOLD, 0.5)
    
    # Audio effect
    if AudioManager and AudioManager.has_method("play_sfx"):
        AudioManager.play_sfx(evolution.evolution_sound)
    
    # Screen shake
    EventBus.screen_shake_requested.emit(1.0, 0.3)

func add_passive_item(passive_name: String) -> void:
    """Add passive item to owned list"""
    if not owned_passives.has(passive_name):
        owned_passives.append(passive_name)
        print("📿 Added passive: %s" % passive_name)
        
        # Check for new evolution opportunities
        var available = check_all_evolutions()
        if not available.is_empty():
            print("🔄 New evolutions available: %d" % available.size())

func upgrade_weapon_level(weapon_name: String) -> void:
    """Increase weapon level"""
    var current_level = weapon_levels.get(weapon_name, 0)
    weapon_levels[weapon_name] = current_level + 1
    
    print("⬆️ %s level: %d" % [weapon_name, weapon_levels[weapon_name]])
    
    # Check for evolution opportunity
    var available = check_all_evolutions()
    for evolution in available:
        if evolution.base_weapon_name == weapon_name:
            print("🌟 %s can evolve! (Level %d)" % [weapon_name, weapon_levels[weapon_name]])

# === EVENT HANDLERS ===
func _on_weapon_upgraded(weapon_type: String, upgrade_type: String) -> void:
    """Handle weapon upgrade - increase level"""
    upgrade_weapon_level(weapon_type)

func _on_upgrade_applied(upgrade_data: Resource) -> void:
    """Handle upgrade application"""
    if upgrade_data and upgrade_data.has_method("get_upgrade_name"):
        var upgrade_name = upgrade_data.get_upgrade_name()
        
        # Check if it's a passive item
        if upgrade_data.upgrade_type == "PASSIVE":
            add_passive_item(upgrade_name)

# === UTILITY FUNCTIONS ===
func get_evolution_opportunities() -> Array[String]:
    """Get list of weapons that can evolve"""
    var opportunities: Array[String] = []
    
    for evolution in check_all_evolutions():
        opportunities.append("%s -> %s" % [evolution.base_weapon_name, evolution.evolution_name])
    
    return opportunities

func get_weapon_level(weapon_name: String) -> int:
    """Get current weapon level"""
    return weapon_levels.get(weapon_name, 0)

func get_owned_passives() -> Array[String]:
    """Get list of owned passive items"""
    return owned_passives.duplicate()