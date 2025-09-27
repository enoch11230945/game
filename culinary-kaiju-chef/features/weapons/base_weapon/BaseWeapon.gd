# BaseWeapon.gd
extends Node2D
class_name BaseWeapon

@export var weapon_data: Resource

var player: Node2D
var projectile_scene: PackedScene
var _cooldown_accumulator: float = 0.0

func _ready() -> void:
    projectile_scene = preload("res://features/weapons/base_weapon/BaseProjectile.tscn")

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
            var angle = start_angle + (angle_step * i)
            var direction = base_direction.rotated(angle)
            directions.append(direction)
    
    # Fire projectiles in all calculated directions
    for direction in directions:
        _fire_projectile(direction)

func _get_best_attack_direction() -> Vector2:
    # Find the nearest enemy
    var enemies = get_tree().get_nodes_in_group("enemies")
    var nearest_enemy: Node2D = null
    var min_distance = INF
    
    for enemy in enemies:
        if enemy is Node2D:
            var distance = player.global_position.distance_to(enemy.global_position)
            if distance < min_distance and distance <= weapon_data.range:
                min_distance = distance
                nearest_enemy = enemy
    
    if nearest_enemy:
        return (nearest_enemy.global_position - player.global_position).normalized()
    else:
        # Default to right direction if no enemies found
        return Vector2.RIGHT

func _fire_projectile(direction: Vector2) -> void:
    var projectile = ObjectPool.request(projectile_scene)
    if projectile:
        var projectile_layer = get_tree().get_first_node_in_group("projectiles_layer")
        if projectile_layer:
            projectile_layer.add_child(projectile)
        else:
            get_tree().get_root().add_child(projectile)
        var spawn_offset = direction * 20
        projectile.initialize(player.global_position + spawn_offset, direction, weapon_data)
        EventBus.weapon_fired.emit(self, projectile)

func get_weapon_stats() -> Dictionary:
    if not weapon_data:
        return {}
    
    return {
        "name": weapon_data.name,
        "damage": weapon_data.damage,
        "cooldown": weapon_data.cooldown,
        "projectile_count": weapon_data.projectile_count,
        "piercing": weapon_data.piercing
    }