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
        actual_speed *= character_data.get("speed_multiplier", 1.0)
    
    velocity = input_direction * actual_speed
    move_and_slide()
    
    # Update sprite facing direction
    if velocity.x != 0 and sprite:
        sprite.scale.x = abs(sprite.scale.x) * (1 if velocity.x > 0 else -1)
    
    # Update camera position for VFX system
    EventBus.player_position_changed.emit(global_position)

func equip_weapon(weapon_data: WeaponData) -> void:
    """Equip weapon using pure data-driven approach - Linus approved"""
    if not weapon_data:
        print("❌ Cannot equip weapon: null weapon_data")
        return
    
    # Create weapon instance from base scene
    var weapon_scene = preload("res://features/weapons/base_weapon/BaseWeapon.tscn")
    var weapon_instance = weapon_scene.instantiate()
    add_child(weapon_instance)
    
    # Initialize weapon with pure data - NO hardcoded values
    if weapon_instance.has_method("initialize"):
        weapon_instance.initialize(self, weapon_data)
        weapons.append(weapon_instance)
        print("✅ Equipped weapon: %s (Damage: %d, Speed: %.1f)" % [
            weapon_data.weapon_name, 
            weapon_data.damage, 
            weapon_data.get_actual_speed()
        ])
    else:
        print("❌ Weapon instance missing initialize method")
        weapon_instance.queue_free()

func _on_xp_collector_area_entered(area: Area2D) -> void:
    """Handle XP gem collection - data driven"""
    if area.is_in_group("xp_gems"):
        var xp_gem = area
        var xp_value = 5  # Default value
        
        # Try to get XP value from gem data
        if xp_gem.has_method("get_xp_value"):
            xp_value = xp_gem.get_xp_value()
        elif xp_gem.has_method("get_value"):
            xp_value = xp_gem.get_value()
        
        # Add XP and emit events
        EventBus.xp_gained.emit(xp_value)
        EventBus.experience_vial_collected.emit(xp_value)
        
        # Return gem to pool
        ObjectPool.return_xp_gem(xp_gem)
        
        print("✅ Collected %d XP" % xp_value)

func take_damage(amount: int) -> void:
    """Take damage and update health"""
    current_health -= amount
    current_health = max(0, current_health)
    
    # Emit health change events
    EventBus.player_health_changed.emit(current_health, max_health)
    EventBus.player_damaged.emit()
    
    # Check for death
    if current_health <= 0:
        _handle_death()

func _handle_death() -> void:
    """Handle player death"""
    EventBus.player_died.emit()
    EventBus.game_over.emit(0, 0.0)  # Would include actual score/time
    print("💀 Player died!")

func heal(amount: int) -> void:
    """Heal player"""
    current_health = min(max_health, current_health + amount)
    EventBus.player_health_changed.emit(current_health, max_health)

func increase_max_health(amount: int) -> void:
    """Increase maximum health"""
    max_health += amount
    current_health += amount  # Also heal when max health increases
    EventBus.player_health_changed.emit(current_health, max_health)

func modify_movement_speed(multiplier: float) -> void:
    """Modify movement speed with multiplier"""
    movement_speed *= multiplier
    EventBus.player_move_speed_changed.emit(movement_speed)

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