# WeaponManager.gd - Pure weapon logic management (Linus refactor)
# "Each manager handles exactly one domain" - Linus Philosophy
extends Node

# === WEAPON STATE ===
var active_weapons: Array[Node2D] = []
var weapon_data_cache: Dictionary = {}
var auto_attack_enabled: bool = true

# === ATTACK TIMERS ===
var attack_timers: Dictionary = {}
var global_attack_timer: float = 0.0
var base_attack_interval: float = 1.0

# === TARGETING ===
var auto_target_enabled: bool = true
var max_target_range: float = 500.0

func _ready() -> void:
    print("⚔️ WeaponManager initialized")
    _load_weapon_data()
    _connect_events()

func _load_weapon_data() -> void:
    """Preload weapon data resources"""
    var weapon_paths = [
        "res://features/weapons/weapon_data/throwing_knife.tres",
        "res://src/core/data/cleaver_weapon.tres"
    ]
    
    for path in weapon_paths:
        if ResourceLoader.exists(path):
            var weapon_data = load(path)
            if weapon_data:
                weapon_data_cache[weapon_data.weapon_name] = weapon_data
                print("✅ Loaded weapon: %s" % weapon_data.weapon_name)

func _connect_events() -> void:
    """Connect to relevant events"""
    EventBus.weapon_upgraded.connect(_on_weapon_upgraded)
    EventBus.player_level_up.connect(_on_player_level_up)

func _process(delta: float) -> void:
    if Game and (Game.is_paused or Game.is_game_over):
        return
    
    # Update global attack timer
    global_attack_timer -= delta
    
    # Auto-attack if enabled
    if auto_attack_enabled and global_attack_timer <= 0:
        execute_auto_attacks()
        global_attack_timer = base_attack_interval

func execute_auto_attacks() -> void:
    """Execute auto-attacks for all active weapons"""
    var player = get_tree().get_first_node_in_group("player")
    if not player:
        return
    
    var enemies = get_tree().get_nodes_in_group("enemies")
    if enemies.is_empty():
        return
    
    # Find best target
    var target = find_best_target(player.global_position, enemies)
    if not target:
        return
    
    # Attack with all weapons
    for weapon in active_weapons:
        if is_instance_valid(weapon) and weapon.has_method("attack"):
            weapon.attack()

func find_best_target(player_pos: Vector2, enemies: Array) -> Node2D:
    """Find the best enemy to target"""
    var best_target: Node2D = null
    var best_distance: float = INF
    
    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        
        var distance = player_pos.distance_to(enemy.global_position)
        if distance < max_target_range and distance < best_distance:
            best_distance = distance
            best_target = enemy
    
    return best_target

func equip_weapon(weapon_name: String, player: Node2D) -> Node2D:
    """Equip a weapon to the player"""
    if not weapon_data_cache.has(weapon_name):
        print("❌ Unknown weapon: %s" % weapon_name)
        return null
    
    var weapon_data = weapon_data_cache[weapon_name]
    var weapon_scene = preload("res://features/weapons/base_weapon/BaseWeapon.tscn")
    var weapon = weapon_scene.instantiate()
    
    if not weapon:
        print("❌ Failed to create weapon: %s" % weapon_name)
        return null
    
    # Add to player
    player.add_child(weapon)
    
    # Initialize weapon
    if weapon.has_method("initialize"):
        weapon.initialize(player, weapon_data)
    
    # Track weapon
    active_weapons.append(weapon)
    attack_timers[weapon] = 0.0
    
    # Emit event
    EventBus.weapon_fired.emit(weapon_name, player.global_position, Vector2.ZERO)
    
    print("⚔️ Equipped weapon: %s" % weapon_name)
    return weapon

func upgrade_weapon(weapon: Node2D, upgrade_data: Resource) -> void:
    """Apply upgrade to specific weapon"""
    if not is_instance_valid(weapon) or not weapon.has_method("apply_upgrade"):
        return
    
    weapon.apply_upgrade(upgrade_data)
    EventBus.weapon_upgraded.emit("weapon", "upgrade")

func remove_weapon(weapon: Node2D) -> void:
    """Remove weapon from tracking"""
    active_weapons.erase(weapon)
    attack_timers.erase(weapon)

# === EVENT HANDLERS ===
func _on_weapon_upgraded(weapon_type: String, upgrade_type: String) -> void:
    """Handle weapon upgrade events"""
    print("⬆️ Weapon upgraded: %s -> %s" % [weapon_type, upgrade_type])

func _on_player_level_up(new_level: int) -> void:
    """Handle player level up - could auto-upgrade weapons"""
    # Increase attack speed slightly
    base_attack_interval = max(0.3, base_attack_interval * 0.98)

# === WEAPON STATISTICS ===
func get_weapon_stats() -> Dictionary:
    """Get current weapon statistics"""
    var stats = {
        "active_weapons": active_weapons.size(),
        "attack_interval": base_attack_interval,
        "auto_attack": auto_attack_enabled,
        "cached_weapons": weapon_data_cache.size()
    }
    
    return stats

func get_total_dps() -> float:
    """Calculate total damage per second"""
    var total_dps = 0.0
    
    for weapon in active_weapons:
        if is_instance_valid(weapon) and weapon.has_method("get_dps"):
            total_dps += weapon.get_dps()
    
    return total_dps