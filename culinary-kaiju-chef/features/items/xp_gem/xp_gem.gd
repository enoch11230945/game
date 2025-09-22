# xp_gem.gd
extends Area2D

class_name XPGem

@export var xp_value: int = 10
@export var collect_radius: float = 30.0
@export var move_speed: float = 200.0

var target: Node2D
var is_collected: bool = false

func _ready() -> void:
    # 設置碰撞層
    collision_layer = 5  # xp_gems
    collision_mask = 2    # player

    # 連接信號
    area_entered.connect(_on_area_entered)

    # 獲取玩家引用
    target = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
    if is_collected and target:
        # 向玩家移動
        var direction = (target.global_position - global_position).normalized()
        global_position += direction * move_speed * delta

        # 如果足夠接近，收集
        if global_position.distance_to(target.global_position) < 10.0:
            collect()

func _on_area_entered(area: Area2D) -> void:
    # 檢查是否被玩家收集器觸碰
    if area.collision_layer == 2:  # player
        collect()

func collect() -> void:
    if not is_collected:
        is_collected = true

        # 發出XP獲得事件
        EventBus.emit_player_gained_xp(xp_value)

        # 將自己還給物件池
        ObjectPool.reclaim(self)

func reset_state() -> void:
    is_collected = false
    target = null
    hide()
    set_physics_process(false)
