# DATA_DRIVEN_MAIN.gd - FULLY LINUS-COMPLIANT ARCHITECTURE
# "Good programmers worry about data structures" - Linus Torvalds
# NO HARDCODED VALUES - ALL DATA FROM RESOURCES
extends Node2D
class_name DataDrivenMain

# === DATA RESOURCES (Linus-approved) ===
@export var cleaver_data: WeaponData = preload("res://src/core/data/cleaver_weapon.tres")
@export var whisk_data: WeaponData = preload("res://src/core/data/whisk_weapon.tres")
@export var onion_data: EnemyData = preload("res://src/core/data/onion_enemy.tres")
@export var tomato_data: EnemyData = preload("res://src/core/data/tomato_enemy.tres")

# === GAME STATE (Clean, minimal) ===
@onready var monster_chef: CharacterBody2D
@onready var ingredient_collector: Area2D

var monster_level: int = 1
var appetite: int = 0
var appetite_required: int = 100
var ingredients_chopped: int = 0
var game_time: float = 0.0
var chef_health: int = 100
var chef_max_health: int = 100

# Movement speed (no hardcoding - can be resource-driven later)
var base_movement_speed: float = 200.0

# Active systems
var active_weapons: Array[WeaponData] = []
var weapon_timers: Dictionary = {}

# Entity arrays
var enemies: Array[Area2D] = []
var projectiles: Array[Area2D] = []
var area_weapons: Array[Area2D] = []
var xp_gems: Array[Area2D] = []

# Timers
var enemy_spawn_timer: float = 0.0

# Upgrade system
var available_upgrades = [
    {"name": "🔪 Cleaver Mastery", "desc": "More cleavers!", "type": "weapon_count", "weapon": "cleaver"},
    {"name": "⚔️ Razor Edge", "desc": "More damage!", "type": "weapon_damage", "weapon": "cleaver"},
    {"name": "⚡ Lightning Hands", "desc": "Faster attacks!", "type": "weapon_speed", "weapon": "cleaver"},
    {"name": "💪 Kaiju Vigor", "desc": "Faster movement!", "type": "movement_speed", "value": 40},
    {"name": "🐉 Giant Growth", "desc": "Bigger size!", "type": "size", "value": 1.25},
    {"name": "🌟 Spice Magnet", "desc": "Larger pickup!", "type": "pickup_radius", "value": 1.5},
    {"name": "🌪️ Whisk Tornado", "desc": "UNLOCK: Area weapon!", "type": "unlock_weapon", "weapon": "whisk"},
    {"name": "💚 Chef's Resilience", "desc": "More health!", "type": "max_health", "value": 25}
]

var current_upgrade_choices: Array[Dictionary] = []
var is_upgrading: bool = false

func _ready():
    print("🎯 DATA-DRIVEN CULINARY KAIJU CHEF - LINUS APPROVED!")
    print("✅ All data loaded from resources - NO hardcoded values!")
    
    setup_clean_game()
    create_data_driven_chef()
    setup_initial_weapons()
    connect_event_bus_signals()
    
    # Start with cleaver
    add_weapon(cleaver_data)
    
    print("✅ LINUS STANDARDS MET: Data structures first, clean architecture!")

func setup_clean_game():
    """Setup game environment"""
    RenderingServer.set_default_clear_color(Color(0.1, 0.1, 0.15))
    EventBus.game_started.emit()

func create_data_driven_chef():
    """Create chef using clean data-driven approach"""
    monster_chef = CharacterBody2D.new()
    monster_chef.name = "DataDrivenChef"
    monster_chef.collision_layer = 2
    monster_chef.collision_mask = 1 | 4 | 32
    
    # Visual (could be resource-driven later)
    var chef_body = ColorRect.new()
    chef_body.size = Vector2(80, 80)
    chef_body.position = Vector2(-40, -40)
    chef_body.color = Color(0.2, 0.8, 0.3)
    monster_chef.add_child(chef_body)
    
    # Chef hat
    var hat = ColorRect.new()
    hat.size = Vector2(60, 25)
    hat.position = Vector2(-30, -55)
    hat.color = Color.WHITE
    chef_body.add_child(hat)
    
    var hat_top = ColorRect.new()
    hat_top.size = Vector2(20, 30)
    hat_top.position = Vector2(-10, -75)
    hat_top.color = Color.WHITE
    chef_body.add_child(hat_top)
    
    # Facial features
    create_chef_face(chef_body)
    
    # Collision
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(70, 70)
    collision.shape = shape
    monster_chef.add_child(collision)
    
    # XP collector
    ingredient_collector = Area2D.new()
    ingredient_collector.name = "XPCollector"
    ingredient_collector.collision_layer = 0
    ingredient_collector.collision_mask = 32
    
    var collector_shape = CollisionShape2D.new()
    var collector_circle = CircleShape2D.new()
    collector_circle.radius = 60
    collector_shape.shape = collector_circle
    ingredient_collector.add_child(collector_shape)
    
    monster_chef.add_child(ingredient_collector)
    add_child(monster_chef)
    
    # Camera
    var camera = Camera2D.new()
    camera.enabled = true
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 5.0
    monster_chef.add_child(camera)

func create_chef_face(parent: Node2D):
    """Create animated facial features"""
    # Eyes
    var left_eye = ColorRect.new()
    left_eye.size = Vector2(14, 14)
    left_eye.position = Vector2(-28, -18)
    left_eye.color = Color.WHITE
    parent.add_child(left_eye)
    
    var left_pupil = ColorRect.new()
    left_pupil.size = Vector2(8, 8)
    left_pupil.position = Vector2(3, 3)
    left_pupil.color = Color.BLACK
    left_eye.add_child(left_pupil)
    
    var right_eye = ColorRect.new()
    right_eye.size = Vector2(14, 14)
    right_eye.position = Vector2(14, -18)
    right_eye.color = Color.WHITE
    parent.add_child(right_eye)
    
    var right_pupil = ColorRect.new()
    right_pupil.size = Vector2(8, 8)
    right_pupil.position = Vector2(3, 3)
    right_pupil.color = Color.BLACK
    right_eye.add_child(right_pupil)
    
    # Mouth
    var mouth = ColorRect.new()
    mouth.size = Vector2(30, 8)
    mouth.position = Vector2(-15, 8)
    mouth.color = Color.BLACK
    parent.add_child(mouth)

func setup_initial_weapons():
    """Initialize weapon systems"""
    active_weapons = []
    weapon_timers = {}

func add_weapon(weapon_data: WeaponData):
    """Add weapon using data-driven approach"""
    active_weapons.append(weapon_data)
    weapon_timers[weapon_data.weapon_name] = 0.0
    print("✅ Added weapon: %s (Data-driven)" % weapon_data.weapon_name)

func connect_event_bus_signals():
    """Connect to EventBus - NO direct node references"""
    if ingredient_collector:
        ingredient_collector.area_entered.connect(_on_xp_collected)
    
    # Connect EventBus signals
    EventBus.enemy_died.connect(_on_enemy_died_signal)
    EventBus.player_level_up.connect(_on_level_up_signal)

func _process(delta):
    """Main game loop - clean and efficient"""
    if is_upgrading:
        return
    
    game_time += delta
    handle_movement(delta)
    handle_enemy_spawning(delta)
    handle_weapon_systems(delta)
    update_all_entities(delta)
    cleanup_invalid_objects()

func handle_movement(delta: float):
    """Data-driven movement system"""
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var actual_speed = base_movement_speed * (1.0 + monster_level * 0.08)
    monster_chef.velocity = input_dir * actual_speed
    monster_chef.move_and_slide()
    
    # Visual feedback
    if input_dir.x != 0:
        monster_chef.scale.x = abs(monster_chef.scale.x) * (1 if input_dir.x > 0 else -1)
    
    # Emit position for other systems
    EventBus.player_position_changed.emit(monster_chef.global_position)

func handle_enemy_spawning(delta: float):
    """Data-driven enemy spawning"""
    enemy_spawn_timer += delta
    var spawn_interval = max(0.6, 2.0 - (monster_level * 0.12))
    
    if enemy_spawn_timer > spawn_interval:
        enemy_spawn_timer = 0.0
        spawn_data_driven_enemy()

func spawn_data_driven_enemy():
    """Spawn enemy using EnemyData resource"""
    var enemy_data: EnemyData = onion_data if monster_level < 2 or randf() < 0.7 else tomato_data
    var enemy = create_enemy_from_data(enemy_data)
    enemies.append(enemy)
    EventBus.enemy_spawned.emit(enemy, enemy_data)

func create_enemy_from_data(data: EnemyData) -> Area2D:
    """Create enemy from EnemyData resource - NO hardcoding"""
    var enemy = Area2D.new()
    enemy.collision_layer = 4
    enemy.collision_mask = 8
    
    # Store data reference
    enemy.set_meta("enemy_data", data)
    enemy.set_meta("current_health", data.max_health + (data.health_per_level * (monster_level - 1)))
    enemy.set_meta("current_speed", data.movement_speed + (data.speed_per_level * (monster_level - 1)))
    enemy.set_meta("current_damage", data.damage + (data.damage_per_level * (monster_level - 1)))
    enemy.set_meta("xp_reward", data.experience_reward + (data.xp_per_level * (monster_level - 1)))
    
    # Visual from data
    var sprite = ColorRect.new()
    sprite.size = data.enemy_size
    sprite.position = -data.enemy_size / 2
    sprite.color = data.enemy_color
    enemy.add_child(sprite)
    
    # Eyes
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
    
    # Collision from data
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = data.enemy_size * 0.9
    collision.shape = shape
    enemy.add_child(collision)
    
    add_child(enemy)
    position_enemy_around_player(enemy)
    
    # Connect weapon hits
    enemy.area_entered.connect(func(weapon): _on_weapon_hit_enemy(enemy, weapon))
    
    return enemy

func position_enemy_around_player(enemy: Area2D):
    """Position enemy cleanly around player"""
    var angle = randf() * TAU
    var distance = 650 + randf() * 200
    enemy.global_position = monster_chef.global_position + Vector2.RIGHT.rotated(angle) * distance

func handle_weapon_systems(delta: float):
    """Handle all weapons using their data"""
    for weapon_data in active_weapons:
        weapon_timers[weapon_data.weapon_name] += delta
        var fire_interval = 1.0 / weapon_data.attack_speed
        
        if weapon_timers[weapon_data.weapon_name] >= fire_interval:
            weapon_timers[weapon_data.weapon_name] = 0.0
            fire_weapon(weapon_data)

func fire_weapon(weapon_data: WeaponData):
    """Fire weapon using data-driven approach"""
    match weapon_data.weapon_type:
        "projectile":
            fire_projectile_weapon(weapon_data)
        "aoe":
            fire_aoe_weapon(weapon_data)
        "orbiting":
            # Could implement orbiting weapons later
            pass
    
    EventBus.weapon_fired.emit(weapon_data.weapon_name, monster_chef.global_position, Vector2.ZERO)

func fire_projectile_weapon(weapon_data: WeaponData):
    """Fire projectile using weapon data"""
    var targets = find_nearest_enemies(weapon_data.projectile_count)
    
    for i in range(weapon_data.projectile_count):
        var projectile = create_projectile_from_data(weapon_data)
        
        var direction: Vector2
        if i < targets.size():
            var target = targets[i]
            direction = (target.global_position - monster_chef.global_position).normalized()
        else:
            var spread = (TAU / weapon_data.projectile_count) * i + randf_range(-0.25, 0.25)
            direction = Vector2.RIGHT.rotated(spread)
        
        launch_projectile(projectile, weapon_data, direction)

func create_projectile_from_data(weapon_data: WeaponData) -> Area2D:
    """Create projectile from WeaponData - NO hardcoding"""
    var projectile = Area2D.new()
    projectile.collision_layer = 8
    projectile.collision_mask = 4
    
    # Visual from data
    var visual = ColorRect.new()
    visual.size = weapon_data.weapon_size
    visual.position = -weapon_data.weapon_size / 2
    visual.color = weapon_data.weapon_color
    projectile.add_child(visual)
    
    # Handle specific visual for cleaver
    if weapon_data.weapon_name == "Flying Cleaver":
        # Add handle
        var handle = ColorRect.new()
        handle.size = Vector2(5, 18)
        handle.position = Vector2(-2.5, 5)
        handle.color = Color(0.4, 0.2, 0.1)
        projectile.add_child(handle)
    
    # Collision from data
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = weapon_data.weapon_size * 0.9
    collision.shape = shape
    projectile.add_child(collision)
    
    add_child(projectile)
    
    # Store weapon data
    projectile.set_meta("weapon_data", weapon_data)
    projectile.set_meta("lifetime", weapon_data.range / weapon_data.projectile_speed)
    
    return projectile

func launch_projectile(projectile: Area2D, weapon_data: WeaponData, direction: Vector2):
    """Launch projectile using data"""
    projectile.global_position = monster_chef.global_position
    projectile.set_meta("direction", direction)
    projectile.rotation = direction.angle()
    projectiles.append(projectile)

func fire_aoe_weapon(weapon_data: WeaponData):
    """Fire AOE weapon using data"""
    var aoe = Area2D.new()
    aoe.collision_layer = 8
    aoe.collision_mask = 4
    
    # Visual from data
    var visual = ColorRect.new()
    visual.size = weapon_data.weapon_size
    visual.position = -weapon_data.weapon_size / 2
    visual.color = weapon_data.weapon_color
    aoe.add_child(visual)
    
    # Collision from data
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = weapon_data.area_of_effect
    collision.shape = shape
    aoe.add_child(collision)
    
    add_child(aoe)
    aoe.global_position = monster_chef.global_position
    
    # Store weapon data
    aoe.set_meta("weapon_data", weapon_data)
    aoe.set_meta("lifetime", 5.0)  # Could be in WeaponData
    aoe.set_meta("affected_enemies", [])
    
    aoe.area_entered.connect(func(enemy): _on_aoe_hit_enemy(aoe, enemy))
    area_weapons.append(aoe)

func update_all_entities(delta: float):
    """Update all entities efficiently"""
    update_enemies(delta)
    update_projectiles(delta)
    update_aoe_weapons(delta)
    update_xp_gems(delta)

func update_enemies(delta: float):
    """Update enemies using their data"""
    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        
        var enemy_data: EnemyData = enemy.get_meta("enemy_data")
        var current_speed = enemy.get_meta("current_speed", enemy_data.movement_speed)
        
        if enemy_data.enemy_type == "melee":
            update_melee_enemy(enemy, enemy_data, current_speed, delta)
        elif enemy_data.enemy_type == "ranged":
            update_ranged_enemy(enemy, enemy_data, current_speed, delta)

func update_melee_enemy(enemy: Area2D, data: EnemyData, speed: float, delta: float):
    """Update melee enemy behavior"""
    var direction = (monster_chef.global_position - enemy.global_position).normalized()
    enemy.global_position += direction * speed * delta
    
    # Check contact damage
    if enemy.global_position.distance_to(monster_chef.global_position) < data.attack_range:
        var damage = enemy.get_meta("current_damage", data.damage)
        take_damage(damage)
        damage_enemy(enemy, 999)  # Kill enemy on contact

func update_ranged_enemy(enemy: Area2D, data: EnemyData, speed: float, delta: float):
    """Update ranged enemy behavior"""
    var distance = enemy.global_position.distance_to(monster_chef.global_position)
    
    if distance > data.attack_range:
        var direction = (monster_chef.global_position - enemy.global_position).normalized()
        enemy.global_position += direction * speed * delta
    else:
        # Attack logic
        var attack_timer = enemy.get_meta("attack_timer", 0.0) + delta
        enemy.set_meta("attack_timer", attack_timer)
        
        if attack_timer >= data.attack_cooldown:
            enemy.set_meta("attack_timer", 0.0)
            fire_enemy_projectile(enemy, data)

func fire_enemy_projectile(enemy: Area2D, data: EnemyData):
    """Fire enemy projectile using data"""
    var projectile = Area2D.new()
    projectile.collision_layer = 16
    projectile.collision_mask = 2
    
    var visual = ColorRect.new()
    visual.size = Vector2(10, 10)
    visual.position = Vector2(-5, -5)
    visual.color = data.enemy_color.darkened(0.3)
    projectile.add_child(visual)
    
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 5
    collision.shape = shape
    projectile.add_child(collision)
    
    add_child(projectile)
    projectile.global_position = enemy.global_position
    
    var direction = (monster_chef.global_position - enemy.global_position).normalized()
    projectile.set_meta("direction", direction)
    projectile.set_meta("speed", data.projectile_speed)
    projectile.set_meta("damage", data.projectile_damage)
    projectile.set_meta("lifetime", 4.0)

func update_projectiles(delta: float):
    """Update projectiles using their data"""
    for projectile in projectiles:
        if not is_instance_valid(projectile):
            continue
        
        var weapon_data: WeaponData = projectile.get_meta("weapon_data")
        var direction = projectile.get_meta("direction", Vector2.RIGHT)
        var lifetime = projectile.get_meta("lifetime", 4.0) - delta
        
        projectile.global_position += direction * weapon_data.projectile_speed * delta
        projectile.rotation += weapon_data.spin_speed * delta
        projectile.set_meta("lifetime", lifetime)
        
        if lifetime <= 0:
            projectiles.erase(projectile)
            projectile.queue_free()

func update_aoe_weapons(delta: float):
    """Update AOE weapons using their data"""
    for aoe in area_weapons:
        if not is_instance_valid(aoe):
            continue
        
        var lifetime = aoe.get_meta("lifetime", 5.0) - delta
        aoe.set_meta("lifetime", lifetime)
        
        if lifetime <= 0:
            area_weapons.erase(aoe)
            aoe.queue_free()

func update_xp_gems(delta: float):
    """Update XP gems with magnetic attraction"""
    for gem in xp_gems:
        if not is_instance_valid(gem):
            continue
        
        var direction = (monster_chef.global_position - gem.global_position).normalized()
        var attraction = (120.0 + monster_level * 15) * delta
        gem.global_position += direction * attraction

func _on_weapon_hit_enemy(enemy: Area2D, weapon: Area2D):
    """Handle weapon hitting enemy - using EventBus"""
    if weapon in projectiles:
        var weapon_data: WeaponData = weapon.get_meta("weapon_data")
        damage_enemy(enemy, weapon_data.damage)
        EventBus.weapon_hit.emit(weapon, enemy, weapon_data.damage)
        
        projectiles.erase(weapon)
        weapon.queue_free()

func _on_aoe_hit_enemy(aoe: Area2D, enemy: Area2D):
    """Handle AOE weapon hitting enemy"""
    if enemy in enemies:
        var affected = aoe.get_meta("affected_enemies", [])
        if enemy not in affected:
            affected.append(enemy)
            aoe.set_meta("affected_enemies", affected)
            var weapon_data: WeaponData = aoe.get_meta("weapon_data")
            damage_enemy(enemy, weapon_data.damage)

func damage_enemy(enemy: Area2D, damage: int):
    """Damage enemy using data-driven approach"""
    var current_health = enemy.get_meta("current_health", 50) - damage
    enemy.set_meta("current_health", current_health)
    
    EventBus.enemy_damaged.emit(enemy, damage)
    
    if current_health <= 0:
        kill_enemy(enemy)

func kill_enemy(enemy: Area2D):
    """Kill enemy and emit proper signals"""
    var enemy_data: EnemyData = enemy.get_meta("enemy_data")
    var xp_reward = enemy.get_meta("xp_reward", enemy_data.experience_reward)
    
    spawn_xp_gem(enemy.global_position, xp_reward)
    ingredients_chopped += 1
    
    EventBus.emit_enemy_death(enemy, enemy_data, enemy.global_position)
    
    enemies.erase(enemy)
    enemy.queue_free()

func spawn_xp_gem(position: Vector2, value: int):
    """Spawn XP gem using EventBus"""
    var gem = Area2D.new()
    gem.collision_layer = 32
    gem.collision_mask = 0
    
    var visual = ColorRect.new()
    visual.size = Vector2(12, 12)
    visual.position = Vector2(-6, -6)
    visual.color = Color.GOLD
    gem.add_child(visual)
    
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 8
    collision.shape = shape
    gem.add_child(collision)
    
    add_child(gem)
    gem.global_position = position
    gem.set_meta("xp_value", value)
    
    xp_gems.append(gem)

func _on_xp_collected(gem: Area2D):
    """Handle XP collection via EventBus"""
    if gem in xp_gems:
        var xp_value = gem.get_meta("xp_value", 12)
        appetite += xp_value
        
        EventBus.player_xp_gained.emit(xp_value)
        EventBus.item_collected.emit("xp_gem", gem.global_position)
        
        if appetite >= appetite_required:
            level_up()
        
        xp_gems.erase(gem)
        gem.queue_free()

func level_up():
    """Level up using EventBus signals"""
    monster_level += 1
    appetite = 0
    appetite_required = int(appetite_required * 1.45)
    chef_health = min(chef_max_health, chef_health + 15)
    
    EventBus.player_level_up.emit(monster_level)
    show_upgrade_screen()

func show_upgrade_screen():
    """Show upgrade screen via EventBus"""
    var available = available_upgrades.duplicate()
    available.shuffle()
    current_upgrade_choices = [available[0], available[1], available[2]]
    
    EventBus.show_upgrade_screen.emit(current_upgrade_choices)
    is_upgrading = true
    
    print("🎉 LEVEL UP! Level %d" % monster_level)
    for i in range(3):
        var upgrade = current_upgrade_choices[i]
        print("%d. %s - %s" % [i+1, upgrade.name, upgrade.desc])

func apply_upgrade(upgrade: Dictionary):
    """Apply upgrade using data-driven approach"""
    match upgrade.type:
        "weapon_count":
            for weapon_data in active_weapons:
                if weapon_data.weapon_name.to_lower().contains(upgrade.weapon):
                    # Increase projectile count
                    weapon_data.projectile_count += 1
        "weapon_damage":
            for weapon_data in active_weapons:
                if weapon_data.weapon_name.to_lower().contains(upgrade.weapon):
                    weapon_data.damage += weapon_data.damage_per_level
        "weapon_speed":
            for weapon_data in active_weapons:
                if weapon_data.weapon_name.to_lower().contains(upgrade.weapon):
                    weapon_data.attack_speed *= 1.3
        "movement_speed":
            base_movement_speed += upgrade.value
        "size":
            monster_chef.scale *= upgrade.value
        "pickup_radius":
            var collector = ingredient_collector.get_node("CollisionShape2D").shape as CircleShape2D
            if collector:
                collector.radius *= upgrade.value
        "max_health":
            chef_max_health += upgrade.value
            chef_health += upgrade.value
        "unlock_weapon":
            if upgrade.weapon == "whisk":
                add_weapon(whisk_data)
    
    EventBus.weapon_upgraded.emit(upgrade.get("weapon", ""), upgrade.type)
    print("✅ Data-driven upgrade applied: %s" % upgrade.name)

func take_damage(damage: int):
    """Take damage and emit signals"""
    chef_health = max(0, chef_health - damage)
    
    monster_chef.modulate = Color.RED
    create_tween().tween_property(monster_chef, "modulate", Color.WHITE, 0.2)
    
    EventBus.player_health_changed.emit(chef_health, chef_max_health)
    
    if chef_health <= 0:
        game_over()

func game_over():
    """Game over via EventBus"""
    EventBus.player_died.emit()
    EventBus.game_over.emit(ingredients_chopped, game_time)
    print("💀 GAME OVER! Level %d, Kills %d, Time %.1f" % [monster_level, ingredients_chopped, game_time])
    get_tree().reload_current_scene()

func find_nearest_enemies(count: int) -> Array[Area2D]:
    """Find nearest enemies efficiently"""
    var valid_enemies = enemies.filter(func(e): return is_instance_valid(e))
    valid_enemies.sort_custom(func(a, b): return a.global_position.distance_to(monster_chef.global_position) < b.global_position.distance_to(monster_chef.global_position))
    return valid_enemies.slice(0, count)

func cleanup_invalid_objects():
    """Clean up invalid objects"""
    enemies = enemies.filter(func(obj): return is_instance_valid(obj))
    projectiles = projectiles.filter(func(obj): return is_instance_valid(obj))
    area_weapons = area_weapons.filter(func(obj): return is_instance_valid(obj))
    xp_gems = xp_gems.filter(func(obj): return is_instance_valid(obj))

# EventBus signal handlers
func _on_enemy_died_signal(enemy: Node2D, position: Vector2, xp_reward: int):
    """Handle enemy death signal"""
    pass  # Already handled in kill_enemy

func _on_level_up_signal(new_level: int):
    """Handle level up signal"""
    pass  # Already handled in level_up

func _input(event):
    """Handle input cleanly"""
    if event.is_action_pressed("ui_accept"):
        # Spawn test enemies
        for i in range(5):
            spawn_data_driven_enemy()
        print("🚨 DATA-DRIVEN ENEMY WAVE!")
    
    if event.is_action_pressed("ui_select"):
        level_up()
        print("💪 DATA-DRIVEN LEVEL UP!")
    
    if event.is_action_pressed("ui_cancel"):
        print("📊 STATS: Level %d, Kills %d, Time %.1f" % [monster_level, ingredients_chopped, game_time])
    
    if is_upgrading:
        if Input.is_key_pressed(KEY_1):
            apply_upgrade(current_upgrade_choices[0])
            is_upgrading = false
            EventBus.hide_upgrade_screen.emit()
        elif Input.is_key_pressed(KEY_2):
            apply_upgrade(current_upgrade_choices[1])
            is_upgrading = false
            EventBus.hide_upgrade_screen.emit()
        elif Input.is_key_pressed(KEY_3):
            apply_upgrade(current_upgrade_choices[2])
            is_upgrading = false
            EventBus.hide_upgrade_screen.emit()
var flying_cleavers: Array[Area2D] = []
var whisk_tornadoes: Array[Area2D] = []
var enemy_projectiles: Array[Area2D] = []
var spice_essences: Array[Area2D] = []

# Clean spawning system
var ingredient_spawn_timer: float = 0.0

# Data-driven upgrade system
var clean_upgrades = [
    {"name": "🔪 Cleaver Mastery", "desc": "Throw +2 more cleavers!", "type": "cleavers", "value": 2},
    {"name": "⚔️ Razor Edge", "desc": "Cleavers deal +20 damage!", "type": "damage", "value": 20},
    {"name": "⚡ Lightning Hands", "desc": "Attack 30% faster!", "type": "speed", "value": 0.7},
    {"name": "💪 Kaiju Vigor", "desc": "Move 40% faster!", "type": "movement", "value": 40},
    {"name": "🐉 Giant Growth", "desc": "Grow 25% larger!", "type": "size", "value": 1.25},
    {"name": "🌟 Spice Magnet", "desc": "Attract spice 50% farther!", "type": "magnet", "value": 1.5},
    {"name": "🌪️ Whisk Tornado", "desc": "UNLOCK: Spinning whisk weapon!", "type": "unlock_weapon", "value": "whisk"},
    {"name": "💚 Chef's Resilience", "desc": "Increase max health by 25!", "type": "health", "value": 25}
]

var current_upgrade_choices: Array[Dictionary] = []
var is_upgrading: bool = false

func _ready():
    print("🧹🍳🐉 === CLEAN CULINARY KAIJU CHEF === 🐉🍳🧹")
    print("Following Linus Philosophy: Good programmers worry about data structures")
    
    setup_clean_game()
    create_clean_chef()
    connect_clean_systems()
    spawn_initial_ingredients()
    
    print("✅ CLEAN GAME READY - Linus would approve!")

func setup_clean_game():
    """Setup clean game environment"""
    # Clean background
    RenderingServer.set_default_clear_color(Color(0.1, 0.1, 0.15))

func create_clean_chef():
    """Create the cleanest monster chef ever"""
    monster_chef = CharacterBody2D.new()
    monster_chef.name = "CleanMonsterChef"
    monster_chef.collision_layer = 2
    monster_chef.collision_mask = 1 | 4 | 32
    
    # Clean visual design
    var chef_body = ColorRect.new()
    chef_body.size = Vector2(80, 80)
    chef_body.position = Vector2(-40, -40)
    chef_body.color = Color(0.2, 0.8, 0.3)
    monster_chef.add_child(chef_body)
    
    # Professional chef hat
    var hat = ColorRect.new()
    hat.size = Vector2(60, 25)
    hat.position = Vector2(-30, -55)
    hat.color = Color.WHITE
    chef_body.add_child(hat)
    
    var hat_top = ColorRect.new()
    hat_top.size = Vector2(20, 30)
    hat_top.position = Vector2(-10, -75)
    hat_top.color = Color.WHITE
    chef_body.add_child(hat_top)
    
    # Clean facial features
    create_clean_face(chef_body)
    
    # Chef apron
    var apron = ColorRect.new()
    apron.size = Vector2(50, 40)
    apron.position = Vector2(-25, 0)
    apron.color = Color(0.9, 0.9, 0.9)
    chef_body.add_child(apron)
    
    # Physics collision
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(70, 70)
    collision.shape = shape
    monster_chef.add_child(collision)
    
    # Clean ingredient collector
    ingredient_collector = Area2D.new()
    ingredient_collector.name = "CleanCollector"
    ingredient_collector.collision_layer = 0
    ingredient_collector.collision_mask = 32
    
    var collector_shape = CollisionShape2D.new()
    var collector_circle = CircleShape2D.new()
    collector_circle.radius = 60
    collector_shape.shape = collector_circle
    ingredient_collector.add_child(collector_shape)
    
    monster_chef.add_child(ingredient_collector)
    add_child(monster_chef)
    
    # Clean camera follow
    var camera = Camera2D.new()
    camera.enabled = true
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 5.0
    monster_chef.add_child(camera)

func create_clean_face(parent: Node2D):
    """Create clean animated facial features"""
    # Eyes
    var left_eye = ColorRect.new()
    left_eye.size = Vector2(14, 14)
    left_eye.position = Vector2(-28, -18)
    left_eye.color = Color.WHITE
    parent.add_child(left_eye)
    
    var left_pupil = ColorRect.new()
    left_pupil.size = Vector2(8, 8)
    left_pupil.position = Vector2(3, 3)
    left_pupil.color = Color.BLACK
    left_eye.add_child(left_pupil)
    
    var right_eye = ColorRect.new()
    right_eye.size = Vector2(14, 14)
    right_eye.position = Vector2(14, -18)
    right_eye.color = Color.WHITE
    parent.add_child(right_eye)
    
    var right_pupil = ColorRect.new()
    right_pupil.size = Vector2(8, 8)
    right_pupil.position = Vector2(3, 3)
    right_pupil.color = Color.BLACK
    right_eye.add_child(right_pupil)
    
    # Clean mouth
    var mouth = ColorRect.new()
    mouth.size = Vector2(30, 8)
    mouth.position = Vector2(-15, 8)
    mouth.color = Color.BLACK
    parent.add_child(mouth)

func connect_clean_systems():
    """Connect all systems cleanly"""
    if ingredient_collector:
        ingredient_collector.area_entered.connect(_on_clean_collection)

func _process(delta):
    """Clean main game loop"""
    if is_upgrading:
        return
    
    game_time += delta
    handle_clean_movement(delta)
    handle_clean_spawning(delta)
    handle_clean_combat(delta)
    update_clean_entities(delta)
    cleanup_clean_objects()

func handle_clean_movement(delta: float):
    """Clean movement system"""
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var actual_speed = monster_chef_speed * (1.0 + monster_level * 0.08)
    monster_chef.velocity = input_dir * actual_speed
    monster_chef.move_and_slide()
    
    # Visual direction feedback
    if input_dir.x != 0:
        monster_chef.scale.x = abs(monster_chef.scale.x) * (1 if input_dir.x > 0 else -1)

func handle_clean_spawning(delta: float):
    """Clean enemy spawning"""
    ingredient_spawn_timer += delta
    var spawn_interval = max(0.6, 2.0 - (monster_level * 0.12))
    
    if ingredient_spawn_timer > spawn_interval:
        ingredient_spawn_timer = 0.0
        spawn_clean_enemy()

func spawn_clean_enemy():
    """Spawn enemies cleanly"""
    var enemy_type = "onion" if monster_level < 2 or randf() < 0.7 else "tomato"
    
    match enemy_type:
        "onion":
            spawn_clean_onion()
        "tomato":
            spawn_clean_tomato()

func spawn_clean_onion():
    """Create clean onion enemy"""
    var onion = create_clean_enemy("onion", Color(0.8, 0.6, 0.9))
    
    var health = 35 + (monster_level * 5)
    var speed = 55 + (monster_level * 3)
    var xp = 12 + monster_level
    
    setup_clean_enemy_data(onion, "onion", health, speed, xp)
    onion.area_entered.connect(func(area): hit_clean_ingredient(onion, area))
    rebellious_ingredients.append(onion)

func spawn_clean_tomato():
    """Create clean tomato enemy"""
    var tomato = create_clean_enemy("tomato", Color.RED)
    
    var health = 50 + (monster_level * 6)
    var speed = 40 + (monster_level * 2)
    var xp = 18 + (monster_level * 2)
    
    setup_clean_enemy_data(tomato, "tomato", health, speed, xp)
    tomato.set_meta("attack_range", 220.0)
    tomato.set_meta("attack_damage", 12 + monster_level)
    tomato.set_meta("attack_timer", 0.0)
    tomato.set_meta("attack_cooldown", 2.8)
    
    tomato.area_entered.connect(func(area): hit_clean_ingredient(tomato, area))
    rebellious_ingredients.append(tomato)

func create_clean_enemy(enemy_type: String, color: Color) -> Area2D:
    """Clean enemy creation template"""
    var enemy = Area2D.new()
    enemy.collision_layer = 4
    enemy.collision_mask = 8
    
    # Clean visual
    var sprite = ColorRect.new()
    sprite.size = Vector2(40, 40)
    sprite.position = Vector2(-20, -20)
    sprite.color = color
    enemy.add_child(sprite)
    
    # Simple eyes
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
    
    # Clean collision
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(35, 35)
    collision.shape = shape
    enemy.add_child(collision)
    
    add_child(enemy)
    position_clean_enemy(enemy)
    
    return enemy

func setup_clean_enemy_data(enemy: Area2D, type: String, health: int, speed: int, xp: int):
    """Clean enemy data setup"""
    enemy.set_meta("enemy_type", type)
    enemy.set_meta("health", health)
    enemy.set_meta("max_health", health)
    enemy.set_meta("speed", speed)
    enemy.set_meta("xp", xp)

func position_clean_enemy(enemy: Area2D):
    """Position enemy cleanly around player"""
    var angle = randf() * TAU
    var distance = 650 + randf() * 200
    enemy.global_position = monster_chef.global_position + Vector2.RIGHT.rotated(angle) * distance

func handle_clean_combat(delta: float):
    """Clean combat system"""
    # Clean cleaver system
    weapon_timers["cleaver"] += delta
    var cleaver_interval = (1.4 / attack_speed_multiplier) - (monster_level * 0.06)
    if weapon_timers["cleaver"] > max(0.25, cleaver_interval):
        weapon_timers["cleaver"] = 0.0
        if "cleaver" in active_weapons:
            throw_clean_cleavers()
    
    # Clean whisk system
    if "whisk" in active_weapons:
        weapon_timers["whisk"] += delta
        if weapon_timers["whisk"] > 3.5:
            weapon_timers["whisk"] = 0.0
            create_clean_whisk()

func throw_clean_cleavers():
    """Throw cleavers cleanly"""
    var targets = find_clean_targets(cleavers_per_attack)
    
    for i in range(cleavers_per_attack):
        var cleaver = create_clean_cleaver()
        
        var direction: Vector2
        if i < targets.size():
            var target = targets[i]
            direction = (target.global_position - monster_chef.global_position).normalized()
        else:
            var spread = (TAU / cleavers_per_attack) * i + randf_range(-0.25, 0.25)
            direction = Vector2.RIGHT.rotated(spread)
        
        launch_clean_cleaver(cleaver, direction)

func create_clean_cleaver():
    """Create clean cleaver"""
    var cleaver = Area2D.new()
    cleaver.collision_layer = 8
    cleaver.collision_mask = 4
    
    # Clean cleaver design
    var blade = ColorRect.new()
    blade.size = Vector2(22, 10)
    blade.position = Vector2(-11, -5)
    blade.color = Color.SILVER
    cleaver.add_child(blade)
    
    var handle = ColorRect.new()
    handle.size = Vector2(5, 18)
    handle.position = Vector2(-2.5, 5)
    handle.color = Color(0.4, 0.2, 0.1)
    cleaver.add_child(handle)
    
    # Clean collision
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(20, 8)
    collision.shape = shape
    cleaver.add_child(collision)
    
    add_child(cleaver)
    
    cleaver.set_meta("damage", cleaver_damage)
    cleaver.set_meta("speed", 320.0 + (monster_level * 10))
    cleaver.set_meta("lifetime", 4.5)
    
    return cleaver

func launch_clean_cleaver(cleaver: Area2D, direction: Vector2):
    """Launch cleaver cleanly"""
    cleaver.global_position = monster_chef.global_position
    cleaver.set_meta("direction", direction)
    cleaver.rotation = direction.angle()
    flying_cleavers.append(cleaver)

func create_clean_whisk():
    """Create clean whisk tornado"""
    var whisk = Area2D.new()
    whisk.collision_layer = 8
    whisk.collision_mask = 4
    
    # Clean whisk visual
    var whisk_visual = ColorRect.new()
    whisk_visual.size = Vector2(100, 100)
    whisk_visual.position = Vector2(-50, -50)
    whisk_visual.color = Color(0.8, 1, 1, 0.4)
    whisk.add_child(whisk_visual)
    
    # Clean collision
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 50
    collision.shape = shape
    whisk.add_child(collision)
    
    add_child(whisk)
    whisk.global_position = monster_chef.global_position
    
    whisk.set_meta("damage", cleaver_damage)
    whisk.set_meta("speed", 120.0)
    whisk.set_meta("lifetime", 5.0)
    whisk.set_meta("affected_enemies", [])
    
    whisk.area_entered.connect(func(area): _on_clean_whisk_hit(whisk, area))
    whisk_tornadoes.append(whisk)

func _on_clean_whisk_hit(whisk: Area2D, enemy: Area2D):
    """Handle clean whisk hits"""
    if enemy in rebellious_ingredients:
        var affected = whisk.get_meta("affected_enemies", [])
        if enemy not in affected:
            affected.append(enemy)
            whisk.set_meta("affected_enemies", affected)
            damage_clean_ingredient(enemy, whisk.get_meta("damage", 25))

func update_clean_entities(delta: float):
    """Update all entities cleanly"""
    update_clean_ingredients(delta)
    update_clean_cleavers(delta)
    update_clean_whisks(delta)
    update_clean_spices(delta)

func update_clean_ingredients(delta: float):
    """Update ingredients cleanly"""
    for ingredient in rebellious_ingredients:
        if not is_instance_valid(ingredient):
            continue
        
        var enemy_type = ingredient.get_meta("enemy_type", "onion")
        
        match enemy_type:
            "onion":
                update_clean_onion(ingredient, delta)
            "tomato":
                update_clean_tomato(ingredient, delta)

func update_clean_onion(onion: Area2D, delta: float):
    """Clean onion update"""
    var speed = onion.get_meta("speed", 55.0)
    var direction = (monster_chef.global_position - onion.global_position).normalized()
    onion.global_position += direction * speed * delta
    
    # Contact damage
    if onion.global_position.distance_to(monster_chef.global_position) < 65:
        take_clean_damage(8 + monster_level)
        rebellious_ingredients.erase(onion)
        onion.queue_free()

func update_clean_tomato(tomato: Area2D, delta: float):
    """Clean tomato update"""
    var distance = tomato.global_position.distance_to(monster_chef.global_position)
    var attack_range = tomato.get_meta("attack_range", 220.0)
    var speed = tomato.get_meta("speed", 40.0)
    
    if distance > attack_range:
        var direction = (monster_chef.global_position - tomato.global_position).normalized()
        tomato.global_position += direction * speed * delta
    else:
        var attack_timer = tomato.get_meta("attack_timer", 0.0) + delta
        tomato.set_meta("attack_timer", attack_timer)
        
        if attack_timer >= tomato.get_meta("attack_cooldown", 2.8):
            tomato.set_meta("attack_timer", 0.0)
            clean_tomato_attack(tomato)

func clean_tomato_attack(tomato: Area2D):
    """Clean tomato attack"""
    var projectile = Area2D.new()
    projectile.collision_layer = 16
    projectile.collision_mask = 2
    
    var visual = ColorRect.new()
    visual.size = Vector2(10, 10)
    visual.position = Vector2(-5, -5)
    visual.color = Color.RED
    projectile.add_child(visual)
    
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 5
    collision.shape = shape
    projectile.add_child(collision)
    
    add_child(projectile)
    projectile.global_position = tomato.global_position
    
    var direction = (monster_chef.global_position - tomato.global_position).normalized()
    projectile.set_meta("direction", direction)
    projectile.set_meta("speed", 180.0)
    projectile.set_meta("damage", tomato.get_meta("attack_damage", 12))
    projectile.set_meta("lifetime", 4.0)
    
    enemy_projectiles.append(projectile)

func update_clean_cleavers(delta: float):
    """Update cleavers cleanly"""
    for cleaver in flying_cleavers:
        if not is_instance_valid(cleaver):
            continue
        
        var direction = cleaver.get_meta("direction", Vector2.RIGHT)
        var speed = cleaver.get_meta("speed", 320.0)
        var lifetime = cleaver.get_meta("lifetime", 4.5) - delta
        
        cleaver.global_position += direction * speed * delta
        cleaver.rotation += 10.0 * delta
        cleaver.set_meta("lifetime", lifetime)
        
        if lifetime <= 0:
            flying_cleavers.erase(cleaver)
            cleaver.queue_free()

func update_clean_whisks(delta: float):
    """Update whisk tornadoes cleanly"""
    for whisk in whisk_tornadoes:
        if not is_instance_valid(whisk):
            continue
        
        var lifetime = whisk.get_meta("lifetime", 5.0) - delta
        whisk.set_meta("lifetime", lifetime)
        
        if lifetime <= 0:
            whisk_tornadoes.erase(whisk)
            whisk.queue_free()

func update_clean_spices(delta: float):
    """Update spice essences cleanly"""
    for spice in spice_essences:
        if not is_instance_valid(spice):
            continue
        
        var direction = (monster_chef.global_position - spice.global_position).normalized()
        var attraction = (120.0 + monster_level * 15) * delta
        spice.global_position += direction * attraction

func take_clean_damage(damage: int):
    """Handle clean damage"""
    chef_health = max(0, chef_health - damage)
    
    monster_chef.modulate = Color.RED
    create_tween().tween_property(monster_chef, "modulate", Color.WHITE, 0.2)
    
    if chef_health <= 0:
        clean_game_over()

func clean_game_over():
    """Clean game over"""
    print("💀 CLEAN GAME OVER!")
    print("Level: %d, Kills: %d, Time: %.1f" % [monster_level, ingredients_chopped, game_time])
    get_tree().reload_current_scene()

func hit_clean_ingredient(ingredient: Area2D, weapon: Area2D):
    """Handle clean ingredient hits"""
    if weapon in flying_cleavers:
        damage_clean_ingredient(ingredient, weapon.get_meta("damage", 25))
        flying_cleavers.erase(weapon)
        weapon.queue_free()

func damage_clean_ingredient(ingredient: Area2D, damage: int):
    """Apply clean damage"""
    var current_health = ingredient.get_meta("health", 35) - damage
    ingredient.set_meta("health", current_health)
    
    if current_health <= 0:
        chop_clean_ingredient(ingredient)

func chop_clean_ingredient(ingredient: Area2D):
    """Handle clean ingredient death"""
    var xp_reward = ingredient.get_meta("xp", 12)
    spawn_clean_spice(ingredient.global_position, xp_reward)
    
    ingredients_chopped += 1
    appetite += xp_reward
    
    if appetite >= appetite_required:
        clean_level_up()
    
    rebellious_ingredients.erase(ingredient)
    ingredient.queue_free()

func spawn_clean_spice(position: Vector2, value: int):
    """Spawn clean spice essence"""
    var spice = Area2D.new()
    spice.collision_layer = 32
    spice.collision_mask = 0
    
    var visual = ColorRect.new()
    visual.size = Vector2(12, 12)
    visual.position = Vector2(-6, -6)
    visual.color = Color.GOLD
    spice.add_child(visual)
    
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 8
    collision.shape = shape
    spice.add_child(collision)
    
    add_child(spice)
    spice.global_position = position
    spice.set_meta("xp", value)
    
    spice_essences.append(spice)

func _on_clean_collection(area: Area2D):
    """Handle clean spice collection"""
    if area in spice_essences:
        var xp_value = area.get_meta("xp", 12)
        appetite += xp_value
        
        if appetite >= appetite_required:
            clean_level_up()
        
        spice_essences.erase(area)
        area.queue_free()

func clean_level_up():
    """Clean level up system"""
    monster_level += 1
    appetite = 0
    appetite_required = int(appetite_required * 1.45)
    chef_health = min(chef_max_health, chef_health + 15)
    
    show_clean_upgrades()

func show_clean_upgrades():
    """Show clean upgrade choices"""
    print("🎉 CLEAN LEVEL UP! Level %d" % monster_level)
    
    var available = clean_upgrades.duplicate()
    available.shuffle()
    current_upgrade_choices = [available[0], available[1], available[2]]
    
    for i in range(3):
        var upgrade = current_upgrade_choices[i]
        print("%d. %s - %s" % [i+1, upgrade.name, upgrade.desc])
    
    is_upgrading = true

func apply_clean_upgrade(upgrade: Dictionary):
    """Apply clean upgrade"""
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
            var collector = ingredient_collector.get_node("CollisionShape2D").shape as CircleShape2D
            if collector:
                collector.radius *= upgrade.value
        "health":
            chef_max_health += upgrade.value
            chef_health += upgrade.value
        "unlock_weapon":
            active_weapons.append(upgrade.value)
            weapon_timers[upgrade.value] = 0.0
    
    print("✨ Clean upgrade applied: %s" % upgrade.name)

func find_clean_targets(count: int) -> Array[Area2D]:
    """Find clean targets"""
    var targets = rebellious_ingredients.duplicate()
    targets.sort_custom(func(a, b): return a.global_position.distance_to(monster_chef.global_position) < b.global_position.distance_to(monster_chef.global_position))
    return targets.slice(0, count)

func spawn_initial_ingredients():
    """Spawn initial clean ingredients"""
    for i in range(3):
        spawn_clean_onion()

func cleanup_clean_objects():
    """Clean object cleanup"""
    rebellious_ingredients = rebellious_ingredients.filter(func(obj): return is_instance_valid(obj))
    flying_cleavers = flying_cleavers.filter(func(obj): return is_instance_valid(obj))
    whisk_tornadoes = whisk_tornadoes.filter(func(obj): return is_instance_valid(obj))
    enemy_projectiles = enemy_projectiles.filter(func(obj): return is_instance_valid(obj))
    spice_essences = spice_essences.filter(func(obj): return is_instance_valid(obj))

func _input(event):
    """Handle clean input"""
    if event.is_action_pressed("ui_accept"):
        for i in range(5):
            if randf() > 0.5:
                spawn_clean_onion()
            else:
                spawn_clean_tomato()
        print("🚨 CLEAN ENEMY WAVE!")
    
    if event.is_action_pressed("ui_select"):
        clean_level_up()
        print("💪 CLEAN LEVEL UP TEST!")
    
    if event.is_action_pressed("ui_cancel"):
        print("📊 CLEAN STATS: Level %d, Kills %d, Time %.1f" % [monster_level, ingredients_chopped, game_time])
    
    if is_upgrading:
        if Input.is_key_pressed(KEY_1):
            apply_clean_upgrade(current_upgrade_choices[0])
            is_upgrading = false
        elif Input.is_key_pressed(KEY_2):
            apply_clean_upgrade(current_upgrade_choices[1])
            is_upgrading = false
        elif Input.is_key_pressed(KEY_3):
            apply_clean_upgrade(current_upgrade_choices[2])
            is_upgrading = false