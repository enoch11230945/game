# base_enemy.gd
extends Area2D

class_name BaseEnemy

@export var data: EnemyData

var health: int
var speed: float
var damage: int
var xp_value: int
var velocity: Vector2 = Vector2.ZERO
var target: Node2D
var separation_strength: float

# 緩存的引用，避免重複獲取
var _space_state: PhysicsDirectSpaceState2D
var _last_separation_update: int = 0

func _ready() -> void:
    # 獲取空間狀態引用
    _space_state = get_world_2d().direct_space_state

    # 獲取玩家引用
    target = get_tree().get_first_node_in_group("player")

    # 設置碰撞層
    collision_layer = 3  # enemies
    collision_mask = 4    # player_weapons

    # 連接信號
    area_entered.connect(_on_area_entered)

func initialize(pos: Vector2, enemy_data: EnemyData) -> void:
    self.global_position = pos
    self.data = enemy_data
    self.health = data.health
    self.speed = data.speed
    self.damage = data.damage
    self.xp_value = data.xp_value
    self.separation_strength = data.separation_strength

    # 啟用處理
    set_physics_process(true)
    show()

func _physics_process(delta: float) -> void:
    if not is_instance_valid(target):
        return

    # 1. 計算朝向玩家的方向
    var direction = (target.global_position - global_position).normalized()
    velocity = direction * speed

    # 2. 計算分離行為（每4幀更新一次以優化性能）
    if Engine.get_physics_frames() % 4 == get_instance_id() % 4:
        var separation_vector = _get_separation_vector()
        velocity += separation_vector * separation_strength

    # 3. 手動移動
    global_position += velocity * delta

func _get_separation_vector() -> Vector2:
    # 創建圓形查詢形狀
    var query = PhysicsShapeQueryParameters2D.new()
    query.shape = CircleShape2D.new()
    query.shape.radius = 40.0  # 查詢半徑，應大於碰撞形狀
    query.transform = global_transform
    query.collision_mask = 3  # 只查詢敵人層
    query.exclude = [self.get_rid()]

    var results: Array = _space_state.intersect_shape(query)
    var push_vector: Vector2 = Vector2.ZERO

    if not results.is_empty():
        for result in results:
            var neighbor = result.collider
            if neighbor != self:
                var distance = global_position.distance_to(neighbor.global_position)
                if distance > 0:
                    push_vector += (global_position - neighbor.global_position).normalized() / distance

    return push_vector

func _on_area_entered(area: Area2D) -> void:
    # 檢查是否被玩家武器擊中
    if area.collision_layer == 4:  # player_weapons
        take_damage(area.get_parent().damage)

func take_damage(amount: int) -> void:
    health -= amount

    # 可以在此處觸發閃爍效果
    if health <= 0:
        die()

func die() -> void:
    # 發出敵人死亡事件
    EventBus.emit_enemy_died(global_position, xp_value)

    # 播放死亡特效（如果有的話）

    # 將自己還給物件池
    ObjectPool.reclaim(self)

func reset_state() -> void:
    # 重置所有變數，為下次使用做準備
    self.velocity = Vector2.ZERO
    self.health = 0
    self.data = null
    self.target = null
    hide()
    set_physics_process(false)
