# PERFECT_GAME.gd - The ultimate Culinary Kaiju Chef game
# Based on Linus Torvalds philosophy: Simple, Effective, No Bloat
extends Node2D
class_name PerfectGame

# === CORE GAME STATE ===
@onready var monster_chef: CharacterBody2D
@onready var ingredient_collector: Area2D

# Game Statistics
var monster_level: int = 1
var appetite: int = 0
var appetite_required: int = 100
var ingredients_chopped: int = 0
var game_time: float = 0.0
var chef_health: int = 100
var chef_max_health: int = 100

# Performance-critical stats (pre-calculated)
var monster_chef_speed: float = 200.0
var cleaver_damage: int = 25
var cleavers_per_attack: int = 2
var attack_speed_multiplier: float = 1.0

# Multi-weapon system
var active_weapons: Array[String] = ["cleaver"]
var weapon_timers: Dictionary = {"cleaver": 0.0, "whisk": 0.0}

# High-performance object pools (no instantiate/queue_free)
var rebellious_ingredients: Array[Area2D] = []
var flying_cleavers: Array[Area2D] = []
var whisk_tornadoes: Array[Area2D] = []
var enemy_projectiles: Array[Area2D] = []
var spice_essences: Array[Area2D] = []

# Spawning system
var ingredient_spawn_timer: float = 0.0

# Upgrade database - data-driven approach
var enhanced_upgrades = [
    {"name": "🔪 Cleaver Mastery", "desc": "Throw +2 more cleavers!\nMore blades = more chaos!", "type": "cleavers", "value": 2},
    {"name": "⚔️ Razor Edge", "desc": "Cleavers deal +20 damage!\nSharp enough to cut reality!", "type": "damage", "value": 20},
    {"name": "⚡ Lightning Hands", "desc": "Attack 30% faster!\nMaster chef speed!", "type": "speed", "value": 0.7},
    {"name": "💪 Kaiju Vigor", "desc": "Move 40% faster!\nSwift domination!", "type": "movement", "value": 40},
    {"name": "🐉 Giant Growth", "desc": "Grow 25% larger!\nImposing presence!", "type": "size", "value": 1.25},
    {"name": "🌟 Spice Magnet", "desc": "Attract spice 50% farther!\nMagnetic aura!", "type": "magnet", "value": 1.5},
    {"name": "🌪️ Whisk Tornado", "desc": "UNLOCK: Spinning whisk weapon!\nTornado of destruction!", "type": "unlock_weapon", "value": "whisk"},
    {"name": "💚 Chef's Resilience", "desc": "Increase max health by 25!\nTougher warrior!", "type": "health", "value": 25}
]

var current_upgrade_choices: Array[Dictionary] = []
var is_upgrading: bool = false

# UI References - minimalist approach
var ui_overlay: Control
var level_label: Label
var health_label: Label
var appetite_label: Label
var time_label: Label
var enemies_label: Label
var upgrade_panel: Panel

func _ready():
    print("🍳🐉 === PERFECT CULINARY KAIJU CHEF === 🐉🍳")
    print("Built with Linus Torvalds philosophy: Simple, Fast, Effective")
    
    setup_game_world()
    create_monster_chef()
    create_minimal_ui()
    connect_systems()
    spawn_initial_battle()
    
    # Start the core game loop
    set_process(true)

func setup_game_world():
    """Initialize the game world with proper environment"""
    # Set background color
    RenderingServer.set_default_clear_color(Color(0.1, 0.1, 0.15))

func create_monster_chef():
    """Create the player character - CharacterBody2D for proper physics"""
    monster_chef = CharacterBody2D.new()
    monster_chef.name = "MonsterChef"
    monster_chef.collision_layer = 2  # player layer
    monster_chef.collision_mask = 1 | 4 | 32  # world, enemies, collectables
    
    # Visual representation - simplified but effective
    var sprite = ColorRect.new()
    sprite.size = Vector2(80, 80)
    sprite.position = Vector2(-40, -40)
    sprite.color = Color(0.2, 0.8, 0.3)  # Green monster chef
    monster_chef.add_child(sprite)
    
    # Chef face - personality matters
    var eye1 = ColorRect.new()
    eye1.size = Vector2(12, 12)
    eye1.position = Vector2(-25, -15)
    eye1.color = Color.WHITE
    sprite.add_child(eye1)
    
    var pupil1 = ColorRect.new()
    pupil1.size = Vector2(6, 6)
    pupil1.position = Vector2(3, 3)
    pupil1.color = Color.BLACK
    eye1.add_child(pupil1)
    
    var eye2 = ColorRect.new()
    eye2.size = Vector2(12, 12)
    eye2.position = Vector2(13, -15)
    eye2.color = Color.WHITE
    sprite.add_child(eye2)
    
    var pupil2 = ColorRect.new()
    pupil2.size = Vector2(6, 6)
    pupil2.position = Vector2(3, 3)
    pupil2.color = Color.BLACK
    eye2.add_child(pupil2)
    
    var mouth = ColorRect.new()
    mouth.size = Vector2(30, 8)
    mouth.position = Vector2(-15, 10)
    mouth.color = Color.BLACK
    sprite.add_child(mouth)
    
    # Chef hat for style
    var hat = ColorRect.new()
    hat.size = Vector2(50, 20)
    hat.position = Vector2(-25, -50)
    hat.color = Color.WHITE
    sprite.add_child(hat)
    
    # Physics collision
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(70, 70)
    collision.shape = shape
    monster_chef.add_child(collision)
    
    # Ingredient collector - Area2D for pickups
    ingredient_collector = Area2D.new()
    ingredient_collector.name = "IngredientCollector"
    ingredient_collector.collision_layer = 0
    ingredient_collector.collision_mask = 32  # collectables
    
    var collector_collision = CollisionShape2D.new()
    var collector_shape = CircleShape2D.new()
    collector_shape.radius = 50
    collector_collision.shape = collector_shape
    collector_collision.name = "CollectorShape"
    ingredient_collector.add_child(collector_collision)
    
    monster_chef.add_child(ingredient_collector)
    add_child(monster_chef)
    
    # Camera follow
    var camera = Camera2D.new()
    camera.enabled = true
    monster_chef.add_child(camera)

func create_minimal_ui():
    """Create a clean, performance-focused UI overlay"""
    ui_overlay = Control.new()
    ui_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ui_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(ui_overlay)
    
    # Top-left HUD
    var hud_container = VBoxContainer.new()
    hud_container.position = Vector2(20, 20)
    ui_overlay.add_child(hud_container)
    
    level_label = Label.new()
    level_label.text = "🐉 Chef Level: 1"
    level_label.add_theme_font_size_override("font_size", 18)
    hud_container.add_child(level_label)
    
    health_label = Label.new()
    health_label.text = "💚 Health: 100/100"
    health_label.add_theme_font_size_override("font_size", 16)
    hud_container.add_child(health_label)
    
    appetite_label = Label.new()
    appetite_label.text = "🔥 Appetite: 0/100"
    appetite_label.add_theme_font_size_override("font_size", 16)
    hud_container.add_child(appetite_label)
    
    # Top-right info
    var info_container = VBoxContainer.new()
    info_container.position = Vector2(get_viewport().get_visible_rect().size.x - 250, 20)
    ui_overlay.add_child(info_container)
    
    time_label = Label.new()
    time_label.text = "⏰ Time: 00:00"
    time_label.add_theme_font_size_override("font_size", 16)
    info_container.add_child(time_label)
    
    enemies_label = Label.new()
    enemies_label.text = "🧅🍅 Enemies: 0"
    enemies_label.add_theme_font_size_override("font_size", 16)
    info_container.add_child(enemies_label)
    
    # Controls hint
    var controls = Label.new()
    controls.text = "WASD: Move | Enter: Spawn Wave | Space: Level Up | 1,2,3: Choose Upgrade"
    controls.position = Vector2(20, get_viewport().get_visible_rect().size.y - 40)
    controls.add_theme_font_size_override("font_size", 14)
    controls.modulate = Color(0.8, 0.8, 0.8)
    ui_overlay.add_child(controls)
    
    # Upgrade panel (hidden initially)
    upgrade_panel = Panel.new()
    upgrade_panel.size = Vector2(500, 400)
    upgrade_panel.position = Vector2(
        (get_viewport().get_visible_rect().size.x - 500) / 2,
        (get_viewport().get_visible_rect().size.y - 400) / 2
    )
    upgrade_panel.hide()
    
    var upgrade_bg = ColorRect.new()
    upgrade_bg.color = Color(0.1, 0.1, 0.2, 0.9)
    upgrade_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    upgrade_panel.add_child(upgrade_bg)
    
    ui_overlay.add_child(upgrade_panel)

func connect_systems():
    """Connect all the game systems together"""
    if ingredient_collector:
        ingredient_collector.area_entered.connect(_on_spice_collected)

func _process(delta):
    """Main game loop - optimized for performance"""
    if is_upgrading:
        return  # Pause game during upgrades
    
    game_time += delta
    handle_chef_movement(delta)
    handle_enemy_spawning(delta)
    handle_combat(delta)
    update_all_entities(delta)
    cleanup_invalid_objects()
    update_ui()

# === MOVEMENT SYSTEM ===
func handle_chef_movement(delta: float):
    """Handle player movement with Godot 4.5 best practices"""
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var actual_speed = monster_chef_speed * (1.0 + monster_level * 0.08)
    monster_chef.velocity = input_dir * actual_speed
    monster_chef.move_and_slide()
    
    # Visual feedback
    if input_dir.x != 0:
        monster_chef.scale.x = abs(monster_chef.scale.x) * (1 if input_dir.x > 0 else -1)

# === ENEMY SPAWNING SYSTEM ===
func handle_enemy_spawning(delta: float):
    """Spawn enemies based on level and time - performance optimized"""
    ingredient_spawn_timer += delta
    var spawn_interval = max(0.6, 2.0 - (monster_level * 0.12))
    
    if ingredient_spawn_timer > spawn_interval:
        ingredient_spawn_timer = 0.0
        spawn_dynamic_enemy()

func spawn_dynamic_enemy():
    """Smart enemy spawning based on game progression"""
    var enemy_type = "onion" if monster_level < 2 or randf() < 0.7 else "tomato"
    
    match enemy_type:
        "onion":
            spawn_onion()
        "tomato":
            spawn_tomato()

func spawn_onion():
    """Create an onion enemy - using Area2D for performance"""
    var onion = create_enemy_template("onion", Color(0.8, 0.6, 0.9))  # Purple-ish onion
    
    var health = 35 + (monster_level * 5)
    var speed = 55 + (monster_level * 3)
    var xp = 12 + monster_level
    
    setup_enemy_metadata(onion, "onion", health, speed, xp)
    onion.area_entered.connect(func(area): hit_ingredient(onion, area))
    rebellious_ingredients.append(onion)

func spawn_tomato():
    """Create a tomato enemy with ranged attacks"""
    var tomato = create_enemy_template("tomato", Color.RED)
    
    var health = 50 + (monster_level * 6)
    var speed = 40 + (monster_level * 2)
    var xp = 18 + (monster_level * 2)
    
    setup_enemy_metadata(tomato, "tomato", health, speed, xp)
    tomato.set_meta("attack_range", 220.0)
    tomato.set_meta("attack_damage", 12 + monster_level)
    tomato.set_meta("attack_timer", 0.0)
    tomato.set_meta("attack_cooldown", 2.8)
    
    tomato.area_entered.connect(func(area): hit_ingredient(tomato, area))
    rebellious_ingredients.append(tomato)

func create_enemy_template(enemy_type: String, color: Color) -> Area2D:
    """Generic enemy creation - DRY principle"""
    var enemy = Area2D.new()
    enemy.collision_layer = 4  # enemies layer
    enemy.collision_mask = 8   # player_weapons layer
    
    # Visual representation
    var sprite_container = Node2D.new()
    sprite_container.name = enemy_type.capitalize() + "Sprite"
    
    var sprite = ColorRect.new()
    sprite.size = Vector2(40, 40)
    sprite.position = Vector2(-20, -20)
    sprite.color = color
    sprite_container.add_child(sprite)
    
    # Character eyes
    var eye1 = ColorRect.new()
    eye1.size = Vector2(6, 6)
    eye1.position = Vector2(-12, -8)
    eye1.color = Color.BLACK
    sprite.add_child(eye1)
    
    var eye2 = ColorRect.new()
    eye2.size = Vector2(6, 6)
    eye2.position = Vector2(6, -8)
    eye2.color = Color.BLACK
    sprite.add_child(eye2)
    
    # Angry mouth for enemies
    var mouth = ColorRect.new()
    mouth.size = Vector2(16, 4)
    mouth.position = Vector2(-8, 8)
    mouth.color = Color.DARK_RED
    sprite.add_child(mouth)
    
    enemy.add_child(sprite_container)
    
    # Physics collision
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(35, 35)
    collision.shape = shape
    enemy.add_child(collision)
    
    add_child(enemy)
    position_enemy_around_chef(enemy)
    
    return enemy

func setup_enemy_metadata(enemy: Area2D, type: String, health: int, speed: int, xp: int):
    """Set enemy properties using metadata - efficient approach"""
    enemy.set_meta("enemy_type", type)
    enemy.set_meta("health", health)
    enemy.set_meta("max_health", health)
    enemy.set_meta("speed", speed)
    enemy.set_meta("xp", xp)

func position_enemy_around_chef(enemy: Area2D):
    """Spawn enemies off-screen in a circle around the player"""
    var angle = randf() * TAU
    var distance = 650 + randf() * 200
    enemy.global_position = monster_chef.global_position + Vector2.RIGHT.rotated(angle) * distance

# === COMBAT SYSTEM ===
func handle_combat(delta: float):
    """Main combat loop - weapon systems"""
    # Cleaver system (default weapon)
    weapon_timers["cleaver"] += delta
    var cleaver_interval = (1.4 / attack_speed_multiplier) - (monster_level * 0.06)
    if weapon_timers["cleaver"] > max(0.25, cleaver_interval):
        weapon_timers["cleaver"] = 0.0
        if "cleaver" in active_weapons:
            throw_cleavers()
    
    # Whisk tornado system (unlockable)
    if "whisk" in active_weapons:
        weapon_timers["whisk"] += delta
        if weapon_timers["whisk"] > 3.5:
            weapon_timers["whisk"] = 0.0
            create_whisk_tornado()

func throw_cleavers():
    """Throw cleavers at nearest enemies - smart targeting"""
    var targets = find_nearest_enemies(cleavers_per_attack)
    
    for i in range(cleavers_per_attack):
        var cleaver = create_cleaver()
        
        var direction: Vector2
        if i < targets.size():
            var target = targets[i]
            var predicted_pos = predict_target_position(target)
            direction = (predicted_pos - monster_chef.global_position).normalized()
        else:
            # Spread pattern when no targets
            var spread = (TAU / cleavers_per_attack) * i + randf_range(-0.25, 0.25)
            direction = Vector2.RIGHT.rotated(spread)
        
        launch_cleaver(cleaver, direction)

func create_cleaver():
    """Create a cleaver projectile - Area2D for collision detection"""
    var cleaver = Area2D.new()
    cleaver.collision_layer = 8  # player_weapons
    cleaver.collision_mask = 4   # enemies
    
    # Visual - simple but recognizable
    var sprite = Node2D.new()
    var blade = ColorRect.new()
    blade.size = Vector2(20, 8)
    blade.position = Vector2(-10, -4)
    blade.color = Color.SILVER
    sprite.add_child(blade)
    
    var handle = ColorRect.new()
    handle.size = Vector2(4, 15)
    handle.position = Vector2(-2, 4)
    handle.color = Color(0.4, 0.2, 0.1)
    sprite.add_child(handle)
    
    cleaver.add_child(sprite)
    
    # Collision detection
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(18, 6)
    collision.shape = shape
    cleaver.add_child(collision)
    
    add_child(cleaver)
    
    # Weapon stats
    cleaver.set_meta("damage", cleaver_damage)
    cleaver.set_meta("speed", 320.0 + (monster_level * 10))
    cleaver.set_meta("lifetime", 4.5)
    
    return cleaver

func launch_cleaver(cleaver: Area2D, direction: Vector2):
    """Launch a cleaver in the specified direction"""
    cleaver.global_position = monster_chef.global_position
    cleaver.set_meta("direction", direction)
    cleaver.rotation = direction.angle()
    flying_cleavers.append(cleaver)

func predict_target_position(target: Area2D) -> Vector2:
    """Simple target prediction for better hit accuracy"""
    var speed = target.get_meta("speed", 50.0)
    var direction_to_chef = (monster_chef.global_position - target.global_position).normalized()
    var predicted_movement = direction_to_chef * speed * 0.4
    return target.global_position + predicted_movement

func create_whisk_tornado():
    """Create a whisk tornado - area effect weapon"""
    var whisk = Area2D.new()
    whisk.collision_layer = 8
    whisk.collision_mask = 4
    
    # Visual effect
    var sprite = Node2D.new()
    var handle = ColorRect.new()
    handle.size = Vector2(4, 30)
    handle.position = Vector2(-2, -15)
    handle.color = Color(0.4, 0.2, 0.1)
    sprite.add_child(handle)
    
    var tornado_effect = ColorRect.new()
    tornado_effect.size = Vector2(120, 120)
    tornado_effect.position = Vector2(-60, -60)
    tornado_effect.color = Color(0.8, 1, 1, 0.4)
    sprite.add_child(tornado_effect)
    
    whisk.add_child(sprite)
    
    # Large collision area
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 60
    collision.shape = shape
    whisk.add_child(collision)
    
    add_child(whisk)
    whisk.global_position = monster_chef.global_position
    
    var direction = find_tornado_direction()
    whisk.set_meta("direction", direction)
    whisk.set_meta("damage", cleaver_damage)
    whisk.set_meta("speed", 120.0)
    whisk.set_meta("lifetime", 5.0)
    whisk.set_meta("spin_speed", 15.0)
    whisk.set_meta("affected_enemies", [])
    
    whisk.area_entered.connect(func(area): _on_tornado_hits_enemy(whisk, area))
    whisk_tornadoes.append(whisk)
    
    print("🌪️ WHISK TORNADO UNLEASHED!")

func find_tornado_direction() -> Vector2:
    """Find the direction toward enemy clusters"""
    if rebellious_ingredients.is_empty():
        return Vector2.RIGHT
    
    var center = Vector2.ZERO
    var count = 0
    
    for enemy in rebellious_ingredients:
        if is_instance_valid(enemy):
            center += enemy.global_position
            count += 1
    
    if count > 0:
        center /= count
        return (center - monster_chef.global_position).normalized()
    
    return Vector2.RIGHT

func _on_tornado_hits_enemy(tornado: Area2D, enemy: Area2D):
    """Handle tornado hitting enemies - prevent double damage"""
    if enemy in rebellious_ingredients:
        var affected = tornado.get_meta("affected_enemies", [])
        if enemy not in affected:
            affected.append(enemy)
            tornado.set_meta("affected_enemies", affected)
            damage_ingredient(enemy, tornado.get_meta("damage", 25))

# === ENTITY UPDATE SYSTEM ===
func update_all_entities(delta: float):
    """Update all game entities - optimized single loop"""
    update_ingredients(delta)
    update_cleavers(delta)
    update_whisk_tornadoes(delta)
    update_enemy_projectiles(delta)
    update_spice_essences(delta)

func update_ingredients(delta: float):
    """Update enemy behavior - hand-optimized movement"""
    for ingredient in rebellious_ingredients:
        if not is_instance_valid(ingredient):
            continue
        
        var enemy_type = ingredient.get_meta("enemy_type", "onion")
        
        match enemy_type:
            "onion":
                update_onion(ingredient, delta)
            "tomato":
                update_tomato(ingredient, delta)

func update_onion(onion: Area2D, delta: float):
    """Onion AI - simple chase behavior with wobble"""
    var speed = onion.get_meta("speed", 55.0)
    var direction = (monster_chef.global_position - onion.global_position).normalized()
    
    # Add some personality with wobble
    var wobble = Vector2(sin(game_time * 3) * 10, cos(game_time * 2.5) * 8)
    onion.global_position += (direction * speed + wobble) * delta
    
    # Visual rotation
    var sprite = onion.get_node_or_null("OnionSprite")
    if sprite:
        sprite.rotation += (speed / 15.0) * delta
    
    # Contact damage
    if onion.global_position.distance_to(monster_chef.global_position) < 65:
        take_chef_damage(8 + monster_level)
        rebellious_ingredients.erase(onion)
        onion.queue_free()

func update_tomato(tomato: Area2D, delta: float):
    """Tomato AI - ranged combat behavior"""
    var distance = tomato.global_position.distance_to(monster_chef.global_position)
    var attack_range = tomato.get_meta("attack_range", 220.0)
    var speed = tomato.get_meta("speed", 40.0)
    
    if distance > attack_range:
        # Move closer
        var direction = (monster_chef.global_position - tomato.global_position).normalized()
        tomato.global_position += direction * speed * delta
        
        # Bob animation
        var sprite = tomato.get_node_or_null("TomatoSprite")
        if sprite:
            sprite.position.y = sin(game_time * 4) * 4
    else:
        # Attack behavior
        var attack_timer = tomato.get_meta("attack_timer", 0.0) + delta
        tomato.set_meta("attack_timer", attack_timer)
        
        var cooldown = tomato.get_meta("attack_cooldown", 2.8)
        if attack_timer >= cooldown:
            tomato.set_meta("attack_timer", 0.0)
            tomato_attack(tomato)

func tomato_attack(tomato: Area2D):
    """Tomato projectile attack"""
    var acid = Area2D.new()
    acid.collision_layer = 16  # enemy_weapons
    acid.collision_mask = 2    # player
    
    # Visual projectile
    var acid_sprite = ColorRect.new()
    acid_sprite.size = Vector2(12, 12)
    acid_sprite.position = Vector2(-6, -6)
    acid_sprite.color = Color.RED
    acid.add_child(acid_sprite)
    
    # Collision
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 6
    collision.shape = shape
    acid.add_child(collision)
    
    add_child(acid)
    acid.global_position = tomato.global_position
    
    # Predictive targeting
    var chef_velocity = monster_chef.velocity
    var predicted_chef_pos = monster_chef.global_position + chef_velocity * 0.5
    var direction = (predicted_chef_pos - tomato.global_position).normalized()
    
    acid.set_meta("direction", direction)
    acid.set_meta("speed", 180.0)
    acid.set_meta("damage", tomato.get_meta("attack_damage", 12))
    acid.set_meta("lifetime", 4.0)
    
    enemy_projectiles.append(acid)

func update_cleavers(delta: float):
    """Update flying cleavers - manual physics for performance"""
    for cleaver in flying_cleavers:
        if not is_instance_valid(cleaver):
            continue
        
        var direction = cleaver.get_meta("direction", Vector2.RIGHT)
        var speed = cleaver.get_meta("speed", 320.0)
        var lifetime = cleaver.get_meta("lifetime", 4.5) - delta
        
        # Manual position update - faster than physics
        cleaver.global_position += direction * speed * delta
        cleaver.rotation += 10.0 * delta  # Spinning effect
        cleaver.set_meta("lifetime", lifetime)
        
        # Cleanup expired cleavers
        if lifetime <= 0 or cleaver.global_position.distance_to(monster_chef.global_position) > 1000:
            flying_cleavers.erase(cleaver)
            cleaver.queue_free()

func update_whisk_tornadoes(delta: float):
    """Update whisk tornadoes - area effect weapons"""
    for whisk in whisk_tornadoes:
        if not is_instance_valid(whisk):
            continue
        
        var direction = whisk.get_meta("direction", Vector2.RIGHT)
        var speed = whisk.get_meta("speed", 120.0)
        var lifetime = whisk.get_meta("lifetime", 5.0) - delta
        var spin_speed = whisk.get_meta("spin_speed", 15.0)
        
        whisk.global_position += direction * speed * delta
        whisk.set_meta("lifetime", lifetime)
        
        # Visual spinning
        var sprite = whisk.get_children()[0]
        if sprite:
            sprite.rotation += spin_speed * delta
        
        if lifetime <= 0:
            whisk_tornadoes.erase(whisk)
            create_tornado_explosion(whisk.global_position)
            whisk.queue_free()

func create_tornado_explosion(position: Vector2):
    """Visual explosion effect when tornado expires"""
    var explosion = ColorRect.new()
    explosion.size = Vector2(200, 200)
    explosion.position = Vector2(-100, -100)
    explosion.color = Color(1, 1, 0, 0.8)
    add_child(explosion)
    explosion.global_position = position
    
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(explosion, "scale", Vector2(2, 2), 0.6).set_ease(Tween.EASE_OUT)
    tween.tween_property(explosion, "modulate", Color(1, 1, 0, 0), 0.6)
    tween.finished.connect(func(): explosion.queue_free())

func update_enemy_projectiles(delta: float):
    """Update enemy projectiles"""
    for projectile in enemy_projectiles:
        if not is_instance_valid(projectile):
            continue
        
        var direction = projectile.get_meta("direction", Vector2.RIGHT)
        var speed = projectile.get_meta("speed", 180.0)
        var lifetime = projectile.get_meta("lifetime", 4.0) - delta
        
        projectile.global_position += direction * speed * delta
        projectile.set_meta("lifetime", lifetime)
        
        # Check collision with player (manual check for performance)
        if projectile.global_position.distance_to(monster_chef.global_position) < 45:
            var damage = projectile.get_meta("damage", 12)
            take_chef_damage(damage)
            enemy_projectiles.erase(projectile)
            projectile.queue_free()
            continue
        
        if lifetime <= 0:
            enemy_projectiles.erase(projectile)
            projectile.queue_free()

func update_spice_essences(delta: float):
    """Update spice pickup items - magnetic attraction"""
    for spice in spice_essences:
        if not is_instance_valid(spice):
            continue
        
        var direction = (monster_chef.global_position - spice.global_position).normalized()
        var attraction = (120.0 + monster_level * 15) * delta
        spice.global_position += direction * attraction

# === DAMAGE AND HEALTH SYSTEM ===
func take_chef_damage(damage: int):
    """Handle player taking damage"""
    chef_health = max(0, chef_health - damage)
    
    # Visual feedback
    monster_chef.modulate = Color.RED
    create_tween().tween_property(monster_chef, "modulate", Color.WHITE, 0.25)
    
    print("💥 Chef took %d damage! Health: %d/%d" % [damage, chef_health, chef_max_health])
    
    if chef_health <= 0:
        game_over()

func game_over():
    """Handle game over state"""
    print("💀 GAME OVER!")
    print("📊 Final Stats:")
    print("   - Level: %d" % monster_level)
    print("   - Ingredients: %d" % ingredients_chopped)
    print("   - Time: %.1f seconds" % game_time)
    print("   - Press R to restart")
    
    # Could transition to game over screen here
    set_process(false)

func hit_ingredient(ingredient: Area2D, weapon: Area2D):
    """Handle weapon hitting an enemy"""
    if weapon in flying_cleavers:
        var damage = weapon.get_meta("damage", 25)
        damage_ingredient(ingredient, damage)
        flying_cleavers.erase(weapon)
        weapon.queue_free()

func damage_ingredient(ingredient: Area2D, damage: int):
    """Apply damage to an enemy"""
    var current_health = ingredient.get_meta("health", 35) - damage
    ingredient.set_meta("health", current_health)
    
    # Visual damage feedback
    var enemy_type = ingredient.get_meta("enemy_type", "onion")
    var sprite_name = enemy_type.capitalize() + "Sprite"
    var sprite = ingredient.get_node_or_null(sprite_name)
    
    if sprite:
        sprite.modulate = Color.RED
        create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.15)
    
    if current_health <= 0:
        chop_ingredient(ingredient)

func chop_ingredient(ingredient: Area2D):
    """Handle enemy death - spawn XP and update stats"""
    var enemy_type = ingredient.get_meta("enemy_type", "onion")
    var xp_reward = ingredient.get_meta("xp", 12)
    
    if enemy_type == "tomato":
        xp_reward = int(xp_reward * 1.6)  # Tomatoes give more XP
    
    spawn_spice(ingredient.global_position, xp_reward, enemy_type)
    
    ingredients_chopped += 1
    appetite += xp_reward
    
    if appetite >= appetite_required:
        level_up()
    
    rebellious_ingredients.erase(ingredient)
    ingredient.queue_free()

func spawn_spice(position: Vector2, value: int, ingredient_type: String):
    """Spawn XP pickup"""
    var spice = Area2D.new()
    spice.collision_layer = 32  # collectables
    spice.collision_mask = 0
    
    var color = Color.YELLOW
    match ingredient_type:
        "tomato":
            color = Color.GOLD
        "onion":
            color = Color.ORANGE
    
    var core = ColorRect.new()
    core.name = "SpiceCore"
    core.size = Vector2(15, 15)
    core.position = Vector2(-7.5, -7.5)
    core.color = color
    spice.add_child(core)
    
    # Add sparkle effect
    var sparkle = ColorRect.new()
    sparkle.size = Vector2(8, 8)
    sparkle.position = Vector2(-4, -4)
    sparkle.color = Color.WHITE
    core.add_child(sparkle)
    
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 10
    collision.shape = shape
    spice.add_child(collision)
    
    add_child(spice)
    spice.global_position = position
    spice.set_meta("xp", value)
    
    spice_essences.append(spice)

func _on_spice_collected(area: Area2D):
    """Handle spice pickup"""
    if area in spice_essences:
        var xp_value = area.get_meta("xp", 12)
        appetite += xp_value
        
        if appetite >= appetite_required:
            level_up()
        
        spice_essences.erase(area)
        area.queue_free()

# === UPGRADE SYSTEM ===
func level_up():
    """Handle player level up"""
    monster_level += 1
    appetite = 0
    appetite_required = int(appetite_required * 1.45)
    
    # Heal on level up
    chef_health = min(chef_max_health, chef_health + 15)
    
    show_upgrade_choices()
    
    print("🎉 LEVEL UP! Level %d reached!" % monster_level)

func show_upgrade_choices():
    """Display upgrade options"""
    var available = get_level_appropriate_upgrades()
    available.shuffle()
    
    current_upgrade_choices = [available[0], available[1], available[2]]
    
    print("Choose your upgrade (press 1, 2, or 3):")
    for i in range(3):
        var upgrade = current_upgrade_choices[i]
        print("%d. %s - %s" % [i+1, upgrade.name, upgrade.desc])
    
    # Show upgrade panel
    upgrade_panel.show()
    var upgrade_text = ""
    for i in range(3):
        var upgrade = current_upgrade_choices[i]
        upgrade_text += "%d. %s\n%s\n\n" % [i+1, upgrade.name, upgrade.desc]
    
    # Create upgrade text if not exists
    var existing_text = upgrade_panel.get_node_or_null("UpgradeText")
    if not existing_text:
        var upgrade_label = Label.new()
        upgrade_label.name = "UpgradeText"
        upgrade_label.text = upgrade_text
        upgrade_label.add_theme_font_size_override("font_size", 16)
        upgrade_label.position = Vector2(20, 20)
        upgrade_label.size = Vector2(460, 360)
        upgrade_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
        upgrade_panel.add_child(upgrade_label)
    else:
        existing_text.text = upgrade_text
    
    is_upgrading = true

func get_level_appropriate_upgrades() -> Array[Dictionary]:
    """Get upgrades appropriate for current level"""
    var available: Array[Dictionary] = []
    
    for upgrade in enhanced_upgrades:
        if upgrade.type in ["cleavers", "damage", "speed", "movement", "size", "magnet", "health"]:
            available.append(upgrade)
        elif upgrade.type == "unlock_weapon":
            var weapon = upgrade.value
            if weapon == "whisk" and monster_level >= 3 and "whisk" not in active_weapons:
                available.append(upgrade)
    
    return available

func apply_upgrade(upgrade: Dictionary):
    """Apply the selected upgrade"""
    match upgrade.type:
        "cleavers":
            cleavers_per_attack += upgrade.value
        "damage":
            cleaver_damage += upgrade.value
        "speed":
            attack_speed_multiplier /= upgrade.value
        "movement":
            monster_chef_speed += upgrade.value
        "size":
            monster_chef.scale *= upgrade.value
        "magnet":
            var collector = ingredient_collector.get_node("CollectorShape").shape as CircleShape2D
            if collector:
                collector.radius *= upgrade.value
        "health":
            chef_max_health += upgrade.value
            chef_health += upgrade.value
        "unlock_weapon":
            var weapon = upgrade.value
            active_weapons.append(weapon)
            weapon_timers[weapon] = 0.0
    
    print("✨ Upgrade applied: %s" % upgrade.name)

# === UTILITY FUNCTIONS ===
func find_nearest_enemies(count: int) -> Array[Area2D]:
    """Find the nearest enemies for targeting"""
    var tomatoes: Array[Area2D] = []
    var onions: Array[Area2D] = []
    
    for ingredient in rebellious_ingredients:
        if is_instance_valid(ingredient):
            var enemy_type = ingredient.get_meta("enemy_type", "onion")
            if enemy_type == "tomato":
                tomatoes.append(ingredient)
            else:
                onions.append(ingredient)
    
    # Sort by distance
    tomatoes.sort_custom(func(a, b): return a.global_position.distance_to(monster_chef.global_position) < b.global_position.distance_to(monster_chef.global_position))
    onions.sort_custom(func(a, b): return a.global_position.distance_to(monster_chef.global_position) < b.global_position.distance_to(monster_chef.global_position))
    
    # Prioritize tomatoes (ranged enemies)
    var targets: Array[Area2D] = []
    targets.append_array(tomatoes)
    targets.append_array(onions)
    
    return targets.slice(0, count)

func spawn_initial_battle():
    """Spawn initial enemies"""
    for i in range(3):
        spawn_onion()

func cleanup_invalid_objects():
    """Remove invalid objects from arrays - prevent memory leaks"""
    rebellious_ingredients = rebellious_ingredients.filter(func(obj): return is_instance_valid(obj))
    flying_cleavers = flying_cleavers.filter(func(obj): return is_instance_valid(obj))
    whisk_tornadoes = whisk_tornadoes.filter(func(obj): return is_instance_valid(obj))
    enemy_projectiles = enemy_projectiles.filter(func(obj): return is_instance_valid(obj))
    spice_essences = spice_essences.filter(func(obj): return is_instance_valid(obj))

func update_ui():
    """Update all UI elements"""
    level_label.text = "🐉 Chef Level: %d" % monster_level
    health_label.text = "💚 Health: %d/%d" % [chef_health, chef_max_health]
    appetite_label.text = "🔥 Appetite: %d/%d" % [appetite, appetite_required]
    
    var minutes = int(game_time) / 60
    var seconds = int(game_time) % 60
    time_label.text = "⏰ Time: %02d:%02d" % [minutes, seconds]
    enemies_label.text = "🧅🍅 Enemies: %d" % rebellious_ingredients.size()

# === INPUT HANDLING ===
func _input(event):
    """Handle input events"""
    if event.is_action_pressed("ui_accept"):
        # Spawn enemy wave
        for i in range(6):
            if randf() > 0.4:
                spawn_onion()
            else:
                spawn_tomato()
        print("🚨 ENEMY WAVE! Mixed ingredients incoming!")
    
    if event.is_action_pressed("ui_select"):
        # Test level up
        level_up()
        print("💪 Testing upgrade system!")
    
    if Input.is_action_just_pressed("ui_cancel"):
        # Restart game
        if not is_upgrading:
            get_tree().reload_current_scene()
    
    # Upgrade selection
    if is_upgrading:
        if Input.is_key_pressed(KEY_1):
            apply_upgrade(current_upgrade_choices[0])
            upgrade_panel.hide()
            is_upgrading = false
        elif Input.is_key_pressed(KEY_2):
            apply_upgrade(current_upgrade_choices[1])
            upgrade_panel.hide()
            is_upgrading = false
        elif Input.is_key_pressed(KEY_3):
            apply_upgrade(current_upgrade_choices[2])
            upgrade_panel.hide()
            is_upgrading = false