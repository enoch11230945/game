# LINUS_FIXED_CLEAN_GAME.gd - 修復版本的乾淨遊戲
# "Fuck it, I'll write a working version myself" - Linus
extends Node2D

# === WORKING SURVIVOR GAME - NO DEPENDENCIES ===
var player: CharacterBody2D
var enemies: Array[Area2D] = []
var xp_gems: Array[Area2D] = []
var ui_layer: CanvasLayer

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

# HUD
var health_label: Label
var xp_label: Label
var level_label: Label
var time_label: Label

# Input fix - no need for InputMap issues
var input_vector: Vector2 = Vector2.ZERO

func _ready():
    print("🎯 LINUS FIXED CLEAN GAME - Zero dependencies, just works")
    setup_clean_game()

func setup_clean_game():
    """Setup completely self-contained game"""
    create_player()
    create_ui()
    setup_timers()
    print("✅ Clean game ready - WASD to move!")

func create_player():
    """Create self-contained player"""
    player = CharacterBody2D.new()
    player.name = "Player"
    player.global_position = Vector2(400, 300)
    
    # Visual
    var sprite = Sprite2D.new()
    var texture = PlaceholderTexture2D.new()
    texture.size = Vector2(32, 32)
    sprite.texture = texture
    sprite.modulate = Color.GREEN
    player.add_child(sprite)
    
    # Collision for physics
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(32, 32)
    collision.shape = shape
    player.add_child(collision)
    
    # XP pickup area
    var pickup_area = Area2D.new()
    pickup_area.name = "PickupArea"
    var pickup_collision = CollisionShape2D.new()
    var pickup_shape = CircleShape2D.new()
    pickup_shape.radius = 50.0
    pickup_collision.shape = pickup_shape
    pickup_area.add_child(pickup_collision)
    pickup_area.area_entered.connect(_on_pickup_area_entered)
    player.add_child(pickup_area)
    
    add_child(player)

func create_ui():
    """Create self-contained UI"""
    ui_layer = CanvasLayer.new()
    add_child(ui_layer)
    
    # Health
    health_label = Label.new()
    health_label.text = "Health: 100/100"
    health_label.position = Vector2(10, 10)
    health_label.add_theme_color_override("font_color", Color.RED)
    ui_layer.add_child(health_label)
    
    # XP  
    xp_label = Label.new()
    xp_label.text = "XP: 0/100"
    xp_label.position = Vector2(10, 40)
    xp_label.add_theme_color_override("font_color", Color.BLUE)
    ui_layer.add_child(xp_label)
    
    # Level
    level_label = Label.new()
    level_label.text = "Level: 1"  
    level_label.position = Vector2(10, 70)
    level_label.add_theme_color_override("font_color", Color.YELLOW)
    ui_layer.add_child(level_label)
    
    # Time
    time_label = Label.new()
    time_label.text = "Time: 0:00"
    time_label.position = Vector2(10, 100)
    time_label.add_theme_color_override("font_color", Color.WHITE)
    ui_layer.add_child(time_label)

func setup_timers():
    """Setup game timers"""
    enemy_spawn_timer = Timer.new()
    enemy_spawn_timer.wait_time = 1.0
    enemy_spawn_timer.timeout.connect(spawn_enemy)
    enemy_spawn_timer.autostart = true
    add_child(enemy_spawn_timer)
    
    weapon_attack_timer = Timer.new()
    weapon_attack_timer.wait_time = 1.0
    weapon_attack_timer.timeout.connect(attack_nearest_enemy)
    weapon_attack_timer.autostart = true
    add_child(weapon_attack_timer)

func _physics_process(delta):
    """Handle player movement manually"""
    handle_input()
    
    if player:
        player.velocity = input_vector * 300.0
        player.move_and_slide()

func handle_input():
    """Manual input handling - no InputMap dependencies"""
    input_vector = Vector2.ZERO
    
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
        input_vector.y -= 1.0
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
        input_vector.y += 1.0
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        input_vector.x -= 1.0
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        input_vector.x += 1.0
    
    input_vector = input_vector.normalized()

func spawn_enemy():
    """Spawn simple enemy"""
    var enemy = Area2D.new()
    enemy.name = "Enemy"
    
    # Visual
    var sprite = Sprite2D.new()
    var texture = PlaceholderTexture2D.new()
    texture.size = Vector2(20, 20)
    sprite.texture = texture
    sprite.modulate = Color.RED
    enemy.add_child(sprite)
    
    # Collision
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(20, 20)
    collision.shape = shape
    enemy.add_child(collision)
    
    # Position at screen edge
    var screen_size = get_viewport().get_visible_rect().size
    var spawn_pos: Vector2
    match randi() % 4:
        0: spawn_pos = Vector2(randf() * screen_size.x, -30)
        1: spawn_pos = Vector2(screen_size.x + 30, randf() * screen_size.y)
        2: spawn_pos = Vector2(randf() * screen_size.x, screen_size.y + 30)
        3: spawn_pos = Vector2(-30, randf() * screen_size.y)
    
    enemy.global_position = spawn_pos
    enemy.set_meta("health", 50)
    enemy.set_meta("speed", 80.0)
    
    add_child(enemy)
    enemies.append(enemy)
    
    # Limit enemies
    if enemies.size() > 30:
        var old_enemy = enemies[0]
        if is_instance_valid(old_enemy):
            old_enemy.queue_free()
        enemies.remove_at(0)

func attack_nearest_enemy():
    """Simple weapon attack"""
    if enemies.is_empty() or not player:
        return
    
    # Find closest enemy
    var closest_enemy = null
    var closest_distance = 999999.0
    
    for enemy in enemies:
        if is_instance_valid(enemy):
            var distance = player.global_position.distance_to(enemy.global_position)
            if distance < closest_distance:
                closest_distance = distance
                closest_enemy = enemy
    
    if closest_enemy and closest_distance < 200:
        # Create projectile
        var projectile = Area2D.new()
        projectile.name = "Projectile"
        projectile.global_position = player.global_position
        
        # Visual
        var sprite = Sprite2D.new()
        var texture = PlaceholderTexture2D.new()
        texture.size = Vector2(8, 8)
        sprite.texture = texture
        sprite.modulate = Color.YELLOW
        projectile.add_child(sprite)
        
        # Collision
        var collision = CollisionShape2D.new()
        var shape = CircleShape2D.new()
        shape.radius = 4.0
        collision.shape = shape
        projectile.add_child(collision)
        
        # Movement towards enemy
        var direction = (closest_enemy.global_position - player.global_position).normalized()
        projectile.set_meta("direction", direction)
        projectile.set_meta("lifetime", 2.0)
        projectile.area_entered.connect(_on_projectile_hit)
        
        add_child(projectile)

func _on_projectile_hit(projectile_area, other_area):
    """Handle projectile hitting enemy"""
    if other_area.name == "Enemy":
        # Damage enemy
        var health = other_area.get_meta("health", 50)
        health -= 25
        other_area.set_meta("health", health)
        
        # Visual feedback
        other_area.modulate = Color.WHITE.lerp(Color.RED, 0.5)
        var tween = create_tween()
        tween.tween_property(other_area, "modulate", Color.WHITE, 0.2)
        
        # Remove projectile
        if is_instance_valid(projectile_area.get_parent()):
            projectile_area.get_parent().queue_free()
        
        # Check enemy death
        if health <= 0:
            kill_enemy(other_area)

func kill_enemy(enemy):
    """Kill enemy and drop XP"""
    # Drop XP gem
    var xp_gem = Area2D.new()
    xp_gem.name = "XPGem"
    xp_gem.global_position = enemy.global_position
    
    # Visual
    var sprite = Sprite2D.new()
    var texture = PlaceholderTexture2D.new()
    texture.size = Vector2(10, 10)
    sprite.texture = texture
    sprite.modulate = Color.CYAN
    xp_gem.add_child(sprite)
    
    # Collision
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 5.0
    collision.shape = shape
    xp_gem.add_child(collision)
    
    add_child(xp_gem)
    xp_gems.append(xp_gem)
    
    # Remove enemy
    enemies.erase(enemy)
    enemy.queue_free()

func _on_pickup_area_entered(area):
    """Handle XP pickup"""
    if area.name == "XPGem":
        player_xp += 10
        area.queue_free()
        xp_gems.erase(area)
        
        # Check level up
        if player_xp >= player_max_xp:
            level_up()

func level_up():
    """Simple level up"""
    player_level += 1
    player_xp = 0
    player_max_xp = int(player_max_xp * 1.2)
    
    # Increase weapon speed
    weapon_attack_timer.wait_time = max(0.3, weapon_attack_timer.wait_time - 0.1)
    
    print("🎉 Level Up! Now level %d" % player_level)

func update_projectiles(delta):
    """Update projectile movement"""
    var projectiles = get_tree().get_nodes_in_group("projectiles")
    for projectile in projectiles:
        if not is_instance_valid(projectile):
            continue
        
        var direction = projectile.get_meta("direction", Vector2.ZERO)
        var lifetime = projectile.get_meta("lifetime", 0.0)
        
        # Move
        projectile.global_position += direction * 400.0 * delta
        
        # Update lifetime
        lifetime -= delta
        projectile.set_meta("lifetime", lifetime)
        
        if lifetime <= 0:
            projectile.queue_free()

func update_enemies(delta):
    """Update enemy AI"""
    for enemy in enemies:
        if not is_instance_valid(enemy) or not player:
            continue
        
        var speed = enemy.get_meta("speed", 80.0)
        var direction = (player.global_position - enemy.global_position).normalized()
        enemy.global_position += direction * speed * delta

func update_ui():
    """Update HUD"""
    health_label.text = "Health: %d/%d" % [player_health, player_max_health]
    xp_label.text = "XP: %d/%d" % [player_xp, player_max_xp]
    level_label.text = "Level: %d" % player_level
    
    var minutes = int(game_time) / 60
    var seconds = int(game_time) % 60
    time_label.text = "Time: %d:%02d" % [minutes, seconds]

func _process(delta):
    """Main game loop"""
    game_time += delta
    update_projectiles(delta)
    update_enemies(delta)
    update_ui()
    
    # Clean up invalid references
    enemies = enemies.filter(func(e): return is_instance_valid(e))
    xp_gems = xp_gems.filter(func(g): return is_instance_valid(g))

func _input(event):
    """Handle special input"""
    if event.is_action_pressed("ui_cancel"):
        print("👋 Exiting clean game")
        get_tree().quit()
    
    if event.is_action_pressed("ui_accept"):
        print("=== CLEAN GAME STATUS ===")
        print("Level: %d | XP: %d/%d" % [player_level, player_xp, player_max_xp])
        print("Enemies: %d | Time: %.1fs" % [enemies.size(), game_time])
        print("=========================")