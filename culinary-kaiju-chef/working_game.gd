# Working game test - simplified version
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var enemy_template: Area2D = $EnemyTemplate
@onready var status_label: Label = $UI/StatusLabel

var player_health: int = 100
var score: int = 0
var enemies: Array[Area2D] = []
var spawn_timer: float = 0.0

func _ready():
    print("=== WORKING GAME TEST STARTED ===")
    
    # Test autoloads
    var autoload_status = ""
    if EventBus: autoload_status += "EventBus✓ "
    if Game: autoload_status += "Game✓ "
    if ObjectPool: autoload_status += "ObjectPool✓ "
    if DataManager: autoload_status += "DataManager✓ "
    
    print("Autoloads: ", autoload_status)
    
    # Hide template enemy
    enemy_template.hide()
    
    # Connect XP collector
    $Player/XPCollector.area_entered.connect(_on_xp_collected)
    
    # Create initial enemy
    spawn_enemy()
    
    update_status()

func _process(delta):
    # Player movement
    if player:
        var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
        player.velocity = input_dir * 300
        player.move_and_slide()
    
    # Enemy spawning
    spawn_timer += delta
    if spawn_timer > 3.0:
        spawn_timer = 0.0
        spawn_enemy()
    
    # Update enemies
    for enemy in enemies:
        if is_instance_valid(enemy) and player:
            var direction = (player.global_position - enemy.global_position).normalized()
            enemy.global_position += direction * 50 * delta
            
            # Check if enemy reached player
            if enemy.global_position.distance_to(player.global_position) < 40:
                player_health -= 1
                if player_health <= 0:
                    print("GAME OVER!")
                    get_tree().reload_current_scene()
                update_status()
    
    # Clean up invalid enemies
    enemies = enemies.filter(func(e): return is_instance_valid(e))

func spawn_enemy():
    var enemy = enemy_template.duplicate()
    add_child(enemy)
    
    # Spawn outside screen
    var angle = randf() * TAU
    var distance = 800
    enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * distance
    enemy.show()
    
    # Make enemy clickable to kill
    enemy.input_event.connect(func(viewport, event, shape_idx): 
        if event is InputEventMouseButton and event.pressed:
            kill_enemy(enemy)
    )
    
    enemies.append(enemy)
    print("Spawned enemy at: ", enemy.global_position)

func kill_enemy(enemy: Area2D):
    if is_instance_valid(enemy):
        score += 10
        enemy.queue_free()
        enemies.erase(enemy)
        
        # Create simple XP gem
        var xp_gem = ColorRect.new()
        xp_gem.size = Vector2(8, 8)
        xp_gem.color = Color.CYAN
        add_child(xp_gem)
        xp_gem.global_position = enemy.global_position
        
        # Make it an Area2D for collection
        var area = Area2D.new()
        var shape = CollisionShape2D.new()
        var circle = CircleShape2D.new()
        circle.radius = 4
        shape.shape = circle
        area.add_child(shape)
        area.collision_layer = 32
        area.global_position = enemy.global_position
        add_child(area)
        
        print("Enemy killed! Score: ", score)
        update_status()

func _on_xp_collected(area: Area2D):
    print("XP Collected!")
    area.queue_free()
    score += 5
    update_status()

func update_status():
    status_label.text = "Use WASD to move\nClick enemies to kill them\nHealth: %d\nScore: %d\nEnemies: %d" % [player_health, score, enemies.size()]

func _input(event):
    if event.is_action_pressed("ui_accept"):
        print("=== MANUAL ENEMY SPAWN ===")
        spawn_enemy()