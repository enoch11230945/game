# VFXManager.gd - Visual Effects Manager (Linus approved performance)
extends Node2D
class_name VFXManager

# === VFX POOLS ===
var damage_number_scene: PackedScene
var hit_flash_material: ShaderMaterial

# === SCREEN EFFECTS ===
var screen_shake_camera: Camera2D
var current_shake_intensity: float = 0.0
var current_shake_duration: float = 0.0

func _ready() -> void:
    print("✨ VFXManager initialized - High performance visual effects")
    _preload_vfx_resources()
    _setup_screen_effects()
    
    # Connect to events
    EventBus.projectile_hit.connect(_on_projectile_hit)
    EventBus.enemy_killed.connect(_on_enemy_killed) 
    EventBus.screen_shake_requested.connect(_on_screen_shake_requested)

func _preload_vfx_resources() -> void:
    """Preload all VFX resources for performance"""
    # Load scenes
    damage_number_scene = preload("res://src/vfx/DamageNumber.tscn")
    
    # Load hit flash shader
    var shader = preload("res://src/vfx/HitFlash.gdshader")
    hit_flash_material = ShaderMaterial.new()
    hit_flash_material.shader = shader
    
    print("✅ VFX resources preloaded")

func _setup_screen_effects() -> void:
    """Setup screen shake system"""
    # Find camera
    screen_shake_camera = get_viewport().get_camera_2d()

func _process(delta: float) -> void:
    """Handle screen shake"""
    if current_shake_duration > 0.0 and screen_shake_camera:
        current_shake_duration -= delta
        
        # Calculate shake offset
        var shake_offset = Vector2(
            randf_range(-current_shake_intensity, current_shake_intensity),
            randf_range(-current_shake_intensity, current_shake_intensity)
        )
        
        screen_shake_camera.offset = shake_offset
        
        # Decay intensity
        current_shake_intensity = lerp(current_shake_intensity, 0.0, delta * 8.0)
        
        if current_shake_duration <= 0.0:
            screen_shake_camera.offset = Vector2.ZERO

func spawn_damage_number(position: Vector2, damage: int, color: Color = Color.WHITE) -> void:
    """Spawn floating damage number using ObjectPool"""
    var damage_number = ObjectPool.get_damage_number(damage_number_scene)
    if damage_number:
        get_tree().get_root().add_child(damage_number)
        
        if damage_number.has_method("initialize"):
            damage_number.initialize(position, damage, color)

func apply_hit_flash(sprite: Sprite2D, duration: float = 0.2, color: Color = Color.RED) -> void:
    """Apply hit flash effect to sprite"""
    if not sprite:
        return
    
    # Apply shader material
    var flash_material = hit_flash_material.duplicate()
    flash_material.set_shader_parameter("flash_color", color)
    sprite.material = flash_material
    
    # Animate flash
    var tween = create_tween()
    tween.tween_method(_set_flash_intensity.bind(flash_material), 0.8, 0.0, duration)
    tween.tween_callback(_remove_flash_material.bind(sprite))

func _set_flash_intensity(material: ShaderMaterial, intensity: float) -> void:
    """Set flash intensity in shader"""
    if material:
        material.set_shader_parameter("flash_intensity", intensity)

func _remove_flash_material(sprite: Sprite2D) -> void:
    """Remove flash material from sprite"""
    if sprite:
        sprite.material = null

func trigger_screen_shake(intensity: float, duration: float) -> void:
    """Trigger screen shake effect"""
    current_shake_intensity = max(current_shake_intensity, intensity)
    current_shake_duration = max(current_shake_duration, duration)

# === EVENT HANDLERS ===

func _on_projectile_hit(projectile: Node, enemy: Node, damage: int) -> void:
    """Handle projectile hit VFX"""
    if enemy:
        # Damage number
        spawn_damage_number(enemy.global_position, damage, Color.YELLOW)
        
        # Hit flash
        var sprite = enemy.get_node_or_null("Sprite2D")
        if sprite:
            apply_hit_flash(sprite, 0.15, Color.WHITE)
        
        # Light screen shake
        trigger_screen_shake(2.0, 0.1)

func _on_enemy_killed(enemy: Node, position: Vector2, xp_reward: int) -> void:
    """Handle enemy death VFX"""
    # XP number
    spawn_damage_number(position, xp_reward, Color.CYAN)
    
    # Screen shake
    trigger_screen_shake(5.0, 0.3)

func _on_screen_shake_requested(intensity: float, duration: float) -> void:
    """Handle screen shake request"""
    trigger_screen_shake(intensity, duration)