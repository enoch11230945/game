# Player.gd - Clean Linus-approved player implementation
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

func _on_player_health_changed(current: int, max_health: int) -> void:
    """Update Game.gd with health changes"""
    Game.set_player_health(current, max_health)

func _ready() -> void:
    # Initialize from character data
    if character_data:
        max_health = character_data.get("max_health", 100)
        current_health = max_health
        movement_speed = character_data.get("movement_speed", 300.0)
        
        if sprite and character_data.has("sprite_texture"):
            sprite.texture = character_data.sprite_texture
            sprite.scale = character_data.get("sprite_scale", Vector2.ONE)
            sprite.modulate = character_data.get("sprite_modulate", Color.WHITE)
    
    # Add to player group for targeting
    add_to_group("player")
    
    # Connect XP collection
    if xp_collector:
        xp_collector.area_entered.connect(_on_xp_collector_area_entered)
    
    # Connect health changes to Game.gd
    EventBus.player_health_changed.connect(_on_player_health_changed)
    
    # Initialize Game.gd with starting health
    Game.set_player_health(current_health, max_health)
    
    # Load starting weapon
    if not starting_weapon_data:
        starting_weapon_data = load("res://features/weapons/weapon_data/throwing_knife.tres")
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
        print("✅ Equipped weapon: %s (Damage: %d)" % [
            weapon_data.weapon_name, 
            weapon_data.damage
        ])
    else:
        print("❌ Weapon instance missing initialize method")
        weapon_instance.queue_free()

func _on_xp_collector_area_entered(area: Area2D) -> void:
    """Handle XP gem collection - data driven"""
    if area.is_in_group("xp_gems") or area.is_in_group("collectables"):
        var xp_gem = area
        var xp_value = 5  # Default value
        
        # Try to get XP value from gem data
        if xp_gem.has_method("get_xp_value"):
            xp_value = xp_gem.get_xp_value()
        elif xp_gem.has_method("get_value"):
            xp_value = xp_gem.get_value()
        elif xp_gem.has("experience_value"):
            xp_value = xp_gem.experience_value
        
        # Add XP and emit events
        EventBus.xp_gained.emit(xp_value)
        EventBus.experience_vial_collected.emit(xp_value)
        
        # Return gem to pool
        ObjectPool.return_xp_gem(xp_gem)
        
        print("✅ Collected %d XP" % xp_value)

func take_damage(amount: int) -> void:
    """Take damage and update health - Linus approved single responsibility"""
    current_health -= amount
    current_health = max(0, current_health)
    
    # Emit health change events
    EventBus.player_health_changed.emit(current_health, max_health)
    EventBus.player_damaged.emit()
    
    # Visual hit effect
    if sprite:
        sprite.modulate = Color.RED
        var tween = create_tween()
        var target_color = Color.WHITE
        if character_data and character_data.has("sprite_modulate"):
            target_color = character_data.sprite_modulate
        tween.tween_property(sprite, "modulate", target_color, 0.2)
    
    # Check for death
    if current_health <= 0:
        _handle_death()

func _handle_death() -> void:
    """Handle player death"""
    EventBus.player_died.emit()
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