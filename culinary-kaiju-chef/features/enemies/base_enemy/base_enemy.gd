# features/enemies/base_enemy/base_enemy.gd
extends Area2D

const XpGemScene = preload("res://features/items/xp_gem/xp_gem.tscn")
const HitFlashShader = preload("res://assets/shaders/hit_flash.gdshader")

@export var data: EnemyData

var health: int = 10
var speed: float = 150.0
var damage: int = 5
var velocity: Vector2 = Vector2.ZERO
var target: Node2D

var separation_query: PhysicsShapeQueryParameters2D
var separation_shape: CircleShape2D

@onready var sprite = $Sprite2D

func _ready():
    set_collision_layer_value(3, true)
    set_collision_mask_value(4, true)
    
    target = get_tree().get_first_node_in_group("player")

    separation_query = PhysicsShapeQueryParameters2D.new()
    separation_shape = CircleShape2D.new()
    separation_shape.radius = 40
    separation_query.shape = separation_shape
    separation_query.collision_mask = self.collision_layer
    separation_query.exclude = [self.get_rid()]

    self.body_entered.connect(_on_body_entered)

    # Ensure the sprite has a ShaderMaterial for the hit flash effect
    if not sprite.material or not sprite.material is ShaderMaterial:
        sprite.material = ShaderMaterial.new()
    sprite.material.shader = HitFlashShader

func initialize(pos: Vector2, enemy_data):
    self.global_position = pos
    self.data = enemy_data

    # Handle both EnemyData objects and dictionaries
    if enemy_data is EnemyData:
        self.health = enemy_data.health
        self.speed = enemy_data.speed
        self.damage = enemy_data.damage
    elif enemy_data is Dictionary:
        self.health = enemy_data.get("health", 50)
        self.speed = enemy_data.get("speed", 100.0)
        self.damage = enemy_data.get("damage", 10)

    set_physics_process(true)
    show()

func _physics_process(delta: float):
    if not is_instance_valid(target):
        velocity = Vector2.ZERO
        return

    var direction_to_target = (target.global_position - self.global_position).normalized()
    var target_velocity = direction_to_target * speed

    var separation_velocity = Vector2.ZERO
    if Engine.get_physics_frames() % 4 == get_instance_id() % 4:
        separation_velocity = _get_separation_vector() * speed * 0.5

    velocity = target_velocity + separation_velocity
    global_position += velocity * delta

func _get_separation_vector() -> Vector2:
    var space_state = get_world_2d().direct_space_state
    separation_query.transform = global_transform
    var results: Array = space_state.intersect_shape(separation_query)
    var push_vector: Vector2 = Vector2.ZERO
    if not results.is_empty():
        for result in results:
            var neighbor = result.collider
            if is_instance_valid(neighbor):
                push_vector += (global_position - neighbor.global_position).normalized()
    return push_vector.normalized()

func take_damage(amount: int):
    health -= amount
    
    # Trigger the hit flash effect
    var tween = create_tween()
    tween.tween_property(sprite.material, "shader_parameter/flash_modifier", 1.0, 0.05)
    tween.tween_property(sprite.material, "shader_parameter/flash_modifier", 0.0, 0.1)

    if health <= 0:
        die()

func die():
    var gem = XpGemScene.instantiate()
    get_tree().current_scene.add_child(gem)
    gem.global_position = self.global_position
    ObjectPool.reclaim(self)

func reset_state():
    velocity = Vector2.ZERO
    health = 10
    speed = 150
    damage = 5
    data = null

func _on_body_entered(body: Node):
    if body.is_in_group("player"):
        if body.has_method("take_damage"):
            body.take_damage(damage)
            die()
