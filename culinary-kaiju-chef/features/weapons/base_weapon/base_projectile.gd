# base_projectile.gd
extends Area2D
class_name BaseProjectile

var speed: float = 400.0
var damage: int = 10
var direction: Vector2 = Vector2.RIGHT

# The projectile needs a child Timer node named "LifetimeTimer"
@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready() -> void:
    # Connect signals once. They will persist when pooled.
    area_entered.connect(_on_area_entered)
    lifetime_timer.timeout.connect(_on_lifetime_timeout)

func initialize(pos: Vector2, dir: Vector2, weapon_data: WeaponData) -> void:
    global_position = pos
    direction = dir
    if weapon_data:
        damage = weapon_data.damage
        speed = weapon_data.speed
    
    set_physics_process(true)
    show()
    lifetime_timer.start()

func _physics_process(delta: float) -> void:
    global_position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
    # Check if the area is an enemy
    if area is BaseEnemy:
        area.take_damage(damage)
        # Reclaim the projectile after it hits an enemy
        ObjectPool.reclaim(self)

func _on_lifetime_timeout() -> void:
    # Reclaim the projectile when its life is over to prevent memory leaks
    ObjectPool.reclaim(self)

func reset_state() -> void:
    # Reset variables for object pooling. No need to handle signals here.
    speed = 400.0
    damage = 10
    direction = Vector2.RIGHT
    lifetime_timer.stop()
