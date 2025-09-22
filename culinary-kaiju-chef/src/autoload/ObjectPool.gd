# ObjectPool.gd
extends Node

var pool: Dictionary = {}

# 預先填充池，可在遊戲加載時呼叫
func pre_populate(scene: PackedScene, count: int) -> void:
    if not pool.has(scene):
        pool[scene] = []
    for i in range(count):
        var instance = scene.instantiate()
        instance.name = scene.resource_path.get_file().split(".")[0] + "_" + str(i)
        pool[scene].append(instance)
        # 確保物件在被取出前是不可見和不處理的
        instance.get_parent().remove_child(instance) if instance.get_parent() else pass
        instance.set_process(false)
        instance.set_physics_process(false)
        instance.hide()

# 從池中請求一個物件
func request(scene: PackedScene) -> Node:
    if not pool.has(scene) or pool[scene].is_empty():
        # 如果池為空，動態創建一個，但這應該盡量避免
        return scene.instantiate()

    var instance = pool[scene].pop_front()
    return instance

# 將物件返回池中
func reclaim(instance: Node) -> void:
    var scene = instance.scene_file_path
    if not pool.has(scene):
        pool[scene] = []

    # 確保物件的父節點是 null，否則下次添加會出錯
    instance.get_parent().remove_child(instance) if instance.get_parent() else pass

    # 重置狀態
    instance.set_process(false)
    instance.set_physics_process(false)
    instance.hide()

    # 你可能還需要呼叫一個 'reset_state()' 函數來重置物件的內部變數
    if instance.has_method("reset_state"):
        instance.reset_state()

    pool[scene].push_back(instance)

# 獲取池的統計信息
func get_pool_stats() -> Dictionary:
    var stats = {}
    for scene in pool:
        stats[scene.resource_path] = pool[scene].size()
    return stats

# 清空所有池
func clear_all_pools() -> void:
    pool.clear()
