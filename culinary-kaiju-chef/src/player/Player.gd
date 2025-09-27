# Player.gd
extends CharacterBody2D
class_name Player

@export var character_data: Resource
@export var starting_weapon_data: Resource

var max_health: int = 100
var current_health: int = 100
var movement_speed: float = 300.0

# Equipment
var weapons: Array = []

# Components
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var camera: Camera2D = $Camera2D
@onready var xp_collector: Area2D = $XPCollector

func _ready() -> void:
    # Initialize from character data
    if character_data:
        max_health = character_data.max_health
        current_health = max_health
        movement_speed = character_data.movement_speed
        
        if sprite and character_data.sprite_texture:
            sprite.texture = character_data.sprite_texture
            sprite.scale = character_data.sprite_scale
            sprite.modulate = character_data.sprite_modulate
    
    # Add to player group for targeting
    add_to_group("player")
    
    # Connect XP collection
    if xp_collector:
        xp_collector.area_entered.connect(_on_xp_collector_area_entered)
    
    # Load starting weapon
    if not starting_weapon_data:
        starting_weapon_data = DataManager.get_weapon("Throwing Knife")
    if starting_weapon_data:
        equip_weapon(starting_weapon_data)
    
    # Connect to game events
    EventBus.player_health_changed.emit(current_health, max_health)

func _physics_process(delta: float) -> void:
    # Handle movement
    var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    
    # Apply character data multipliers if available
    var actual_speed = movement_speed
    if character_data:
        actual_speed *= character_data.speed_multiplier
    
    velocity = input_direction * actual_speed
    move_and_slide()
    
    # Update sprite facing direction
    if velocity.x != 0 and sprite:
        sprite.scale.x = abs(sprite.scale.x) * (1 if velocity.x > 0 else -1)

func equip_weapon(weapon_data: Resource) -> void:
    # Create weapon instance
    var weapon_scene = preload("res://features/weapons/base_weapon/BaseWeapon.tscn")
    var weapon_instance = weapon_scene.instantiate()
    add_child(weapon_instance)
    
    # Initialize weapon
    if weapon_instance.has_method("initialize"):
        # Apply character multipliers to weapon data if available
        var modified_weapon_data = weapon_data
        if character_data:
            # We could create a modified copy here, but for now just pass original
            pass
        
        weapon_instance.initialize(self, modified_weapon_data)
        weapons.append(weapon_instance)

func take_damage(amount: int) -> void:
    current_health -= amount
    EventBus.player_health_changed.emit(current_health, max_health)
    
    # Trigger hit effect
    if sprite:
        sprite.modulate = Color.RED
        var tween = create_tween()
        tween.tween_property(sprite, "modulate", character_data.sprite_modulate if character_data else Color.WHITE, 0.2)
    
    # Check for death
    if current_health <= 0:
        die()

func heal(amount: int) -> void:
    current_health = min(current_health + amount, max_health)
    EventBus.player_health_changed.emit(current_health, max_health)

func die() -> void:
    EventBus.player_died.emit()
    # Game over logic would be handled by the Game manager

func _on_xp_collector_area_entered(area: Area2D) -> void:
    # Collect XP gems
    if area.has_method("collect"):
        area.collect()

func get_player_stats() -> Dictionary:
    return {
        "current_health": current_health,
        "max_health": max_health,
        "movement_speed": movement_speed,
        "weapons_count": weapons.size(),
        "position": global_position
    }