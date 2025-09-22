# player.gd
extends CharacterBody2D

class_name Player

@export var character_data: CharacterData
@export var speed: float = 200.0
@export var health: int = 100
@export var max_health: int = 100

# XP系統
var current_xp: int = 0
var current_level: int = 1
var xp_to_next_level: int = 100

# 武器系統
var weapons: Array[WeaponData] = []
var current_weapon_index: int = 0
var weapon_cooldowns: Dictionary = {}

# 狀態
var is_alive: bool = true

func _ready() -> void:
    # 添加到玩家群組
    add_to_group("player")

    # 設置碰撞層
    collision_layer = 2  # player
    collision_mask = 1    # world

    # 連接事件總線
    EventBus.player_gained_xp.connect(_on_xp_gained)

    # 初始化武器系統
    if weapons.is_empty():
        var throwing_knife_data = load("res://features/weapons/weapon_data/throwing_knife.tres")
        weapons.append(throwing_knife_data)

    # 應用角色數據
    if character_data:
        speed = character_data.speed
        health = character_data.health
        max_health = character_data.health

func _physics_process(delta: float) -> void:
    if not is_alive:
        return

    # 處理移動
    var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input_vector * speed
    move_and_slide()

    # 處理武器發射
    _handle_weapon_firing(delta)

func _handle_weapon_firing(delta: float) -> void:
    if weapons.is_empty():
        return

    var current_weapon = weapons[current_weapon_index]
    var cooldown_key = current_weapon.name

    # 更新冷卻時間
    if weapon_cooldowns.has(cooldown_key):
        weapon_cooldowns[cooldown_key] -= delta
        if weapon_cooldowns[cooldown_key] <= 0:
            weapon_cooldowns.erase(cooldown_key)

    # 檢查是否可以發射
    if weapon_cooldowns.has(cooldown_key):
        return

    # 發射武器
    _fire_weapon(current_weapon)

    # 設置冷卻時間
    weapon_cooldowns[cooldown_key] = current_weapon.cooldown

func _fire_weapon(weapon_data: WeaponData) -> void:
    # 創建投射物實例
    var projectile_scene = weapon_data.projectile_scene
    if projectile_scene:
        var projectile = ObjectPool.request(projectile_scene) as Area2D

        # 設置投射物位置和方向
        projectile.global_position = global_position
        projectile.direction = Vector2.RIGHT  # 預設方向，實際應該根據玩家朝向

        # 設置傷害
        projectile.damage = weapon_data.damage

        # 添加到場景樹
        get_tree().get_root().add_child(projectile)

        # 發出武器發射事件
        EventBus.emit_weapon_fired(weapon_data, global_position, Vector2.RIGHT)

func _on_xp_gained(amount: int) -> void:
    current_xp += amount
    PlayerData.total_xp_gained += amount

    # 檢查是否升級
    if current_xp >= xp_to_next_level:
        _level_up()

func _level_up() -> void:
    current_level += 1
    current_xp -= xp_to_next_level

    # 增加下次升級所需XP
    xp_to_next_level = int(xp_to_next_level * 1.2)

    # 發出升級事件
    EventBus.emit_player_level_up(current_level)

    # 暫停遊戲以顯示升級畫面
    Game.pause_game()

func take_damage(amount: int) -> void:
    health -= amount
    EventBus.emit_player_took_damage(amount)

    if health <= 0:
        die()

func die() -> void:
    is_alive = false
    # 發出遊戲結束事件
    Game._end_game(false)

func heal(amount: int) -> void:
    health = min(health + amount, max_health)

func get_current_weapon() -> WeaponData:
    if weapons.is_empty():
        return null
    return weapons[current_weapon_index]

func add_weapon(weapon_data: WeaponData) -> void:
    weapons.append(weapon_data)

func switch_weapon(index: int) -> void:
    if index >= 0 and index < weapons.size():
        current_weapon_index = index
