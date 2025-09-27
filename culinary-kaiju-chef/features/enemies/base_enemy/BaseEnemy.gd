# BaseEnemy.gd
extends Area2D
class_name BaseEnemy

@export var data: Resource

var health: int
var speed: float
var velocity: Vector2 = Vector2.ZERO
var target: Node2D
var xp_gem_scene: PackedScene
static var _sep_shape: CircleShape2D = CircleShape2D.new()
var _cached_sep: Vector2 = Vector2.ZERO
var _cached_sep_ttl: int = 0

# Cached components
var sprite: Sprite2D
var collision_shape: CollisionShape2D

func _ready() -> void:
    # Load XP gem scene dynamically
    xp_gem_scene = preload("res://features/items/xp_gem/XPGem.tscn")
    
    # Cache component references
    sprite = $Sprite2D
    collision_shape = $CollisionShape2D
    
    # Find player target
    target = get_tree().get_first_node_in_group("player")
    
    # Add to enemies group
    add_to_group("enemies")

func initialize(pos: Vector2, enemy_data: Resource) -> void:
    self.global_position = pos
    self.data = enemy_data
    
    if data:
        health = data.health
        speed = data.speed
        
        # Apply visual properties
        if sprite and data.sprite_texture:
            sprite.texture = data.sprite_texture
        
        if sprite:
            sprite.scale = data.sprite_scale
            sprite.modulate = data.sprite_modulate
    
    # Enable processing and visibility
    set_physics_process(true)
    show()

func _physics_process(delta: float) -> void:
    if not is_instance_valid(target):
        return
    
    # 1. Calculate direction towards the player
    var direction_to_target = (target.global_position - self.global_position).normalized()
    # 行為層：速度基礎
    velocity = direction_to_target * speed
    # Speed Demon wobble
    if data and data.wobble_amplitude > 0.0 and data.wobble_frequency > 0.0:
        var t = Time.get_ticks_msec() / 1000.0
        var perp = Vector2(-direction_to_target.y, direction_to_target.x)
        velocity += perp * data.wobble_amplitude * sin(t * data.wobble_frequency + float(get_instance_id() % 1024))
    # Tank Brute charge
    if data and data.charge_interval > 0.1 and data.charge_multiplier > 1.0 and data.charge_duration > 0.05:
        var phase = fmod(Time.get_ticks_msec()/1000.0, data.charge_interval)
        if phase < data.charge_duration:
            velocity += direction_to_target * speed * (data.charge_multiplier - 1.0)
    
    # 2. (Performance Optimization) Calculate separation force to avoid clumping
    # This is staggered across frames to maintain 60fps with hundreds of enemies
    if _cached_sep_ttl <= 0 and Engine.get_physics_frames() % 4 == get_instance_id() % 4:
        _cached_sep = _compute_separation_vector()
        _cached_sep_ttl = 3
    if _cached_sep_ttl > 0:
        _cached_sep_ttl -= 1
        velocity += _cached_sep * (data.separation_strength if data else 0.5)
    
    # 3. Apply manual movement - this is the core of our "good taste" architecture
    global_position += velocity * delta
    
    # 4. Update sprite facing direction
    if sprite and velocity.x != 0:
        sprite.scale.x = abs(sprite.scale.x) * (-1 if velocity.x < 0 else 1)

func _compute_separation_vector() -> Vector2:
    var space_state = get_world_2d().direct_space_state
    _sep_shape.radius = data.separation_radius if data else 40.0
    var query = PhysicsShapeQueryParameters2D.new()
    query.shape_rid = _sep_shape.get_rid()
    query.transform = global_transform
    query.collision_mask = collision_layer
    query.exclude = [self.get_rid()]
    var results: Array[Dictionary] = space_state.intersect_shape(query)
    var push: Vector2 = Vector2.ZERO
    for result in results:
        var neighbor = result.get("collider")
        if is_instance_valid(neighbor) and neighbor != self:
            push += (global_position - neighbor.global_position).normalized()
    return push

func take_damage(amount: int) -> void:
    health -= amount
    
    # Trigger hit effect (could add screen shake, particles, etc.)
    if sprite:
        # Simple hit flash
        sprite.modulate = Color.WHITE
        var tween = create_tween()
        tween.tween_property(sprite, "modulate", data.sprite_modulate if data else Color.WHITE, 0.1)
    
    # Check for death
    if health <= 0:
        # Use call_deferred to avoid physics conflicts during collision detection
        call_deferred("die")

func die() -> void:
    # Spawn XP gem at death location
    if xp_gem_scene:
        var gem = ObjectPool.request(xp_gem_scene)
        var collect_layer = get_tree().get_first_node_in_group("collectables_layer")
        if collect_layer:
            collect_layer.add_child(gem)
        else:
            get_tree().get_root().add_child(gem)
        gem.global_position = self.global_position
        
        # Initialize gem if it has an initialize method
        if gem.has_method("initialize"):
            gem.initialize(data.xp_reward if data else 5)
    
    # Notify game systems
    EventBus.enemy_killed.emit(self, data.xp_reward if data else 5)
    Game.score += (data.xp_reward if data else 5)
    
    # Return to object pool instead of queue_free()
    ObjectPool.reclaim(self)

func reset_state() -> void:
    # Reset all variables for reuse when requested from object pool
    velocity = Vector2.ZERO
    health = 0
    speed = 0
    data = null
    target = null
    
    # Reset visual state
    if sprite:
        sprite.modulate = Color.WHITE
        sprite.scale = Vector2.ONE