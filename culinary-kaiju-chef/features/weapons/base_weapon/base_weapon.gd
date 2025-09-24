# base_weapon.gd
extends Node2D

class_name BaseWeapon

@export var weapon_data: WeaponData

var cooldown_timer: float = 0.0

func _ready() -> void:
    # 設置武器位置
    position = Vector2.ZERO

func initialize(data: WeaponData) -> void:
    self.weapon_data = data
    cooldown_timer = 0.0

func _process(delta: float) -> void:
    if cooldown_timer > 0:
        cooldown_timer -= delta

func can_fire() -> bool:
    return cooldown_timer <= 0

func fire() -> void:
    if not can_fire():
        return

    # 創建投射物
    var projectile_scene = weapon_data.projectile_scene
    if projectile_scene:
        var projectile = ObjectPool.request(projectile_scene) as BaseProjectile

        # 設置投射物位置和方向
        var fire_position = global_position
        var fire_direction = Vector2.RIGHT  # 預設方向，實際應該根據玩家朝向

        # 添加到場景樹
        get_tree().get_root().add_child(projectile)
        projectile.initialize(fire_position, weapon_data, fire_direction)

        # 設置冷卻時間
        cooldown_timer = weapon_data.cooldown

        # 發出武器發射事件
        EventBus.emit_weapon_fired(weapon_data, fire_position, fire_direction)

func reset_state() -> void:
    cooldown_timer = 0.0
