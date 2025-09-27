# BaseProjectile.gd
extends Area2D
class_name BaseProjectile

var damage: int = 10
var speed: float = 300.0
var direction: Vector2 = Vector2.RIGHT
var piercing: int = 0
var enemies_hit: int = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready() -> void:
    # Connect signals
    area_entered.connect(_on_area_entered)
    lifetime_timer.timeout.connect(_on_lifetime_timeout)

func initialize(pos: Vector2, dir: Vector2, weapon_data: Resource) -> void:
    global_position = pos
    direction = dir.normalized()
    
    if weapon_data:
        damage = weapon_data.damage
        speed = weapon_data.speed
        piercing = weapon_data.piercing
        lifetime_timer.wait_time = weapon_data.lifetime
        
        # Apply visual properties
        if sprite and weapon_data.projectile_texture:
            sprite.texture = weapon_data.projectile_texture
        
        if sprite:
            sprite.scale = weapon_data.projectile_scale
            sprite.modulate = weapon_data.projectile_modulate
    
    # Reset hit counter
    enemies_hit = 0
    
    # Enable processing and visibility
    set_physics_process(true)
    show()
    lifetime_timer.start()

func _physics_process(delta: float) -> void:
    global_position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
    # Check if the area is an enemy
    if area.has_method("take_damage"):
        area.take_damage(damage)
        # 回填武器傷害統計（若需要 HUD 顯示 DPS）
        if get_parent() and get_parent().get_parent():
            var maybe_weapon = get_parent().get_parent()
            if maybe_weapon is BaseWeapon:
                maybe_weapon.total_damage_dealt += damage
        enemies_hit += 1
        
        # Check if we should pierce or be destroyed
        if enemies_hit > piercing:
            call_deferred("_reclaim_self")

func _on_lifetime_timeout() -> void:
    call_deferred("_reclaim_self")

func _reclaim_self() -> void:
    # 停用邏輯再回收，避免殘留移動或碰撞信號
    set_physics_process(false)
    hide()
    ObjectPool.reclaim(self)

func reset_state() -> void:
    # Reset all variables for object pooling
    damage = 10
    speed = 300.0
    direction = Vector2.RIGHT
    piercing = 0
    enemies_hit = 0
    lifetime_timer.stop()
    
    if sprite:
        sprite.modulate = Color.WHITE
        sprite.scale = Vector2.ONE