# src/autoload/ObjectPool.gd
extends Node

var pool: Dictionary = {}

# Use the scene's resource path as the key for consistency
func pre_populate(scene: PackedScene, count: int) -> void:
    var scene_path = scene.resource_path
    if not pool.has(scene_path):
        pool[scene_path] = []
    for i in range(count):
        var instance = scene.instantiate()
        instance.name = scene.resource_path.get_file().split(".")[0] + "_" + str(i)
        pool[scene_path].append(instance)
        # This check is important for when the pool is populated on startup
        if instance.get_parent():
            instance.get_parent().remove_child(instance)

func request(scene: PackedScene) -> Node:
    var scene_path = scene.resource_path
    if not pool.has(scene_path) or pool[scene_path].is_empty():
        # If the pool is empty, dynamically create one, but this should be avoided.
        var new_instance = scene.instantiate()
        new_instance.scene_file_path = scene_path # Manually set the path for consistency
        return new_instance

    var instance = pool[scene_path].pop_front()
    # The instance is already parent-less and inactive from being reclaimed.
    # No need to change state here, the caller will do that.
    return instance

func reclaim(instance: Node) -> void:
    # scene_file_path is set automatically when a node is instanced from a scene.
    var scene_path = instance.scene_file_path
    if scene_path.is_empty():
        push_error("Cannot reclaim a node that was not instanced from a scene.")
        instance.queue_free() # Can't pool it, so just free it.
        return

    if not pool.has(scene_path):
        pool[scene_path] = []

    # Ensure the object is removed from the scene tree before pooling
    if instance.get_parent():
        instance.get_parent().remove_child(instance)

    # Reset state for reuse
    instance.set_process(false)
    instance.set_physics_process(false)
    instance.hide()
    if instance.has_method("reset_state"):
        instance.reset_state()

    pool[scene_path].push_back(instance)