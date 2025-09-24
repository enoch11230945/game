# ObjectPool.gd
extends Node

var pool: Dictionary = {}

# Pre-populate the pool, can be called during game loading
func pre_populate(scene: PackedScene, count: int) -> void:
    if not pool.has(scene):
        pool[scene] = []
    for i in range(count):
        var instance = scene.instantiate()
        instance.name = scene.resource_path.get_file().split(".")[0] + "_" + str(i)
        pool[scene].append(instance)
        # Ensure the object is not visible or processed before being requested
        if instance.get_parent():
            instance.get_parent().remove_child(instance)
        instance.set_process(false)
        instance.set_physics_process(false)
        instance.hide()


# Request an object from the pool
func request(scene: PackedScene) -> Node:
    if not pool.has(scene) or pool[scene].is_empty():
        # If the pool is empty, create a new one dynamically, but this should be avoided
        return scene.instantiate()

    var instance = pool[scene].pop_front()
    return instance

# Return an object to the pool
func reclaim(instance: Node) -> void:
    if not instance or not is_instance_valid(instance):
        return

    var scene_path = instance.scene_file_path
    if scene_path.is_empty():
        # This can happen if the node was created procedurally, not from a scene.
        # We can't pool it without a scene reference.
        instance.queue_free()
        return

    if not pool.has(scene_path):
        pool[scene_path] = []

    # Ensure the object has no parent, otherwise adding it again will cause errors
    if instance.get_parent():
        instance.get_parent().remove_child(instance)

    # Reset state
    instance.set_process(false)
    instance.set_physics_process(false)
    instance.hide()
    
    # Call a reset function if it exists to clean up internal state
    if instance.has_method("reset_state"):
        instance.reset_state()

    pool[scene_path].push_back(instance)