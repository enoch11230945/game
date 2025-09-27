# ObjectPool.gd - High-performance object pooling (Linus-approved)
# "Object pooling is mandatory for mobile games - no compromises" - Linus
extends Node

# === POOL STORAGE ===
var pools: Dictionary = {}
var pool_parents: Dictionary = {}

# === POOL CONFIGURATION ===
var default_pool_sizes = {
    "projectile": 200,
    "enemy": 100,
    "xp_gem": 150,
    "damage_number": 50,
    "particle_effect": 100,
    "area_weapon": 50
}

func _ready():
    print("🏊 ObjectPool initialized - Performance optimization active")
    setup_default_pools()

func setup_default_pools():
    """Create default object pools"""
    for pool_name in default_pool_sizes:
        create_pool(pool_name, null, default_pool_sizes[pool_name])

func create_pool(pool_name: String, scene: PackedScene, initial_size: int = 10):
    """Create a new object pool"""
    if pools.has(pool_name):
        print("⚠️ Pool '%s' already exists" % pool_name)
        return
    
    pools[pool_name] = []
    pool_parents[pool_name] = Node2D.new()
    pool_parents[pool_name].name = "%s_Pool" % pool_name
    add_child(pool_parents[pool_name])
    
    # Pre-populate pool if scene provided
    if scene:
        for i in range(initial_size):
            var instance = scene.instantiate()
            instance.set_process(false)
            instance.set_physics_process(false)
            instance.visible = false
            pool_parents[pool_name].add_child(instance)
            pools[pool_name].append(instance)
    
    print("🏊 Created pool '%s' with %d objects" % [pool_name, initial_size])

func get_object(pool_name: String, scene: PackedScene = null) -> Node:
    """Get an object from the pool"""
    if not pools.has(pool_name):
        if scene:
            create_pool(pool_name, scene, 10)
        else:
            print("❌ Pool '%s' doesn't exist and no scene provided" % pool_name)
            return null
    
    var pool = pools[pool_name]
    
    # Find inactive object
    for obj in pool:
        if not obj.visible and not obj.process_mode == Node.PROCESS_MODE_DISABLED:
            continue
        if not is_object_active(obj):
            activate_object(obj)
            return obj
    
    # Pool exhausted, create new object if scene available
    if scene:
        var new_obj = scene.instantiate()
        pool_parents[pool_name].add_child(new_obj)
        pool.append(new_obj)
        activate_object(new_obj)
        print("📈 Pool '%s' expanded to %d objects" % [pool_name, pool.size()])
        return new_obj
    
    print("⚠️ Pool '%s' exhausted and no scene provided" % pool_name)
    return null

func return_object(pool_name: String, obj: Node):
    """Return an object to the pool"""
    if not pools.has(pool_name):
        print("❌ Pool '%s' doesn't exist" % pool_name)
        return
    
    if not pools[pool_name].has(obj):
        print("⚠️ Object not from pool '%s'" % pool_name)
        return
    
    deactivate_object(obj)

func is_object_active(obj: Node) -> bool:
    """Check if object is currently active"""
    return obj.visible and obj.process_mode != Node.PROCESS_MODE_DISABLED

func activate_object(obj: Node):
    """Activate an object from the pool"""
    obj.visible = true
    obj.set_process(true)
    obj.set_physics_process(true)
    obj.process_mode = Node.PROCESS_MODE_INHERIT
    
    # Reset common properties
    if obj.has_method("reset"):
        obj.reset()
    elif obj is Node2D:
        obj.position = Vector2.ZERO
        obj.rotation = 0.0
        obj.scale = Vector2.ONE
        obj.modulate = Color.WHITE

func deactivate_object(obj: Node):
    """Deactivate an object and return it to pool"""
    obj.visible = false
    obj.set_process(false)
    obj.set_physics_process(false)
    obj.process_mode = Node.PROCESS_MODE_DISABLED
    
    # Move to pool parent to avoid tree issues
    if obj.get_parent() != pool_parents.get(get_pool_name_for_object(obj)):
        var pool_name = get_pool_name_for_object(obj)
        if pool_name and pool_parents.has(pool_name):
            obj.reparent(pool_parents[pool_name])

func get_pool_name_for_object(obj: Node) -> String:
    """Find which pool an object belongs to"""
    for pool_name in pools:
        if pools[pool_name].has(obj):
            return pool_name
    return ""

# === CONVENIENCE FUNCTIONS FOR COMMON OBJECTS ===

func get_projectile(scene: PackedScene) -> Node:
    """Get a projectile from the pool"""
    return get_object("projectile", scene)

func return_projectile(obj: Node):
    """Return a projectile to the pool"""
    return_object("projectile", obj)

func get_enemy(scene: PackedScene) -> Node:
    """Get an enemy from the pool"""
    return get_object("enemy", scene)

func return_enemy(obj: Node):
    """Return an enemy to the pool"""
    return_object("enemy", obj)

func get_xp_gem(scene: PackedScene) -> Node:
    """Get an XP gem from the pool"""
    return get_object("xp_gem", scene)

func return_xp_gem(obj: Node):
    """Return an XP gem to the pool"""
    return_object("xp_gem", obj)

func get_damage_number(scene: PackedScene) -> Node:
    """Get a damage number display from the pool"""
    return get_object("damage_number", scene)

func return_damage_number(obj: Node):
    """Return a damage number to the pool"""
    return_object("damage_number", obj)

func get_particle_effect(scene: PackedScene) -> Node:
    """Get a particle effect from the pool"""
    return get_object("particle_effect", scene)

func return_particle_effect(obj: Node):
    """Return a particle effect to the pool"""
    return_object("particle_effect", obj)

# === POOL STATISTICS ===

func get_pool_stats() -> Dictionary:
    """Get statistics about all pools"""
    var stats = {}
    
    for pool_name in pools:
        var pool = pools[pool_name]
        var active_count = 0
        var inactive_count = 0
        
        for obj in pool:
            if is_object_active(obj):
                active_count += 1
            else:
                inactive_count += 1
        
        stats[pool_name] = {
            "total": pool.size(),
            "active": active_count,
            "inactive": inactive_count,
            "utilization": float(active_count) / float(pool.size()) * 100.0
        }
    
    return stats

func print_pool_stats():
    """Print pool statistics to console"""
    var stats = get_pool_stats()
    print("=== OBJECT POOL STATISTICS ===")
    
    for pool_name in stats:
        var pool_stats = stats[pool_name]
        print("%s: %d/%d active (%.1f%% utilization)" % [
            pool_name,
            pool_stats.active,
            pool_stats.total,
            pool_stats.utilization
        ])
    
    print("============================")

func cleanup_pools():
    """Clean up unused objects in pools"""
    for pool_name in pools:
        var pool = pools[pool_name]
        var original_size = pool.size()
        
        # Remove inactive objects beyond minimum size
        var min_size = default_pool_sizes.get(pool_name, 10)
        var inactive_objects = []
        
        for obj in pool:
            if not is_object_active(obj):
                inactive_objects.append(obj)
        
        # Keep only minimum required inactive objects
        while inactive_objects.size() > min_size and pool.size() > min_size:
            var obj_to_remove = inactive_objects.pop_back()
            pool.erase(obj_to_remove)
            obj_to_remove.queue_free()
        
        if pool.size() < original_size:
            print("🧹 Cleaned pool '%s': %d -> %d objects" % [pool_name, original_size, pool.size()])

# === BATCH OPERATIONS ===

func return_all_objects(pool_name: String):
    """Return all active objects in a pool"""
    if not pools.has(pool_name):
        return
    
    var pool = pools[pool_name]
    for obj in pool:
        if is_object_active(obj):
            deactivate_object(obj)
    
    print("🔄 Returned all objects in pool '%s'" % pool_name)

func clear_pool(pool_name: String):
    """Completely clear a pool"""
    if not pools.has(pool_name):
        return
    
    var pool = pools[pool_name]
    for obj in pool:
        obj.queue_free()
    
    pool.clear()
    print("🗑️ Cleared pool '%s'" % pool_name)

func reset_all_pools():
    """Reset all pools for new game"""
    for pool_name in pools:
        return_all_objects(pool_name)
    
    print("🔄 All pools reset for new game")