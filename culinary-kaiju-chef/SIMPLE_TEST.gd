# SIMPLE_TEST.gd - Minimal test to verify Godot 4.5 functionality
extends Node2D

var player: CharacterBody2D
var enemies: Array[Area2D] = []
var game_time: float = 0.0

func _ready():
    print("🚀 SIMPLE TEST STARTED")
    print("Godot Version: ", Engine.get_version_info())
    print("Platform: ", OS.get_name())
    
    create_player()
    create_test_enemy()
    
    print("✅ Test setup complete. Use WASD to move, Enter to spawn enemy.")

func create_player():
    player = CharacterBody2D.new()
    player.name = "Player"
    
    # Visual
    var visual = ColorRect.new()
    visual.size = Vector2(40, 40)
    visual.position = Vector2(-20, -20)
    visual.color = Color.GREEN
    player.add_child(visual)
    
    # Collision
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(40, 40)
    collision.shape = shape
    player.add_child(collision)
    
    # Camera
    var camera = Camera2D.new()
    camera.enabled = true
    player.add_child(camera)
    
    add_child(player)
    print("✅ Player created")

func create_test_enemy():
    var enemy = Area2D.new()
    enemy.name = "TestEnemy"
    
    # Visual
    var visual = ColorRect.new()
    visual.size = Vector2(30, 30)
    visual.position = Vector2(-15, -15)
    visual.color = Color.RED
    enemy.add_child(visual)
    
    # Collision
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(30, 30)
    collision.shape = shape
    enemy.add_child(collision)
    
    enemy.global_position = Vector2(200, 200)
    add_child(enemy)
    enemies.append(enemy)
    print("✅ Test enemy created")

func _process(delta):
    game_time += delta
    
    # Player movement
    if player:
        var input_dir = Vector2.ZERO
        if Input.is_action_pressed("move_left"):
            input_dir.x -= 1
        if Input.is_action_pressed("move_right"):
            input_dir.x += 1
        if Input.is_action_pressed("move_up"):
            input_dir.y -= 1
        if Input.is_action_pressed("move_down"):
            input_dir.y += 1
        
        player.velocity = input_dir.normalized() * 200
        player.move_and_slide()
    
    # Simple enemy AI
    for enemy in enemies:
        if is_instance_valid(enemy) and player:
            var direction = (player.global_position - enemy.global_position).normalized()
            enemy.global_position += direction * 50 * delta

func _input(event):
    if event.is_action_pressed("ui_accept"):
        create_test_enemy()
        print("🔥 Enemy spawned! Total: ", enemies.size())
    
    if event.is_action_pressed("ui_cancel"):
        print("📊 Game Stats:")
        print("  Time: %.1f seconds" % game_time)
        print("  Enemies: ", enemies.size())
        print("  Player position: ", player.global_position if player else "None")