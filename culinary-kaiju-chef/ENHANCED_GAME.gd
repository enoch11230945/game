# ENHANCED_GAME.gd - Expanded Culinary Kaiju Chef with more enemy types and weapons!
extends Node2D

# Core game objects
@onready var monster_chef: CharacterBody2D = $MonsterChef
@onready var ingredient_collector: Area2D = $MonsterChef/IngredientCollector

# Templates for multiple enemy types
@onready var onion_template: Area2D = $OnionTemplate
@onready var tomato_template: Area2D = $TomatoTemplate
@onready var cleaver_template: Area2D = $CleaverTemplate  
@onready var spice_template: Area2D = $SpiceTemplate

# UI Elements
@onready var chef_level_label: Label = $UI/HUD/TopLeft/ChefLevel
@onready var appetite_bar: ProgressBar = $UI/HUD/TopLeft/AppetiteBar
@onready var appetite_label: Label = $UI/HUD/TopLeft/AppetiteLabel
@onready var ingredients_label: Label = $UI/HUD/TopLeft/IngredientsChopped
@onready var power_label: Label = $UI/HUD/TopLeft/CulinaryPower
@onready var game_timer_label: Label = $UI/HUD/TopRight/GameTimer

# Enhanced Upgrade System UI
@onready var upgrade_panel: Panel = $UI/UpgradePanel
@onready var upgrade_title: Label = $UI/UpgradePanel/VBox/UpgradeTitle
@onready var option_a: Button = $UI/UpgradePanel/VBox/Options/OptionA
@onready var option_b: Button = $UI/UpgradePanel/VBox/Options/OptionB
@onready var option_c: Button = $UI/UpgradePanel/VBox/Options/OptionC

# Game state
var monster_level: int = 1
var appetite: int = 0
var appetite_required: int = 100
var ingredients_chopped: int = 0
var game_time: float = 0.0

# Enhanced upgradeable stats
var monster_chef_speed: float = 200.0
var cleaver_damage: int = 25
var cleavers_per_attack: int = 2
var attack_speed_multiplier: float = 1.0
var chef_size_multiplier: float = 1.0
var chef_health: int = 100
var chef_max_health: int = 100

# Weapon arsenal
var active_weapons: Array[String] = ["cleaver"]
var weapon_unlock_levels = {
    "whisk_tornado": 3,
    "flame_breath": 5,
    "ice_shard": 7
}

# Enhanced game objects
var rebellious_ingredients: Array[Area2D] = []
var flying_cleavers: Array[Area2D] = []
var whisk_tornadoes: Array[Area2D] = []
var enemy_projectiles: Array[Area2D] = []
var spice_essences: Array[Area2D] = []

# Enhanced timers
var ingredient_spawn_timer: float = 0.0
var cleaver_attack_timer: float = 0.0
var whisk_attack_timer: float = 0.0
var enemy_projectile_timer: float = 0.0

# Enhanced upgrade options with more variety
var enhanced_upgrade_options = [
    {"name": "🔪 Cleaver Mastery", "desc": "Throw +2 more cleavers per attack!\nMore blades = more chaos!", "type": "cleavers", "value": 2},
    {"name": "⚔️ Razor Edge", "desc": "Cleavers deal +20 more damage!\nSharp enough to cut reality!", "type": "damage", "value": 20},
    {"name": "⚡ Lightning Hands", "desc": "Attack 30% faster!\nThe speed of a master chef!", "type": "speed", "value": 0.7},
    {"name": "💪 Kaiju Vigor", "desc": "Move 25% faster!\nSwift culinary domination!", "type": "movement", "value": 40},
    {"name": "🐉 Giant Growth", "desc": "Grow 25% larger!\nImposing kitchen presence!", "type": "size", "value": 1.25},
    {"name": "🌟 Ingredient Magnet", "desc": "Attract spice from 50% farther!\nMagnetic culinary aura!", "type": "magnet", "value": 1.5},
    {"name": "🌪️ Whisk Tornado", "desc": "Unlock spinning whisk weapon!\nTornado of culinary destruction!", "type": "unlock_weapon", "value": "whisk_tornado"},
    {"name": "💚 Chef's Resilience", "desc": "Increase max health by 20!\nTougher kitchen warrior!", "type": "health", "value": 20},
    {"name": "🔥 Flame Breath", "desc": "Unlock fire breathing attack!\nScorch rebellious ingredients!", "type": "unlock_weapon", "value": "flame_breath"},
    {"name": "❄️ Ice Storm", "desc": "Unlock freezing ice shards!\nFreeze enemies in their tracks!", "type": "unlock_weapon", "value": "ice_shard"}
]

var current_upgrade_choices: Array[Dictionary] = []
var is_upgrading: bool = false

# Enemy spawn variety
var enemy_types = ["onion", "tomato"]
var enemy_spawn_weights = {"onion": 0.7, "tomato": 0.3}

func _ready():
    print("🍳🐉 === ENHANCED CULINARY KAIJU CHEF === 🐉🍳")
    print("📈 New Features: Multiple enemies, more weapons, enhanced upgrades!")
    
    setup_templates()
    connect_systems()
    spawn_initial_ingredients()
    update_all_ui()

func setup_templates():
    """Setup all templates"""
    onion_template.hide()
    tomato_template.hide()
    cleaver_template.hide()
    spice_template.hide()
    upgrade_panel.hide()

func connect_systems():
    """Connect all game systems"""
    ingredient_collector.area_entered.connect(_on_spice_collected)
    option_a.pressed.connect(func(): select_upgrade(0))
    option_b.pressed.connect(func(): select_upgrade(1))
    option_c.pressed.connect(func(): select_upgrade(2))

func _process(delta):
    if is_upgrading:
        return
    
    game_time += delta
    
    # Core systems
    handle_chef_movement(delta)
    handle_enhanced_spawning(delta)
    handle_multi_weapon_combat(delta)
    update_enhanced_objects(delta)
    cleanup_battlefield()
    
    # UI updates
    update_timer_display()

func handle_chef_movement(delta: float):
    """Enhanced chef movement with health system"""
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var actual_speed = monster_chef_speed * (1.0 + monster_level * 0.05)
    monster_chef.velocity = input_dir * actual_speed
    monster_chef.move_and_slide()
    
    if input_dir.x != 0:
        monster_chef.scale.x = abs(monster_chef.scale.x) * (1 if input_dir.x > 0 else -1)

func handle_enhanced_spawning(delta: float):
    """Enhanced spawning with multiple enemy types"""
    ingredient_spawn_timer += delta
    var spawn_interval = max(0.8, 2.5 - (monster_level * 0.1))
    
    if ingredient_spawn_timer > spawn_interval:
        ingredient_spawn_timer = 0.0
        spawn_random_enemy()

func spawn_random_enemy():
    """Spawn different types of enemies based on level"""
    var enemy_type = choose_enemy_type()
    
    match enemy_type:
        "onion":
            spawn_enhanced_onion()
        "tomato":
            spawn_tomato_ranger()

func choose_enemy_type() -> String:
    """Choose enemy type based on level and weights"""
    if monster_level < 3:
        return "onion"  # Only onions early game
    
    # Weighted random selection
    var total_weight = 0.0
    for weight in enemy_spawn_weights.values():
        total_weight += weight
    
    var rand_value = randf() * total_weight
    var current_weight = 0.0
    
    for enemy_type in enemy_spawn_weights:
        current_weight += enemy_spawn_weights[enemy_type]
        if rand_value <= current_weight:
            return enemy_type
    
    return "onion"  # Fallback

func spawn_enhanced_onion():
    """Spawn enhanced onion with level scaling"""
    var onion = onion_template.duplicate()
    add_child(onion)
    
    position_enemy_around_chef(onion)
    onion.show()
    
    # Enhanced stats based on level
    var base_health = 30 + (monster_level * 4)
    var base_speed = 50 + (monster_level * 3)
    var xp_reward = 10 + monster_level
    
    onion.set_meta("health", base_health)
    onion.set_meta("max_health", base_health)
    onion.set_meta("speed", base_speed)
    onion.set_meta("xp", xp_reward)
    onion.set_meta("enemy_type", "onion")
    
    onion.area_entered.connect(func(area): hit_ingredient(onion, area))
    rebellious_ingredients.append(onion)
    
    print("🧅 Enhanced Onion spawned! Health: %d, Speed: %d" % [base_health, base_speed])

func spawn_tomato_ranger():
    """Spawn tomato ranger with ranged attacks"""
    var tomato = tomato_template.duplicate()
    add_child(tomato)
    
    position_enemy_around_chef(tomato)
    tomato.show()
    
    # Tomato ranger stats
    var base_health = 45 + (monster_level * 5)
    var base_speed = 35 + (monster_level * 2)
    var xp_reward = 15 + (monster_level * 2)
    
    tomato.set_meta("health", base_health)
    tomato.set_meta("max_health", base_health)
    tomato.set_meta("speed", base_speed)
    tomato.set_meta("xp", xp_reward)
    tomato.set_meta("enemy_type", "tomato")
    tomato.set_meta("attack_range", 200.0)
    tomato.set_meta("attack_damage", 8 + monster_level)
    tomato.set_meta("attack_timer", 0.0)
    tomato.set_meta("attack_cooldown", 3.0)
    
    tomato.area_entered.connect(func(area): hit_ingredient(tomato, area))
    rebellious_ingredients.append(tomato)
    
    print("🍅 Tomato Ranger spawned! Health: %d, Can attack from range!" % base_health)

func position_enemy_around_chef(enemy: Area2D):
    """Position enemy in circle around chef"""
    var angle = randf() * TAU
    var distance = 600 + randf() * 200
    enemy.global_position = monster_chef.global_position + Vector2.RIGHT.rotated(angle) * distance

func handle_multi_weapon_combat(delta: float):
    """Handle multiple weapon systems"""
    # Cleaver attacks
    cleaver_attack_timer += delta
    var cleaver_interval = (1.5 / attack_speed_multiplier) - (monster_level * 0.05)
    if cleaver_attack_timer > max(0.3, cleaver_interval):
        cleaver_attack_timer = 0.0
        if "cleaver" in active_weapons:
            throw_enhanced_cleavers()
    
    # Whisk tornado attacks
    if "whisk_tornado" in active_weapons:
        whisk_attack_timer += delta
        if whisk_attack_timer > 4.0:  # Whisk every 4 seconds
            whisk_attack_timer = 0.0
            create_whisk_tornado()

func throw_enhanced_cleavers():
    """Enhanced cleaver throwing with better targeting"""
    var targets = find_nearest_ingredients(cleavers_per_attack)
    
    for i in range(cleavers_per_attack):
        var cleaver = cleaver_template.duplicate()
        add_child(cleaver)
        
        cleaver.global_position = monster_chef.global_position
        
        var direction: Vector2
        if i < targets.size():
            # Predictive targeting - aim where enemy will be
            var target = targets[i]
            var target_velocity = estimate_target_velocity(target)
            var predicted_position = target.global_position + target_velocity * 0.5
            direction = (predicted_position - monster_chef.global_position).normalized()
        else:
            var spread = (TAU / cleavers_per_attack) * i + randf_range(-0.3, 0.3)
            direction = Vector2.RIGHT.rotated(spread)
        
        cleaver.set_meta("direction", direction)
        cleaver.set_meta("damage", cleaver_damage)
        cleaver.set_meta("speed", 300.0)
        cleaver.rotation = direction.angle()
        cleaver.show()
        
        flying_cleavers.append(cleaver)
    
    print("🔪 Enhanced cleaver storm! %d cleavers with %d damage each!" % [cleavers_per_attack, cleaver_damage])

func estimate_target_velocity(target: Area2D) -> Vector2:
    """Estimate target velocity for predictive aiming"""
    var speed = target.get_meta("speed", 50.0)
    var direction_to_chef = (monster_chef.global_position - target.global_position).normalized()
    return direction_to_chef * speed

func create_whisk_tornado():
    """Create a whisk tornado weapon"""
    var whisk_scene = preload("res://features/weapons/whisk_tornado/WhiskTornado.tscn")
    var whisk = whisk_scene.instantiate()
    add_child(whisk)
    
    whisk.global_position = monster_chef.global_position
    
    # Find direction to nearest enemy cluster
    var direction = find_best_tornado_direction()
    whisk.initialize(direction, cleaver_damage)
    
    whisk_tornadoes.append(whisk)
    print("🌪️ WHISK TORNADO UNLEASHED! Spinning culinary destruction!")

func find_best_tornado_direction() -> Vector2:
    """Find best direction for tornado to hit most enemies"""
    if rebellious_ingredients.is_empty():
        return Vector2.RIGHT
    
    # Find center of enemy cluster
    var center = Vector2.ZERO
    var count = 0
    
    for ingredient in rebellious_ingredients:
        if is_instance_valid(ingredient):
            center += ingredient.global_position
            count += 1
    
    if count > 0:
        center /= count
        return (center - monster_chef.global_position).normalized()
    
    return Vector2.RIGHT

func update_enhanced_objects(delta: float):
    """Update all game objects with enhanced behaviors"""
    update_enhanced_ingredients(delta)
    update_flying_cleavers(delta)
    update_whisk_tornadoes(delta)
    update_enemy_projectiles(delta)
    update_spice_essences(delta)

func update_enhanced_ingredients(delta: float):
    """Update ingredients with type-specific behaviors"""
    for ingredient in rebellious_ingredients:
        if not is_instance_valid(ingredient):
            continue
        
        var enemy_type = ingredient.get_meta("enemy_type", "onion")
        var speed = ingredient.get_meta("speed", 50.0)
        
        match enemy_type:
            "onion":
                update_onion_behavior(ingredient, delta, speed)
            "tomato":
                update_tomato_behavior(ingredient, delta, speed)

func update_onion_behavior(onion: Area2D, delta: float, speed: float):
    """Enhanced onion behavior"""
    var direction = (monster_chef.global_position - onion.global_position).normalized()
    onion.global_position += direction * speed * delta
    
    # Enhanced rolling animation
    var sprite = onion.get_node_or_null("OnionSprite")
    if sprite:
        sprite.rotation += (speed / 20.0) * delta
    
    # Check collision with chef
    if onion.global_position.distance_to(monster_chef.global_position) < 60:
        print("💥 Onion attacks the chef!")
        take_chef_damage(5)
        rebellious_ingredients.erase(onion)
        onion.queue_free()

func update_tomato_behavior(tomato: Area2D, delta: float, speed: float):
    """Enhanced tomato behavior with ranged attacks"""
    var distance_to_chef = tomato.global_position.distance_to(monster_chef.global_position)
    var attack_range = tomato.get_meta("attack_range", 200.0)
    
    if distance_to_chef > attack_range:
        # Move closer
        var direction = (monster_chef.global_position - tomato.global_position).normalized()
        tomato.global_position += direction * speed * delta
        
        # Bouncing animation
        var sprite = tomato.get_node_or_null("TomatoSprite")
        if sprite:
            sprite.position.y = sin(game_time * 5) * 3
    else:
        # In range - attack!
        var attack_timer = tomato.get_meta("attack_timer", 0.0) + delta
        tomato.set_meta("attack_timer", attack_timer)
        
        var attack_cooldown = tomato.get_meta("attack_cooldown", 3.0)
        if attack_timer >= attack_cooldown:
            tomato.set_meta("attack_timer", 0.0)
            tomato_shoot_acid(tomato)

func tomato_shoot_acid(tomato: Area2D):
    """Tomato shoots acid projectile at chef"""
    var acid = Area2D.new()
    acid.collision_layer = 16
    acid.collision_mask = 2
    
    # Visual acid blob
    var acid_sprite = ColorRect.new()
    acid_sprite.size = Vector2(8, 8)
    acid_sprite.position = Vector2(-4, -4)
    acid_sprite.color = Color.RED
    acid.add_child(acid_sprite)
    
    # Collision
    var acid_collision = CollisionShape2D.new()
    var acid_shape = CircleShape2D.new()
    acid_shape.radius = 4
    acid_collision.shape = acid_shape
    acid.add_child(acid_collision)
    
    add_child(acid)
    acid.global_position = tomato.global_position
    
    var direction = (monster_chef.global_position - tomato.global_position).normalized()
    acid.set_meta("direction", direction)
    acid.set_meta("speed", 150.0)
    acid.set_meta("damage", tomato.get_meta("attack_damage", 8))
    acid.set_meta("lifetime", 3.0)
    
    enemy_projectiles.append(acid)
    print("🍅💥 Tomato shoots acid at the chef!")

func update_flying_cleavers(delta: float):
    """Update cleaver physics"""
    for cleaver in flying_cleavers:
        if not is_instance_valid(cleaver):
            continue
        
        var direction = cleaver.get_meta("direction", Vector2.RIGHT)
        var speed = cleaver.get_meta("speed", 300.0)
        cleaver.global_position += direction * speed * delta
        cleaver.rotation += 8.0 * delta
        
        # Remove if too far
        if cleaver.global_position.distance_to(monster_chef.global_position) > 900:
            flying_cleavers.erase(cleaver)
            cleaver.queue_free()

func update_whisk_tornadoes(delta: float):
    """Update whisk tornadoes"""
    for whisk in whisk_tornadoes:
        if not is_instance_valid(whisk):
            whisk_tornadoes.erase(whisk)

func update_enemy_projectiles(delta: float):
    """Update enemy projectiles"""
    for projectile in enemy_projectiles:
        if not is_instance_valid(projectile):
            continue
        
        var direction = projectile.get_meta("direction", Vector2.RIGHT)
        var speed = projectile.get_meta("speed", 150.0)
        var lifetime = projectile.get_meta("lifetime", 3.0) - delta
        
        projectile.global_position += direction * speed * delta
        projectile.set_meta("lifetime", lifetime)
        
        # Check collision with chef
        if projectile.global_position.distance_to(monster_chef.global_position) < 40:
            var damage = projectile.get_meta("damage", 8)
            take_chef_damage(damage)
            enemy_projectiles.erase(projectile)
            projectile.queue_free()
            continue
        
        # Remove if lifetime expired
        if lifetime <= 0:
            enemy_projectiles.erase(projectile)
            projectile.queue_free()

func update_spice_essences(delta: float):
    """Update spice essence magnetism"""
    for spice in spice_essences:
        if not is_instance_valid(spice):
            continue
        
        var direction = (monster_chef.global_position - spice.global_position).normalized()
        var attraction_speed = (100.0 + monster_level * 15)
        spice.global_position += direction * attraction_speed * delta

func take_chef_damage(damage: int):
    """Chef takes damage from enemy attacks"""
    chef_health = max(0, chef_health - damage)
    print("⚔️ Chef takes %d damage! Health: %d/%d" % [damage, chef_health, chef_max_health])
    
    # Flash effect
    monster_chef.modulate = Color.RED
    create_tween().tween_property(monster_chef, "modulate", Color.WHITE, 0.2)
    
    if chef_health <= 0:
        game_over()

func game_over():
    """Handle game over"""
    print("💀 GAME OVER! The culinary kaiju has fallen!")
    # Could implement game over screen here
    get_tree().reload_current_scene()

func hit_ingredient(ingredient: Area2D, weapon: Area2D):
    """Enhanced ingredient hit system"""
    if weapon in flying_cleavers:
        var damage = weapon.get_meta("damage", 25)
        damage_ingredient(ingredient, damage)
        flying_cleavers.erase(weapon)
        weapon.queue_free()

func damage_ingredient(ingredient: Area2D, damage: int):
    """Enhanced damage system with visual feedback"""
    var current_health = ingredient.get_meta("health", 30) - damage
    ingredient.set_meta("health", current_health)
    
    # Enhanced visual feedback
    var enemy_type = ingredient.get_meta("enemy_type", "onion")
    var sprite_name = enemy_type.capitalize() + "Sprite"
    var sprite = ingredient.get_node_or_null(sprite_name)
    
    if sprite:
        sprite.modulate = Color.RED
        create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.2)
    
    # Health bar effect
    show_damage_number(ingredient, damage)
    
    if current_health <= 0:
        chop_enhanced_ingredient(ingredient)

func show_damage_number(ingredient: Area2D, damage: int):
    """Show floating damage number"""
    var damage_label = Label.new()
    damage_label.text = "-%d" % damage
    damage_label.add_theme_color_override("font_color", Color.YELLOW)
    add_child(damage_label)
    damage_label.global_position = ingredient.global_position + Vector2(randf_range(-20, 20), -30)
    
    # Float up and fade
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(damage_label, "global_position", damage_label.global_position + Vector2(0, -50), 1.0)
    tween.tween_property(damage_label, "modulate", Color(1, 1, 0, 0), 1.0)
    tween.finished.connect(func(): damage_label.queue_free())

func chop_enhanced_ingredient(ingredient: Area2D):
    """Enhanced ingredient chopping with type-specific rewards"""
    var enemy_type = ingredient.get_meta("enemy_type", "onion")
    var xp_reward = ingredient.get_meta("xp", 10)
    
    # Type-specific bonuses
    match enemy_type:
        "tomato":
            xp_reward = int(xp_reward * 1.5)  # Tomatoes give more XP
            print("🍅 TOMATO RANGER DEFEATED! Premium culinary experience!")
        "onion":
            print("🧅 ONION CHOPPED! Classic culinary victory!")
    
    spawn_enhanced_spice_essence(ingredient.global_position, xp_reward, enemy_type)
    
    ingredients_chopped += 1
    appetite += xp_reward
    
    if appetite >= appetite_required:
        level_up_enhanced()
    
    rebellious_ingredients.erase(ingredient)
    ingredient.queue_free()
    
    update_all_ui()

func spawn_enhanced_spice_essence(position: Vector2, value: int, ingredient_type: String):
    """Spawn enhanced spice essence with type-specific appearance"""
    var spice = spice_template.duplicate()
    add_child(spice)
    spice.global_position = position
    spice.set_meta("xp", value)
    
    # Type-specific colors
    var color = Color.YELLOW
    match ingredient_type:
        "tomato":
            color = Color.GOLD
        "onion":
            color = Color.ORANGE
    
    var sprite = spice.get_node_or_null("SpiceCore")
    if sprite:
        sprite.color = color
    
    spice.show()
    spice_essences.append(spice)

func _on_spice_collected(area: Area2D):
    """Enhanced spice collection"""
    if area in spice_essences:
        var xp_value = area.get_meta("xp", 5)
        appetite += xp_value
        
        # Collection effect
        create_collection_effect(area.global_position)
        
        if appetite >= appetite_required:
            level_up_enhanced()
        
        spice_essences.erase(area)
        area.queue_free()
        update_all_ui()

func create_collection_effect(position: Vector2):
    """Create satisfying collection effect"""
    var effect = ColorRect.new()
    effect.size = Vector2(20, 20)
    effect.position = Vector2(-10, -10)
    effect.color = Color.CYAN
    add_child(effect)
    effect.global_position = position
    
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(effect, "scale", Vector2(2, 2), 0.3)
    tween.tween_property(effect, "modulate", Color(0, 1, 1, 0), 0.3)
    tween.finished.connect(func(): effect.queue_free())

func level_up_enhanced():
    """Enhanced level up with more upgrade options"""
    monster_level += 1
    appetite = 0
    appetite_required = int(appetite_required * 1.4)
    
    print("🎉 ENHANCED LEVEL UP! Level %d achieved!" % monster_level)
    print("🎰 Enhanced upgrade system with new options!")
    
    show_enhanced_upgrade_choices()
    update_all_ui()

func show_enhanced_upgrade_choices():
    """Show enhanced upgrade choices with more variety"""
    var available_upgrades = get_level_appropriate_upgrades()
    available_upgrades.shuffle()
    
    current_upgrade_choices = [
        available_upgrades[0],
        available_upgrades[1],
        available_upgrades[2]
    ]
    
    upgrade_title.text = "🎉 ENHANCED CULINARY MASTERY! 🎉\nLevel %d - Choose your evolution:" % monster_level
    
    option_a.text = current_upgrade_choices[0].name + "\n" + current_upgrade_choices[0].desc
    option_b.text = current_upgrade_choices[1].name + "\n" + current_upgrade_choices[1].desc
    option_c.text = current_upgrade_choices[2].name + "\n" + current_upgrade_choices[2].desc
    
    # Enhanced visual effect
    upgrade_panel.show()
    upgrade_panel.scale = Vector2(0.2, 0.2)
    upgrade_panel.modulate = Color(1, 1, 1, 0)
    
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(upgrade_panel, "scale", Vector2(1.1, 1.1), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
    tween.tween_property(upgrade_panel, "modulate", Color.WHITE, 0.3)
    tween.tween_property(upgrade_panel, "scale", Vector2(1, 1), 0.2).set_delay(0.4)
    
    is_upgrading = true

func get_level_appropriate_upgrades() -> Array[Dictionary]:
    """Get upgrades appropriate for current level"""
    var available: Array[Dictionary] = []
    
    # Always available
    for upgrade in enhanced_upgrade_options:
        if upgrade.type in ["cleavers", "damage", "speed", "movement", "size", "magnet", "health"]:
            available.append(upgrade)
        elif upgrade.type == "unlock_weapon":
            var weapon_name = upgrade.value
            if weapon_name in weapon_unlock_levels and monster_level >= weapon_unlock_levels[weapon_name] and weapon_name not in active_weapons:
                available.append(upgrade)
    
    return available

func select_upgrade(choice_index: int):
    """Enhanced upgrade selection"""
    var upgrade = current_upgrade_choices[choice_index]
    
    print("✨ ENHANCED UPGRADE SELECTED: %s" % upgrade.name)
    
    apply_enhanced_upgrade(upgrade)
    
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(upgrade_panel, "scale", Vector2(0.1, 0.1), 0.2)
    tween.tween_property(upgrade_panel, "modulate", Color(1, 1, 1, 0), 0.2)
    tween.finished.connect(func(): upgrade_panel.hide())
    
    is_upgrading = false
    show_enhanced_upgrade_flash()

func apply_enhanced_upgrade(upgrade: Dictionary):
    """Apply enhanced upgrades"""
    match upgrade.type:
        "cleavers":
            cleavers_per_attack += upgrade.value
            print("   - Cleavers per attack: %d" % cleavers_per_attack)
        
        "damage":
            cleaver_damage += upgrade.value
            print("   - Cleaver damage: %d" % cleaver_damage)
        
        "speed":
            attack_speed_multiplier /= upgrade.value
            print("   - Attack speed multiplier: %.2f" % attack_speed_multiplier)
        
        "movement":
            monster_chef_speed += upgrade.value
            print("   - Movement speed: %.0f" % monster_chef_speed)
        
        "size":
            chef_size_multiplier *= upgrade.value
            monster_chef.scale *= upgrade.value
            print("   - Chef size multiplier: %.2f" % chef_size_multiplier)
        
        "magnet":
            var collector_shape = ingredient_collector.get_node("CollectorShape").shape as CircleShape2D
            if collector_shape:
                collector_shape.radius *= upgrade.value
            print("   - Collection range increased by %.1fx" % upgrade.value)
        
        "health":
            chef_max_health += upgrade.value
            chef_health += upgrade.value
            print("   - Max health increased to: %d" % chef_max_health)
        
        "unlock_weapon":
            var weapon_name = upgrade.value
            active_weapons.append(weapon_name)
            print("   - 🎉 NEW WEAPON UNLOCKED: %s!" % weapon_name.replace("_", " ").to_upper())

func show_enhanced_upgrade_flash():
    """Enhanced upgrade flash with better effects"""
    var flash = ColorRect.new()
    flash.color = Color(1, 0.8, 0, 0.5)
    flash.anchors_preset = Control.PRESET_FULL_RECT
    $UI.add_child(flash)
    
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(flash, "modulate", Color(1, 0.8, 0, 0), 0.8)
    tween.tween_method(func(val): flash.color = Color(val, val, 0, flash.color.a), 1.0, 0.0, 0.8)
    tween.finished.connect(func(): flash.queue_free())
    
    print("🔥 ENHANCED CULINARY POWER SURGE! The chef's mastery deepens!")

func update_all_ui():
    """Enhanced UI updates"""
    chef_level_label.text = "🐉 Chef Level: %d" % monster_level
    appetite_bar.max_value = appetite_required
    appetite_bar.value = appetite
    appetite_label.text = "🔥 Appetite: %d/%d" % [appetite, appetite_required]
    ingredients_label.text = "🍴 Chopped: %d" % ingredients_chopped
    power_label.text = "⚡ Power: %s" % get_enhanced_power_description()

func get_enhanced_power_description() -> String:
    """Enhanced power description"""
    var weapons_text = ""
    if active_weapons.size() > 1:
        weapons_text = " (%d weapons)" % active_weapons.size()
    
    match monster_level:
        1, 2: return "Novice Chef" + weapons_text
        3, 4: return "Skilled Chef" + weapons_text
        5, 6, 7: return "Master Chef" + weapons_text
        8, 9, 10: return "Legendary Chef" + weapons_text
        _: return "CULINARY GOD Lv.%d%s" % [monster_level, weapons_text]

func update_timer_display():
    """Update game timer"""
    var minutes = int(game_time) / 60
    var seconds = int(game_time) % 60
    game_timer_label.text = "⏰ Time: %02d:%02d" % [minutes, seconds]

func find_nearest_ingredients(count: int) -> Array[Area2D]:
    """Enhanced ingredient targeting"""
    var valid: Array[Area2D] = []
    for ingredient in rebellious_ingredients:
        if is_instance_valid(ingredient):
            valid.append(ingredient)
    
    valid.sort_custom(func(a, b):
        return a.global_position.distance_to(monster_chef.global_position) < b.global_position.distance_to(monster_chef.global_position)
    )
    
    return valid.slice(0, count)

func spawn_initial_ingredients():
    """Spawn initial ingredients"""
    for i in range(4):
        spawn_enhanced_onion()

func cleanup_battlefield():
    """Enhanced cleanup"""
    rebellious_ingredients = rebellious_ingredients.filter(func(obj): return is_instance_valid(obj))
    flying_cleavers = flying_cleavers.filter(func(obj): return is_instance_valid(obj))
    whisk_tornadoes = whisk_tornadoes.filter(func(obj): return is_instance_valid(obj))
    enemy_projectiles = enemy_projectiles.filter(func(obj): return is_instance_valid(obj))
    spice_essences = spice_essences.filter(func(obj): return is_instance_valid(obj))

func _input(event):
    """Enhanced debug controls"""
    if event.is_action_pressed("ui_accept"):
        for i in range(5):
            spawn_random_enemy()
        print("🚨 Enhanced enemy wave spawned!")
    
    if event.is_action_pressed("ui_select"):
        level_up_enhanced()
        print("💪 Testing enhanced upgrade system!")
    
    # Enhanced upgrade shortcuts
    if is_upgrading:
        if event.is_action_pressed("move_left"):
            select_upgrade(0)
        elif event.is_action_pressed("move_up"):
            select_upgrade(1)
        elif event.is_action_pressed("move_right"):
            select_upgrade(2)