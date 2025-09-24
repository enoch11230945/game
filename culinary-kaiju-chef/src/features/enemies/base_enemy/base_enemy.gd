# features/enemies/base_enemy/base_enemy.gd
extends Area2D

@export var data: EnemyData

var health: int
var speed: float
var velocity: Vector2 = Vector2.ZERO
var target: Node2D

# For separation behavior
var separation_query: PhysicsShapeQueryParameters2D
var separation_shape: CircleShape2D

func _ready() -> void:
    # Set collision layers
    set_collision_layer_value(3, true) # enemies
    set_collision_mask_value(4, true) # player_weapons
    
    target = get_tree().get_first_node_in_group("player")

    # Prepare the query for separation behavior
    separation_query = PhysicsShapeQueryParameters2D.new()
    separation_shape = CircleShape2D.new()
    separation_shape.radius = 40 # Query radius, should be larger than the collision shape
    separation_query.shape = separation_shape
    separation_query.collision_mask = self.collision_layer # Only query other enemies
    separation_query.exclude = [self.get_rid()]

func initialize(pos: Vector2, enemy_data: EnemyData) -> void:
    self.global_position = pos
    self.data = enemy_data
    if self.data:
        self.health = data.health
        self.speed = data.speed
    
    set_physics_process(true)
    show()

func _physics_process(delta: float) -> void:
    if not is_instance_valid(target):
        velocity = Vector2.ZERO
        return

    # 1. Calculate direction towards the player
    var direction_to_target = (target.global_position - self.global_position).normalized()
    var target_velocity = direction_to_target * speed

    # 2. Calculate separation vector
    # This is the key to prevent clumping. We run it every few frames for performance.
    var separation_velocity = Vector2.ZERO
    if Engine.get_physics_frames() % 4 == get_instance_id() % 4:
        separation_velocity = _get_separation_vector() * speed * 0.5 # Adjust weight

    # 3. Combine velocities and move
    velocity = target_velocity + separation_velocity
    global_position += velocity * delta

func _get_separation_vector() -> Vector2:
    # Use the direct space state for a high-performance query
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

func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        die()

func die() -> void:
    ObjectPool.reclaim(self)

func reset_state() -> void:
    velocity = Vector2.ZERO
    health = 0
    speed = 0
    data = null
