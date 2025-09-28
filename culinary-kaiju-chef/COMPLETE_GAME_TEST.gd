# COMPLETE_GAME_TEST.gd - Full working game implementation
extends Node2D

# Game state
var player: CharacterBody2D
var enemies: Array[Area2D] = []
var xp_gems: Array[Area2D] = []
var weapons: Array[Node2D] = []

# Game config
var enemy_spawn_timer: float = 0.0
var enemy_spawn_interval: float = 2.0
var game_time: float = 0.0

# Scenes
var enemy_scene = preload("res://features/enemies/base_enemy/BaseEnemy.tscn")
var xp_gem_scene = preload("res://features/items/xp_gem/XPGem.tscn")
var projectile_scene = preload("res://features/weapons/base_weapon/BaseProjectile.tscn")

func _ready() -> void:
    print("=== COMPLETE GAME TEST STARTED ===")
    
    # Create player manually
    create_player()
    
    # Create weapon system
    create_weapon_system()
    
    # Start enemy spawning
    enemy_spawn_timer = enemy_spawn_interval
    
    print("✅ Game systems initialized")
    print("🎮 Use WASD to move, enemies spawn automatically")

func create_player() -> void:
    player = CharacterBody2D.new()
    player.name = "Player"
    
    # Add sprite
    var sprite = Sprite2D.new()
    sprite.modulate = Color(0, 0.8, 1, 1)
    sprite.scale = Vector2(40, 40)
    player.add_child(sprite)
    
    # Add collision
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 20.0
    collision.shape = shape
    player.add_child(collision)
    
    # Add to scene
    add_child(player)
    player.global_position = Vector2(400, 300)
    player.add_to_group("player")
    
    print("✅ Player created at %s" % player.global_position)

func create_weapon_system() -> void:
    var weapon = Node2D.new()
    weapon.name = "AutoWeapon"
    player.add_child(weapon)
    
    # Attack timer
    var timer = Timer.new()
    timer.wait_time = 1.0
    timer.timeout.connect(_on_weapon_attack)
    timer.autostart = true
    weapon.add_child(timer)
    
    weapons.append(weapon)
    print("✅ Weapon system created")

func _process(delta: float) -> void:
    game_time += delta
    
    # Player movement
    handle_player_movement(delta)
    
    # Enemy spawning
    enemy_spawn_timer -= delta
    if enemy_spawn_timer <= 0:
        spawn_enemy()
        enemy_spawn_timer = enemy_spawn_interval
    
    # Enemy AI
    update_enemy_ai(delta)
    
    # XP collection
    check_xp_collection()
    
    # Cleanup invalid nodes
    cleanup_invalid_entities()

func handle_player_movement(delta: float) -> void:
    if not player:
        return
    
    var input_dir = Vector2.ZERO
    if Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_A):
        input_dir.x -= 1
    if Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_D):
        input_dir.x += 1
    if Input.is_action_pressed("move_up") or Input.is_key_pressed(KEY_W):
        input_dir.y -= 1
    if Input.is_action_pressed("move_down") or Input.is_key_pressed(KEY_S):
        input_dir.y += 1
    
    if input_dir != Vector2.ZERO:
        player.velocity = input_dir.normalized() * 300.0
        player.move_and_slide()

func spawn_enemy() -> void:
    var enemy = enemy_scene.instantiate()
    if not enemy:
        return
    
    add_child(enemy)
    
    # Random spawn position around screen edge
    var spawn_pos = get_random_spawn_position()
    enemy.global_position = spawn_pos
    
    # Create simple enemy data
    var enemy_data = EnemyData.new()
    enemy_data.enemy_name = "Basic Enemy"
    enemy_data.health = 50
    enemy_data.speed = 80.0
    enemy_data.damage = 10
    enemy_data.experience_reward = 15
    
    # Initialize enemy
    if enemy.has_method("initialize"):
        enemy.initialize(spawn_pos, enemy_data)
    
    enemy.add_to_group("enemies")
    enemies.append(enemy)
    
    print("👹 Enemy spawned at %s (Total: %d)" % [spawn_pos, enemies.size()])

func get_random_spawn_position() -> Vector2:
    var screen_size = get_viewport().get_visible_rect().size
    var player_pos = player.global_position if player else Vector2(400, 300)
    
    var spawn_distance = 600.0
    var angle = randf() * TAU
    return player_pos + Vector2.from_angle(angle) * spawn_distance

func update_enemy_ai(delta: float) -> void:
    if not player:
        return
    
    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        
        # Simple AI: move towards player
        var direction = (player.global_position - enemy.global_position).normalized()
        enemy.global_position += direction * 80.0 * delta
        
        # Check collision with player
        var distance = player.global_position.distance_to(enemy.global_position)
        if distance < 50.0:
            # Damage player (simplified)
            print("💥 Player hit by enemy!")
            # Push enemy back slightly
            enemy.global_position -= direction * 30.0

func _on_weapon_attack() -> void:
    if not player or enemies.is_empty():
        return
    
    # Find nearest enemy
    var nearest_enemy = null
    var nearest_distance = INF
    
    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        var distance = player.global_position.distance_to(enemy.global_position)
        if distance < nearest_distance:
            nearest_distance = distance
            nearest_enemy = enemy
    
    if nearest_enemy and nearest_distance < 400.0:
        fire_projectile_at_enemy(nearest_enemy)

func fire_projectile_at_enemy(target: Node2D) -> void:
    var projectile = projectile_scene.instantiate()
    if not projectile:
        return
    
    add_child(projectile)
    projectile.global_position = player.global_position
    
    var direction = (target.global_position - player.global_position).normalized()
    
    # Simple projectile movement
    var tween = create_tween()
    var target_pos = target.global_position
    tween.tween_property(projectile, "global_position", target_pos, 0.5)
    tween.tween_callback(func(): hit_enemy(projectile, target))

func hit_enemy(projectile: Node2D, enemy: Node2D) -> void:
    if not is_instance_valid(enemy):
        if is_instance_valid(projectile):
            projectile.queue_free()
        return
    
    print("🎯 Hit enemy with projectile!")
    
    # Damage enemy (simplified)
    spawn_xp_gem(enemy.global_position)
    
    # Remove enemy
    enemies.erase(enemy)
    enemy.queue_free()
    
    # Remove projectile
    if is_instance_valid(projectile):
        projectile.queue_free()

func spawn_xp_gem(pos: Vector2) -> void:
    var gem = xp_gem_scene.instantiate()
    if not gem:
        return
    
    add_child(gem)
    gem.global_position = pos
    
    if gem.has_method("initialize"):
        gem.initialize(15)
    
    gem.add_to_group("collectables")
    xp_gems.append(gem)
    
    print("💎 XP gem spawned at %s" % pos)

func check_xp_collection() -> void:
    if not player:
        return
    
    for gem in xp_gems:
        if not is_instance_valid(gem):
            continue
        
        var distance = player.global_position.distance_to(gem.global_position)
        if distance < 80.0:
            # Collect XP
            print("✨ Collected XP gem!")
            EventBus.xp_gained.emit(15)
            
            xp_gems.erase(gem)
            gem.queue_free()

func cleanup_invalid_entities() -> void:
    # Clean up invalid enemies
    for i in range(enemies.size() - 1, -1, -1):
        if not is_instance_valid(enemies[i]):
            enemies.remove_at(i)
    
    # Clean up invalid XP gems
    for i in range(xp_gems.size() - 1, -1, -1):
        if not is_instance_valid(xp_gems[i]):
            xp_gems.remove_at(i)

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):  # SPACE
        print("🎮 Game Stats:")
        print("  - Enemies: %d" % enemies.size())
        print("  - XP Gems: %d" % xp_gems.size())
        print("  - Game Time: %.1fs" % game_time)
        print("  - Player Position: %s" % (player.global_position if player else "None"))