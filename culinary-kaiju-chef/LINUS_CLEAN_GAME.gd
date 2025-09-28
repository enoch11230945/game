# LINUS_CLEAN_GAME.gd - 這才是真正的遊戲
# "Talk is cheap. Show me the code." - Linus
extends Node2D

# === MINIMAL WORKING GAME - No bullshit, just working code ===
var player: CharacterBody2D
var spawn_timer: Timer
var enemies: Array[Node2D] = []
var game_time: float = 0.0

func _ready():
    print("🎯 LINUS CLEAN GAME - Starting minimal working game")
    
    # 1. Create player FIRST
    _create_player()
    
    # 2. Start enemy spawning SECOND  
    _setup_enemy_spawning()
    
    # 3. Start game loop THIRD
    _start_game_loop()
    
    print("✅ Minimal game running - WASD to move, survive!")

func _create_player():
    """Create player with MINIMAL setup"""
    # Use existing player scene if it exists
    var player_scene_path = "res://features/player/Player.tscn"
    if ResourceLoader.exists(player_scene_path):
        var player_scene = load(player_scene_path)
        player = player_scene.instantiate()
    else:
        # Create minimal player if scene doesn't exist
        player = _create_minimal_player()
    
    player.global_position = Vector2(400, 300)
    add_child(player)
    print("✅ Player created at center")

func _create_minimal_player() -> CharacterBody2D:
    """Create absolute minimal player if no scene exists"""
    var p = CharacterBody2D.new()
    p.name = "Player"
    
    # Add sprite
    var sprite = Sprite2D.new()
    var texture = PlaceholderTexture2D.new()
    texture.size = Vector2(32, 32)
    sprite.texture = texture
    sprite.modulate = Color.GREEN
    p.add_child(sprite)
    
    # Add collision
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(32, 32)
    collision.shape = shape
    p.add_child(collision)
    
    # Add movement script
    var script = GDScript.new()
    script.source_code = """
extends CharacterBody2D

var speed = 300.0

func _physics_process(delta):
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input_dir * speed
    move_and_slide()
"""
    script.reload()
    p.set_script(script)
    
    p.add_to_group("player")
    return p

func _setup_enemy_spawning():
    """Setup MINIMAL enemy spawning"""
    spawn_timer = Timer.new()
    spawn_timer.wait_time = 2.0
    spawn_timer.timeout.connect(_spawn_enemy)
    spawn_timer.autostart = true
    add_child(spawn_timer)
    print("✅ Enemy spawning every 2 seconds")

func _spawn_enemy():
    """Spawn ONE enemy at random edge"""
    var enemy = _create_minimal_enemy()
    
    # Spawn at random screen edge
    var screen_size = get_viewport().get_visible_rect().size
    var edge = randi() % 4
    var spawn_pos = Vector2.ZERO
    
    match edge:
        0: spawn_pos = Vector2(randf() * screen_size.x, -50)  # Top
        1: spawn_pos = Vector2(screen_size.x + 50, randf() * screen_size.y)  # Right
        2: spawn_pos = Vector2(randf() * screen_size.x, screen_size.y + 50)  # Bottom
        3: spawn_pos = Vector2(-50, randf() * screen_size.y)  # Left
    
    enemy.global_position = spawn_pos
    add_child(enemy)
    enemies.append(enemy)
    
    # Limit enemy count to prevent lag
    if enemies.size() > 50:
        var old_enemy = enemies.pop_front()
        if is_instance_valid(old_enemy):
            old_enemy.queue_free()

func _create_minimal_enemy() -> Area2D:
    """Create absolute minimal enemy"""
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
    
    # Add enemy behavior script
    var script = GDScript.new()
    script.source_code = """
extends Area2D

var speed = 100.0
var player_ref = null

func _ready():
    player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
    if player_ref and is_instance_valid(player_ref):
        var direction = (player_ref.global_position - global_position).normalized()
        global_position += direction * speed * delta
"""
    script.reload()
    enemy.set_script(script)
    
    return enemy

func _start_game_loop():
    """Start minimal game loop"""
    print("✅ Game loop started")

func _process(delta):
    """Minimal game loop - just track time"""
    game_time += delta
    
    # Show time in console every 10 seconds
    if int(game_time) % 10 == 0 and int(game_time * 10) % 10 == 0:
        print("⏰ Game time: %.1fs | Enemies: %d" % [game_time, enemies.size()])

func _input(event):
    """Minimal input handling"""
    if event.is_action_pressed("ui_cancel"):
        print("👋 Exiting LINUS CLEAN GAME")
        get_tree().quit()