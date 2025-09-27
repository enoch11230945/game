# ObjectPool.gd
extends Node

var pool: Dictionary = {}
var debug_mode: bool = false

# Pre-populate the pool, can be called during game loading
func pre_populate(scene: PackedScene, count: int) -> void:
    if not pool.has(scene):
        pool[scene] = []
    
    for i in range(count):
        var instance = scene.instantiate()
        instance.name = scene.resource_path.get_file().split(".")[0] + "_pooled_" + str(i)
        
        # Ensure the object is not visible or processed before being requested
        if instance.get_parent():
            instance.get_parent().remove_child(instance)
        
        _reset_node_state(instance)
        pool[scene].append(instance)
    
    if debug_mode:
        print("Pre-populated pool with ", count, " instances of ", scene.resource_path)

# Request an object from the pool
func request(scene: PackedScene) -> Node:
    if not pool.has(scene) or pool[scene].is_empty():
        # If the pool is empty, create a new one dynamically
        var instance = scene.instantiate()
        if debug_mode:
            print("Pool miss: Created new instance of ", scene.resource_path)
        return instance
    
    var instance = pool[scene].pop_front()
    if debug_mode:
        print("Pool hit: Retrieved instance of ", scene.resource_path, " (", pool[scene].size(), " remaining)")
    
    return instance

# Return an object to the pool
func reclaim(instance: Node) -> void:
    if not instance or not is_instance_valid(instance):
        if debug_mode:
            print("Attempted to reclaim invalid instance")
        return
    
    var scene_path = instance.scene_file_path
    if scene_path.is_empty():
        # This can happen if the node was created procedurally
        instance.queue_free()
        if debug_mode:
            print("Freed procedurally created node (no scene path)")
        return
    
    # Find the scene resource from our pool keys
    var matching_scene = null
    for scene in pool.keys():
        if scene.resource_path == scene_path:
            matching_scene = scene
            break
    
    if not matching_scene:
        # If we can't find the scene, just free the instance
        instance.queue_free()
        if debug_mode:
            print("Freed instance with unknown scene path: ", scene_path)
        return
    
    if not pool.has(matching_scene):
        pool[matching_scene] = []
    
    # Ensure the object has no parent
    if instance.get_parent():
        instance.get_parent().remove_child(instance)
    
    # Reset state
    _reset_node_state(instance)
    
    # Call a reset function if it exists to clean up internal state
    if instance.has_method("reset_state"):
        instance.reset_state()
    
    pool[matching_scene].push_back(instance)
    
    if debug_mode:
        print("Reclaimed instance to pool (", pool[matching_scene].size(), " total)")

func _reset_node_state(instance: Node) -> void:
    instance.set_process(false)
    instance.set_physics_process(false)
    instance.hide()
    
    # Reset position if it's a Node2D
    if instance is Node2D:
        instance.position = Vector2.ZERO
        instance.rotation = 0.0
        instance.scale = Vector2.ONE

# Get pool statistics for debugging
func get_pool_stats() -> Dictionary:
    var stats = {}
    for scene in pool.keys():
        stats[scene.resource_path] = pool[scene].size()
    return stats

# Clear all pools (useful for cleanup)
func clear_all_pools() -> void:
    for scene in pool.keys():
        for instance in pool[scene]:
            if is_instance_valid(instance):
                instance.queue_free()
    pool.clear()
    if debug_mode:
        print("Cleared all object pools")