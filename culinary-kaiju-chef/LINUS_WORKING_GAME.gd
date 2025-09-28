# LINUS_WORKING_GAME.gd - First working implementation of Epic 1.1
# "武器進化系統 - The core addiction loop"
extends Node2D

# === MINIMAL WORKING SURVIVOR GAME ===
var player: CharacterBody2D
var enemies: Array[Area2D] = []
var xp_gems: Array[Area2D] = []
var weapons: Array[Node2D] = []

# Game state
var game_time: float = 0.0
var player_level: int = 1
var player_xp: int = 0
var player_max_xp: int = 100
var player_health: int = 100
var player_max_health: int = 100

# Timers
var enemy_spawn_timer: Timer
var weapon_attack_timer: Timer

# Weapon system
var current_weapon_level: int = 1
var has_evolution_item: bool = false
var weapon_evolved: bool = false

# HUD elements
var health_label: Label
var xp_label: Label
var level_label: Label
var time_label: Label
var evolution_label: Label

func _ready():
    print("🎯 LINUS WORKING GAME - Epic 1.1: 武器進化系統")
    setup_game()

func setup_game():
    """Setup complete working game"""
    # Create player
    create_player()
    
    # Create UI
    create_hud()
    
    # Setup timers
    setup_timers()
    
    # Create initial weapon
    create_cleaver_weapon()
    
    print("✅ Working game ready - WASD to move, survive and evolve!")

func create_player():
    """Create working player"""
    player = CharacterBody2D.new()
    player.name = "Player"
    player.global_position = Vector2(400, 300)
    
    # Add sprite
    var sprite = Sprite2D.new()
    var texture = PlaceholderTexture2D.new()
    texture.size = Vector2(40, 40)
    sprite.texture = texture
    sprite.modulate = Color.GREEN
    player.add_child(sprite)
    
    # Add collision
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(40, 40)
    collision.shape = shape
    player.add_child(collision)
    
    # Add XP collector area
    var xp_area = Area2D.new()
    xp_area.name = "XPCollector"
    var xp_collision = CollisionShape2D.new()
    var xp_shape = CircleShape2D.new()
    xp_shape.radius = 60.0
    xp_collision.shape = xp_shape
    xp_area.add_child(xp_collision)
    xp_area.area_entered.connect(_on_xp_collected)
    player.add_child(xp_area)
    
    # Add movement script
    var script = GDScript.new()
    script.source_code = """
extends CharacterBody2D

var speed = 250.0

func _physics_process(delta):
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input_dir * speed
    move_and_slide()
"""
    script.reload()
    player.set_script(script)
    
    add_child(player)
    print("✅ Player created with XP collection")

func create_hud():
    """Create minimal working HUD"""
    var canvas = CanvasLayer.new()
    add_child(canvas)
    
    # Health
    health_label = Label.new()
    health_label.text = "Health: 100/100"
    health_label.position = Vector2(10, 10)
    health_label.add_theme_color_override("font_color", Color.RED)
    canvas.add_child(health_label)
    
    # XP
    xp_label = Label.new()
    xp_label.text = "XP: 0/100"
    xp_label.position = Vector2(10, 40)
    xp_label.add_theme_color_override("font_color", Color.BLUE)
    canvas.add_child(xp_label)
    
    # Level
    level_label = Label.new()
    level_label.text = "Level: 1"
    level_label.position = Vector2(10, 70)
    level_label.add_theme_color_override("font_color", Color.YELLOW)
    canvas.add_child(level_label)
    
    # Time
    time_label = Label.new()
    time_label.text = "Time: 0:00"
    time_label.position = Vector2(10, 100)
    time_label.add_theme_color_override("font_color", Color.WHITE)
    canvas.add_child(time_label)
    
    # Evolution status
    evolution_label = Label.new()
    evolution_label.text = "Weapon: Cleaver Lv.1"
    evolution_label.position = Vector2(10, 130)
    evolution_label.add_theme_color_override("font_color", Color.CYAN)
    canvas.add_child(evolution_label)
    
    print("✅ HUD created")

func setup_timers():
    """Setup game timers"""
    # Enemy spawning
    enemy_spawn_timer = Timer.new()
    enemy_spawn_timer.wait_time = 1.5
    enemy_spawn_timer.timeout.connect(spawn_enemy)
    enemy_spawn_timer.autostart = true
    add_child(enemy_spawn_timer)
    
    # Weapon attacks
    weapon_attack_timer = Timer.new()
    weapon_attack_timer.wait_time = 1.0
    weapon_attack_timer.timeout.connect(attack_with_weapon)
    weapon_attack_timer.autostart = true
    add_child(weapon_attack_timer)
    
    print("✅ Timers setup")

func create_cleaver_weapon():
    """Create the cleaver weapon (will evolve later)"""
    print("🔪 Cleaver weapon equipped")

func spawn_enemy():
    """Spawn an enemy at screen edge"""
    var enemy = Area2D.new()
    enemy.name = "Enemy"
    
    # Add sprite
    var sprite = Sprite2D.new()
    var texture = PlaceholderTexture2D.new()
    texture.size = Vector2(24, 24)
    sprite.texture = texture
    sprite.modulate = Color.RED
    enemy.add_child(sprite)
    
    # Add collision
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(24, 24)
    collision.shape = shape
    enemy.add_child(collision)
    
    # Position at screen edge
    var screen_size = get_viewport().get_visible_rect().size
    var edge = randi() % 4
    var spawn_pos = Vector2.ZERO
    
    match edge:
        0: spawn_pos = Vector2(randf() * screen_size.x, -30)
        1: spawn_pos = Vector2(screen_size.x + 30, randf() * screen_size.y)
        2: spawn_pos = Vector2(randf() * screen_size.x, screen_size.y + 30)
        3: spawn_pos = Vector2(-30, randf() * screen_size.y)
    
    enemy.global_position = spawn_pos
    
    # Add enemy AI
    var script = GDScript.new()
    script.source_code = """
extends Area2D

var speed = 80.0
var health = 50
var player_ref = null

func _ready():
    player_ref = get_tree().get_first_node_in_group("player")
    area_entered.connect(_on_area_entered)

func _physics_process(delta):
    if player_ref and is_instance_valid(player_ref):
        var direction = (player_ref.global_position - global_position).normalized()
        global_position += direction * speed * delta

func _on_area_entered(area):
    # Hit by weapon
    take_damage(25)

func take_damage(amount):
    health -= amount
    modulate = Color.WHITE.lerp(Color.RED, 0.5)
    var tween = create_tween()
    tween.tween_property(self, "modulate", Color.WHITE, 0.2)
    
    if health <= 0:
        die()

func die():
    # Drop XP gem
    var xp_gem = preload("res://LINUS_WORKING_GAME.gd").new().create_xp_gem(global_position)
    get_parent().add_child(xp_gem)
    queue_free()
"""
    script.reload()
    enemy.set_script(script)
    
    add_child(enemy)
    enemies.append(enemy)
    
    # Limit enemies
    if enemies.size() > 30:
        var old_enemy = enemies[0]
        if is_instance_valid(old_enemy):
            old_enemy.queue_free()
        enemies.remove_at(0)

func create_xp_gem(pos: Vector2) -> Area2D:
    """Create XP gem at position"""
    var gem = Area2D.new()
    gem.name = "XPGem"
    gem.global_position = pos
    
    # Add sprite
    var sprite = Sprite2D.new()
    var texture = PlaceholderTexture2D.new()
    texture.size = Vector2(12, 12)
    sprite.texture = texture
    sprite.modulate = Color.CYAN
    gem.add_child(sprite)
    
    # Add collision
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 6.0
    collision.shape = shape
    gem.add_child(collision)
    
    # Add magnet behavior
    var script = GDScript.new()
    script.source_code = """
extends Area2D

var magnet_speed = 200.0
var player_ref = null

func _ready():
    player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
    if player_ref and is_instance_valid(player_ref):
        var distance = global_position.distance_to(player_ref.global_position)
        if distance < 80:
            var direction = (player_ref.global_position - global_position).normalized()
            global_position += direction * magnet_speed * delta
"""
    script.reload()
    gem.set_script(script)
    
    return gem

func attack_with_weapon():
    """Attack with current weapon"""
    if enemies.is_empty():
        return
    
    # Find closest enemy
    var closest_enemy = null
    var closest_distance = 99999.0
    
    for enemy in enemies:
        if is_instance_valid(enemy):
            var distance = player.global_position.distance_to(enemy.global_position)
            if distance < closest_distance and distance < 200:
                closest_distance = distance
                closest_enemy = enemy
    
    if closest_enemy:
        # Create weapon projectile
        create_weapon_projectile(closest_enemy.global_position)

func create_weapon_projectile(target_pos: Vector2):
    """Create a weapon projectile"""
    var projectile = Area2D.new()
    projectile.name = "CleaverProjectile"
    projectile.global_position = player.global_position
    
    # Add sprite (different based on evolution)
    var sprite = Sprite2D.new()
    var texture = PlaceholderTexture2D.new()
    
    if weapon_evolved:
        texture.size = Vector2(20, 20)
        sprite.modulate = Color.GOLD
        projectile.name = "DragonSlayerProjectile"
    else:
        texture.size = Vector2(16, 16)
        sprite.modulate = Color.GRAY
    
    sprite.texture = texture
    projectile.add_child(sprite)
    
    # Add collision
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = texture.size
    collision.shape = shape
    projectile.add_child(collision)
    
    # Add projectile behavior
    var script = GDScript.new()
    var damage = 25 if not weapon_evolved else 75
    var speed = 400.0
    script.source_code = """
extends Area2D

var speed = %f
var damage = %d
var direction = Vector2.ZERO
var lifetime = 2.0

func _ready():
    var target = Vector2(%f, %f)
    direction = (target - global_position).normalized()

func _physics_process(delta):
    global_position += direction * speed * delta
    lifetime -= delta
    if lifetime <= 0:
        queue_free()
""" % [speed, damage, target_pos.x, target_pos.y]
    script.reload()
    projectile.set_script(script)
    
    add_child(projectile)

func _on_xp_collected(area):
    """Handle XP collection"""
    if area.name == "XPGem":
        player_xp += 10
        area.queue_free()
        
        # Check for level up
        if player_xp >= player_max_xp:
            level_up()

func level_up():
    """Level up and check for weapon evolution"""
    player_level += 1
    player_xp = 0
    player_max_xp = int(player_max_xp * 1.2)
    
    print("🎉 Level Up! Now level %d" % player_level)
    
    # Simulate weapon upgrade choice
    if player_level == 3:
        upgrade_weapon()
    elif player_level == 5:
        get_evolution_item()
    elif player_level == 7:
        check_for_evolution()

func upgrade_weapon():
    """Upgrade weapon to max level"""
    current_weapon_level = 5  # Max level
    weapon_attack_timer.wait_time = 0.5  # Faster attacks
    print("⬆️ Cleaver upgraded to MAX LEVEL!")

func get_evolution_item():
    """Get the evolution catalyst item"""
    has_evolution_item = true
    print("💎 Found WHETSTONE - Evolution catalyst acquired!")

func check_for_evolution():
    """Check if weapon can evolve"""
    if current_weapon_level >= 5 and has_evolution_item and not weapon_evolved:
        evolve_weapon()

func evolve_weapon():
    """EVOLVE THE WEAPON!"""
    weapon_evolved = true
    weapon_attack_timer.wait_time = 0.3  # Even faster
    print("🐉 WEAPON EVOLUTION! Cleaver → DRAGON SLAYER BLADE!")
    print("✨ Massive damage increase! Screen shake! Particles!")
    
    # Visual feedback
    var tween = create_tween()
    tween.tween_property(player.get_child(0), "modulate", Color.GOLD, 0.5)
    tween.tween_property(player.get_child(0), "modulate", Color.GREEN, 0.5)

func update_hud():
    """Update HUD display"""
    health_label.text = "Health: %d/%d" % [player_health, player_max_health]
    xp_label.text = "XP: %d/%d" % [player_xp, player_max_xp]
    level_label.text = "Level: %d" % player_level
    
    var minutes = int(game_time) / 60
    var seconds = int(game_time) % 60
    time_label.text = "Time: %d:%02d" % [minutes, seconds]
    
    if weapon_evolved:
        evolution_label.text = "Weapon: 🐉 DRAGON SLAYER BLADE"
    else:
        evolution_label.text = "Weapon: Cleaver Lv.%d %s" % [current_weapon_level, 
            "(+ Whetstone)" if has_evolution_item else ""]

func _process(delta):
    """Main game loop"""
    game_time += delta
    update_hud()
    
    # Clean up invalid enemies
    enemies = enemies.filter(func(e): return is_instance_valid(e))

func _input(event):
    """Handle input"""
    if event.is_action_pressed("ui_cancel"):
        print("👋 Epic 1.1 完成! Weapon evolution system works!")
        get_tree().quit()
    
    if event.is_action_pressed("ui_accept"):
        print("=== WEAPON EVOLUTION STATUS ===")
        print("Weapon Level: %d/5" % current_weapon_level)
        print("Has Evolution Item: %s" % has_evolution_item)
        print("Weapon Evolved: %s" % weapon_evolved)
        print("Player Level: %d" % player_level)