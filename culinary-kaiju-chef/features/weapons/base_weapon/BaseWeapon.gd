# BaseWeapon.gd
extends Node2D
class_name BaseWeapon

@export var weapon_data: Resource

var player: Node2D
var projectile_scene: PackedScene
var _cooldown_accumulator: float = 0.0
var fired_count: int = 0
var total_damage_dealt: int = 0
var attacks_performed: int = 0  # Add missing variable

func _ready() -> void:
    projectile_scene = preload("res://features/weapons/base_weapon/BaseProjectile.tscn")

    # 監聽武器升級事件（集中 Data 驅動）
    if EventBus.has_signal("upgrade_selected"):
        EventBus.upgrade_selected.connect(apply_upgrade)

func initialize(player_ref: Node2D, weapon_data_ref: Resource) -> void:
    player = player_ref
    weapon_data = weapon_data_ref
    _cooldown_accumulator = 0.0

func _process(delta: float) -> void:
    if not player or not weapon_data:
        return
    _cooldown_accumulator += delta
    while _cooldown_accumulator >= weapon_data.cooldown:
        _cooldown_accumulator -= weapon_data.cooldown
        attack()

func attack() -> void:
    if not player or not weapon_data:
        return
    
    # Calculate attack directions based on projectile count and spread
    var directions: Array[Vector2] = []
    
    if weapon_data.projectile_count == 1:
        # Single projectile - find nearest enemy or use default direction
        directions.append(_get_best_attack_direction())
    else:
        # Multiple projectiles - spread them evenly
        var base_direction = _get_best_attack_direction()
        var spread_rad = deg_to_rad(weapon_data.spread_angle)
        var angle_step = spread_rad / (weapon_data.projectile_count - 1) if weapon_data.projectile_count > 1 else 0
        var start_angle = -spread_rad / 2
        
        for i in range(weapon_data.projectile_count):
            var angle = start_angle + (i * angle_step)
            var rotated_direction = base_direction.rotated(angle)
            directions.append(rotated_direction)
    
    # Fire all projectiles
    for direction in directions:
        _fire_projectile(direction)
    
    fired_count += directions.size()
    EventBus.weapon_fired.emit(weapon_data.weapon_name, player.global_position, Vector2.ZERO)

func _fire_projectile(direction: Vector2) -> void:
    """Fire a single projectile using ObjectPool - Linus approved"""
    var projectile = ObjectPool.get_projectile(projectile_scene)
    if not projectile:
        print("❌ Failed to get projectile from pool")
        return
    
    # Add to scene tree
    get_tree().get_root().add_child(projectile)
    
    # Initialize projectile with weapon data
    if projectile.has_method("initialize"):
        projectile.initialize(player.global_position, direction, weapon_data)
    
    # Connect hit signal for damage tracking
    if projectile.has_signal("enemy_hit"):
        projectile.enemy_hit.connect(_on_projectile_hit)

func _get_best_attack_direction() -> Vector2:
    """Find the best direction to attack (towards nearest enemy)"""
    var enemies = get_tree().get_nodes_in_group("enemies")
    if enemies.is_empty():
        return Vector2.RIGHT  # Default direction if no enemies
    
    var nearest_enemy = null
    var nearest_distance = INF
    
    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        var distance = player.global_position.distance_to(enemy.global_position)
        if distance < nearest_distance:
            nearest_distance = distance
            nearest_enemy = enemy
    
    if nearest_enemy:
        return (nearest_enemy.global_position - player.global_position).normalized()
    else:
        return Vector2.RIGHT

func _on_projectile_hit(enemy: Node, damage: int):
    """Track damage dealt by our projectiles"""
    total_damage_dealt += damage

func apply_upgrade(upgrade_data: Resource):
    """Apply upgrade to this weapon - data driven"""
    if not upgrade_data or not weapon_data:
        return
    
    # This would be implemented based on your upgrade system
    print("Weapon %s applying upgrade: %s" % [weapon_data.weapon_name, upgrade_data])

func _fire_spread_attack(base_direction: Vector2, count: int, angle_spread: float):
    """Fire multiple projectiles in a spread pattern"""
    var directions: Array[Vector2] = []
    
    if count == 1:
        directions.append(base_direction)
    else:
        var start_angle = -angle_spread / 2.0
        var angle_step = angle_spread / (count - 1)
        
        for i in range(count):
            var angle = start_angle + (angle_step * i)
            var direction = base_direction.rotated(angle)
            directions.append(direction)
    
    # Fire projectiles in all calculated directions
    for direction in directions:
        _fire_projectile(direction)
    fired_count += directions.size()

func get_weapon_stats() -> Dictionary:
    """Get current weapon statistics"""
    if not weapon_data:
        return {}
    
    return {
        "name": weapon_data.weapon_name,
        "damage": weapon_data.damage,
        "cooldown": weapon_data.cooldown,
        "range": weapon_data.range,
        "projectile_count": weapon_data.projectile_count,
        "total_damage_dealt": total_damage_dealt,
        "attacks_performed": attacks_performed
    }
    
    return {
        "name": weapon_data.name,
        "damage": weapon_data.damage,
        "cooldown": weapon_data.cooldown,
        "projectile_count": weapon_data.projectile_count,
        "piercing": weapon_data.piercing
    }