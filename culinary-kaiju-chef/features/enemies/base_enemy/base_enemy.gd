# base_enemy.gd
extends Area2D
class_name BaseEnemy

@export var data: EnemyData
@export var xp_gem_scene: PackedScene # You will need to assign the XPGem scene in the editor

var health: int
var speed: float
var velocity: Vector2 = Vector2.ZERO
var target: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # This assumes the player is in a group named "player"
    target = get_tree().get_first_node_in_group("player")

func initialize(pos: Vector2, enemy_data: EnemyData) -> void:
    self.global_position = pos
    self.data = enemy_data
    if data:
        self.health = data.health
        self.speed = data.speed
    
    # Enable processing and visibility
    set_physics_process(true)
    show()

func _physics_process(delta: float) -> void:
    if not is_instance_valid(target):
        return

    # 1. Calculate direction towards the player
    var direction_to_target = (target.global_position - self.global_position).normalized()
    velocity = direction_to_target * speed

    # 2. (Optional but recommended) Calculate separation force to avoid clumping
    # This is a performance-intensive check, so we stagger it across multiple frames.
    if Engine.get_physics_frames() % 4 == get_instance_id() % 4:
        var separation_vector = _get_separation_vector()
        velocity += separation_vector * 0.5 # Adjust weight as needed

    # 3. Apply manual movement
    global_position += velocity * delta

func _get_separation_vector() -> Vector2:
    # This is the core of manual collision avoidance using the physics server directly.
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsShapeQueryParameters2D.new()
    var query_shape = CircleShape2D.new()
    query_shape.radius = 40 # Query radius should be larger than the collision shape
    
    query.shape_rid = query_shape.get_rid()
    query.transform = global_transform
    query.collision_mask = self.collision_layer # Only check against other enemies on the same layer
    query.exclude = [self.get_rid()]

    var results: Array[Dictionary] = space_state.intersect_shape(query)
    var push_vector: Vector2 = Vector2.ZERO
    if not results.is_empty():
        for result in results:
            var neighbor = result.get("collider")
            if is_instance_valid(neighbor):
                push_vector += (global_position - neighbor.global_position).normalized()
    
    return push_vector

func take_damage(amount: int) -> void:
    health -= amount
    # TODO: Trigger a hit flash effect here
    if health <= 0:
        die()

func die() -> void:
    # Spawn an XP gem from the pool
    if xp_gem_scene:
        var gem = ObjectPool.request(xp_gem_scene)
        get_tree().get_root().add_child(gem)
        gem.global_position = self.global_position

    # Then, reclaim this instance to the object pool.
    ObjectPool.reclaim(self)

func reset_state() -> void:
    # Reset all variables for reuse when requested from the object pool.
    self.velocity = Vector2.ZERO
    self.health = 0
    self.speed = 0
    self.data = null
