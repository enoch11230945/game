# base_projectile.gd
extends Area2D

class_name BaseProjectile

@export var speed: float = 300.0
@export var damage: int = 25
@export var lifetime: float = 5.0
@export var piercing: bool = false

var direction: Vector2 = Vector2.RIGHT
var velocity: Vector2 = Vector2.ZERO
var lifetime_timer: float = 0.0

func _ready() -> void:
    # 設置碰撞層
    collision_layer = 4  # player_weapons
    collision_mask = 3    # enemies

    # 連接信號
    area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
    # 更新生命週期
    lifetime_timer += delta
    if lifetime_timer >= lifetime:
        _die()

    # 移動
    velocity = direction * speed
    global_position += velocity * delta

func _on_area_entered(area: Area2D) -> void:
    # 檢查是否擊中敵人
    if area.collision_layer == 3:  # enemies
        var enemy = area.get_parent()
        if enemy and enemy.has_method("take_damage"):
            enemy.take_damage(damage)

        if not piercing:
            _die()

func _die() -> void:
    # 將自己還給物件池
    ObjectPool.reclaim(self)

func reset_state() -> void:
    lifetime_timer = 0.0
    direction = Vector2.RIGHT
    velocity = Vector2.ZERO
    hide()
    set_physics_process(false)
