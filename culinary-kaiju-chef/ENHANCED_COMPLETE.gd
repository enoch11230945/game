# ENHANCED_COMPLETE.gd - Ultimate Culinary Kaiju Chef with full features!
extends Node2D

# Core game objects
@onready var monster_chef: CharacterBody2D = $MonsterChef
@onready var ingredient_collector: Area2D = $MonsterChef/IngredientCollector

# Templates
@onready var onion_template: Area2D = $OnionTemplate
@onready var tomato_template: Area2D = $TomatoTemplate
@onready var cleaver_template: Area2D = $CleaverTemplate  
@onready var spice_template: Area2D = $SpiceTemplate

# UI
@onready var chef_level_label: Label = $UI/HUD/TopLeft/ChefLevel
@onready var appetite_bar: ProgressBar = $UI/HUD/TopLeft/AppetiteBar
@onready var appetite_label: Label = $UI/HUD/TopLeft/AppetiteLabel
@onready var ingredients_label: Label = $UI/HUD/TopLeft/IngredientsChopped
@onready var power_label: Label = $UI/HUD/TopLeft/CulinaryPower
@onready var health_bar: ProgressBar = $UI/HUD/TopLeft/HealthBar
@onready var health_label: Label = $UI/HUD/TopLeft/HealthLabel
@onready var game_timer_label: Label = $UI/HUD/TopRight/GameTimer
@onready var enemies_label: Label = $UI/HUD/TopRight/EnemiesAlive
@onready var weapons_label: Label = $UI/HUD/TopRight/ActiveWeapons
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
var chef_health: int = 100
var chef_max_health: int = 100

# Enhanced stats
var monster_chef_speed: float = 200.0
var cleaver_damage: int = 25
var cleavers_per_attack: int = 2
var attack_speed_multiplier: float = 1.0

# Multi-weapon system
var active_weapons: Array[String] = ["cleaver"]
var weapon_timers: Dictionary = {"cleaver": 0.0, "whisk": 0.0}

# Game objects
var rebellious_ingredients: Array[Area2D] = []
var flying_cleavers: Array[Area2D] = []
var whisk_tornadoes: Array[Area2D] = []
var enemy_projectiles: Array[Area2D] = []
var spice_essences: Array[Area2D] = []

# Timers
var ingredient_spawn_timer: float = 0.0

# Upgrade database
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

func _ready():
    print("🍳🐉 === ENHANCED COMPLETE CULINARY KAIJU CHEF === 🐉🍳")
    setup_game()
    connect_systems()
    spawn_initial_battle()
    update_all_ui()

func setup_game():
    onion_template.hide()
    tomato_template.hide()
    cleaver_template.hide()
    spice_template.hide()
    upgrade_panel.hide()

func connect_systems():
    ingredient_collector.area_entered.connect(_on_spice_collected)
    option_a.pressed.connect(func(): select_upgrade(0))
    option_b.pressed.connect(func(): select_upgrade(1))
    option_c.pressed.connect(func(): select_upgrade(2))

func _process(delta):
    if is_upgrading:
        return
    
    game_time += delta
    handle_chef_movement(delta)
    handle_enemy_spawning(delta)
    handle_combat(delta)
    update_battlefield(delta)
    cleanup_battlefield()
    update_timer_and_stats()

func handle_chef_movement(delta: float):
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var actual_speed = monster_chef_speed * (1.0 + monster_level * 0.08)
    monster_chef.velocity = input_dir * actual_speed
    monster_chef.move_and_slide()
    
    if input_dir.x != 0:
        monster_chef.scale.x = abs(monster_chef.scale.x) * (1 if input_dir.x > 0 else -1)

func handle_enemy_spawning(delta: float):
    ingredient_spawn_timer += delta
    var spawn_interval = max(0.6, 2.0 - (monster_level * 0.12))
    
    if ingredient_spawn_timer > spawn_interval:
        ingredient_spawn_timer = 0.0
        spawn_dynamic_enemy()

func spawn_dynamic_enemy():
    var enemy_type = "onion" if monster_level < 2 or randf() < 0.7 else "tomato"
    
    match enemy_type:
        "onion":
            spawn_onion()
        "tomato":
            spawn_tomato()

func spawn_onion():
    var onion = onion_template.duplicate()
    add_child(onion)
    position_enemy_around_chef(onion)
    onion.show()
    
    var health = 35 + (monster_level * 5)
    var speed = 55 + (monster_level * 3)
    var xp = 12 + monster_level
    
    setup_enemy_metadata(onion, "onion", health, speed, xp)
    onion.area_entered.connect(func(area): hit_ingredient(onion, area))
    rebellious_ingredients.append(onion)

func spawn_tomato():
    var tomato = tomato_template.duplicate()
    add_child(tomato)
    position_enemy_around_chef(tomato)
    tomato.show()
    
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

func setup_enemy_metadata(enemy: Area2D, type: String, health: int, speed: int, xp: int):
    enemy.set_meta("enemy_type", type)
    enemy.set_meta("health", health)
    enemy.set_meta("max_health", health)
    enemy.set_meta("speed", speed)
    enemy.set_meta("xp", xp)

func position_enemy_around_chef(enemy: Area2D):
    var angle = randf() * TAU
    var distance = 650 + randf() * 200
    enemy.global_position = monster_chef.global_position + Vector2.RIGHT.rotated(angle) * distance

func handle_combat(delta: float):
    # Cleaver system
    weapon_timers["cleaver"] += delta
    var cleaver_interval = (1.4 / attack_speed_multiplier) - (monster_level * 0.06)
    if weapon_timers["cleaver"] > max(0.25, cleaver_interval):
        weapon_timers["cleaver"] = 0.0
        if "cleaver" in active_weapons:
            throw_cleavers()
    
    # Whisk tornado system
    if "whisk" in active_weapons:
        weapon_timers["whisk"] += delta
        if weapon_timers["whisk"] > 3.5:
            weapon_timers["whisk"] = 0.0
            create_whisk_tornado()

func throw_cleavers():
    var targets = find_nearest_enemies(cleavers_per_attack)
    
    for i in range(cleavers_per_attack):
        var cleaver = create_cleaver()
        
        var direction: Vector2
        if i < targets.size():
            var target = targets[i]
            var predicted_pos = predict_target_position(target)
            direction = (predicted_pos - monster_chef.global_position).normalized()
        else:
            var spread = (TAU / cleavers_per_attack) * i + randf_range(-0.25, 0.25)
            direction = Vector2.RIGHT.rotated(spread)
        
        launch_cleaver(cleaver, direction)

func create_cleaver():
    var cleaver = cleaver_template.duplicate()
    add_child(cleaver)
    
    cleaver.set_meta("damage", cleaver_damage)
    cleaver.set_meta("speed", 320.0 + (monster_level * 10))
    cleaver.set_meta("lifetime", 4.5)
    
    return cleaver

func launch_cleaver(cleaver: Area2D, direction: Vector2):
    cleaver.global_position = monster_chef.global_position
    cleaver.set_meta("direction", direction)
    cleaver.rotation = direction.angle()
    cleaver.show()
    flying_cleavers.append(cleaver)

func predict_target_position(target: Area2D) -> Vector2:
    var speed = target.get_meta("speed", 50.0)
    var direction_to_chef = (monster_chef.global_position - target.global_position).normalized()
    var predicted_movement = direction_to_chef * speed * 0.4
    return target.global_position + predicted_movement

func create_whisk_tornado():
    var whisk = Area2D.new()
    whisk.collision_layer = 8
    whisk.collision_mask = 4
    
    # Visual
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
    
    # Collision
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
    if enemy in rebellious_ingredients:
        var affected = tornado.get_meta("affected_enemies", [])
        if enemy not in affected:
            affected.append(enemy)
            tornado.set_meta("affected_enemies", affected)
            damage_ingredient(enemy, tornado.get_meta("damage", 25))

func update_battlefield(delta: float):
    update_ingredients(delta)
    update_cleavers(delta)
    update_whisk_tornadoes(delta)
    update_enemy_projectiles(delta)
    update_spice_essences(delta)

func update_ingredients(delta: float):
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
    var speed = onion.get_meta("speed", 55.0)
    var direction = (monster_chef.global_position - onion.global_position).normalized()
    
    var wobble = Vector2(sin(game_time * 3) * 10, cos(game_time * 2.5) * 8)
    onion.global_position += (direction * speed + wobble) * delta
    
    var sprite = onion.get_node_or_null("OnionSprite")
    if sprite:
        sprite.rotation += (speed / 15.0) * delta
    
    if onion.global_position.distance_to(monster_chef.global_position) < 65:
        take_chef_damage(8 + monster_level)
        rebellious_ingredients.erase(onion)
        onion.queue_free()

func update_tomato(tomato: Area2D, delta: float):
    var distance = tomato.global_position.distance_to(monster_chef.global_position)
    var attack_range = tomato.get_meta("attack_range", 220.0)
    var speed = tomato.get_meta("speed", 40.0)
    
    if distance > attack_range:
        var direction = (monster_chef.global_position - tomato.global_position).normalized()
        tomato.global_position += direction * speed * delta
        
        var sprite = tomato.get_node_or_null("TomatoSprite")
        if sprite:
            sprite.position.y = sin(game_time * 4) * 4
    else:
        var attack_timer = tomato.get_meta("attack_timer", 0.0) + delta
        tomato.set_meta("attack_timer", attack_timer)
        
        var cooldown = tomato.get_meta("attack_cooldown", 2.8)
        if attack_timer >= cooldown:
            tomato.set_meta("attack_timer", 0.0)
            tomato_attack(tomato)

func tomato_attack(tomato: Area2D):
    var acid = Area2D.new()
    acid.collision_layer = 16
    acid.collision_mask = 2
    
    var acid_sprite = ColorRect.new()
    acid_sprite.size = Vector2(10, 10)
    acid_sprite.position = Vector2(-5, -5)
    acid_sprite.color = Color.RED
    acid.add_child(acid_sprite)
    
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 5
    collision.shape = shape
    acid.add_child(collision)
    
    add_child(acid)
    acid.global_position = tomato.global_position
    
    var chef_velocity = monster_chef.velocity
    var predicted_chef_pos = monster_chef.global_position + chef_velocity * 0.5
    var direction = (predicted_chef_pos - tomato.global_position).normalized()
    
    acid.set_meta("direction", direction)
    acid.set_meta("speed", 180.0)
    acid.set_meta("damage", tomato.get_meta("attack_damage", 12))
    acid.set_meta("lifetime", 4.0)
    
    enemy_projectiles.append(acid)

func update_cleavers(delta: float):
    for cleaver in flying_cleavers:
        if not is_instance_valid(cleaver):
            continue
        
        var direction = cleaver.get_meta("direction", Vector2.RIGHT)
        var speed = cleaver.get_meta("speed", 320.0)
        var lifetime = cleaver.get_meta("lifetime", 4.5) - delta
        
        cleaver.global_position += direction * speed * delta
        cleaver.rotation += 10.0 * delta
        cleaver.set_meta("lifetime", lifetime)
        
        if lifetime <= 0 or cleaver.global_position.distance_to(monster_chef.global_position) > 1000:
            flying_cleavers.erase(cleaver)
            cleaver.queue_free()

func update_whisk_tornadoes(delta: float):
    for whisk in whisk_tornadoes:
        if not is_instance_valid(whisk):
            continue
        
        var direction = whisk.get_meta("direction", Vector2.RIGHT)
        var speed = whisk.get_meta("speed", 120.0)
        var lifetime = whisk.get_meta("lifetime", 5.0) - delta
        var spin_speed = whisk.get_meta("spin_speed", 15.0)
        
        whisk.global_position += direction * speed * delta
        whisk.set_meta("lifetime", lifetime)
        
        var sprite = whisk.get_children()[0]
        if sprite:
            sprite.rotation += spin_speed * delta
        
        if lifetime <= 0:
            whisk_tornadoes.erase(whisk)
            create_tornado_explosion(whisk.global_position)
            whisk.queue_free()

func create_tornado_explosion(position: Vector2):
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
    for projectile in enemy_projectiles:
        if not is_instance_valid(projectile):
            continue
        
        var direction = projectile.get_meta("direction", Vector2.RIGHT)
        var speed = projectile.get_meta("speed", 180.0)
        var lifetime = projectile.get_meta("lifetime", 4.0) - delta
        
        projectile.global_position += direction * speed * delta
        projectile.set_meta("lifetime", lifetime)
        
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
    for spice in spice_essences:
        if not is_instance_valid(spice):
            continue
        
        var direction = (monster_chef.global_position - spice.global_position).normalized()
        var attraction = (120.0 + monster_level * 15) * delta
        spice.global_position += direction * attraction

func take_chef_damage(damage: int):
    chef_health = max(0, chef_health - damage)
    
    monster_chef.modulate = Color.RED
    create_tween().tween_property(monster_chef, "modulate", Color.WHITE, 0.25)
    
    update_health_ui()
    
    if chef_health <= 0:
        game_over()

func game_over():
    print("💀 GAME OVER!")
    print("📊 Final Stats:")
    print("   - Level: %d" % monster_level)
    print("   - Ingredients: %d" % ingredients_chopped)
    print("   - Time: %.1f seconds" % game_time)
    
    get_tree().reload_current_scene()

func hit_ingredient(ingredient: Area2D, weapon: Area2D):
    if weapon in flying_cleavers:
        var damage = weapon.get_meta("damage", 25)
        damage_ingredient(ingredient, damage)
        flying_cleavers.erase(weapon)
        weapon.queue_free()

func damage_ingredient(ingredient: Area2D, damage: int):
    var current_health = ingredient.get_meta("health", 35) - damage
    ingredient.set_meta("health", current_health)
    
    var enemy_type = ingredient.get_meta("enemy_type", "onion")
    var sprite_name = enemy_type.capitalize() + "Sprite"
    var sprite = ingredient.get_node_or_null(sprite_name)
    
    if sprite:
        sprite.modulate = Color.RED
        create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.15)
    
    if current_health <= 0:
        chop_ingredient(ingredient)

func chop_ingredient(ingredient: Area2D):
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
    update_all_ui()

func spawn_spice(position: Vector2, value: int, ingredient_type: String):
    var spice = spice_template.duplicate()
    add_child(spice)
    spice.global_position = position
    spice.set_meta("xp", value)
    
    var color = Color.YELLOW
    match ingredient_type:
        "tomato":
            color = Color.GOLD
        "onion":
            color = Color.ORANGE
    
    var core = spice.get_node_or_null("SpiceCore")
    if core:
        core.color = color
    
    spice.show()
    spice_essences.append(spice)

func _on_spice_collected(area: Area2D):
    if area in spice_essences:
        var xp_value = area.get_meta("xp", 12)
        appetite += xp_value
        
        if appetite >= appetite_required:
            level_up()
        
        spice_essences.erase(area)
        area.queue_free()
        update_all_ui()

func level_up():
    monster_level += 1
    appetite = 0
    appetite_required = int(appetite_required * 1.45)
    
    chef_health = min(chef_max_health, chef_health + 15)
    
    show_upgrade_choices()
    update_all_ui()

func show_upgrade_choices():
    var available = get_level_appropriate_upgrades()
    available.shuffle()
    
    current_upgrade_choices = [available[0], available[1], available[2]]
    
    upgrade_title.text = "🎉 CULINARY MASTERY! 🎉\nLevel %d - Choose evolution:" % monster_level
    
    option_a.text = current_upgrade_choices[0].name + "\n" + current_upgrade_choices[0].desc
    option_b.text = current_upgrade_choices[1].name + "\n" + current_upgrade_choices[1].desc
    option_c.text = current_upgrade_choices[2].name + "\n" + current_upgrade_choices[2].desc
    
    upgrade_panel.show()
    upgrade_panel.scale = Vector2(0.1, 0.1)
    upgrade_panel.modulate = Color(1, 1, 1, 0)
    
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(upgrade_panel, "scale", Vector2(1.15, 1.15), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
    tween.tween_property(upgrade_panel, "modulate", Color.WHITE, 0.4)
    tween.tween_property(upgrade_panel, "scale", Vector2(1, 1), 0.3).set_delay(0.5)
    
    is_upgrading = true

func get_level_appropriate_upgrades() -> Array[Dictionary]:
    var available: Array[Dictionary] = []
    
    for upgrade in enhanced_upgrades:
        if upgrade.type in ["cleavers", "damage", "speed", "movement", "size", "magnet", "health"]:
            available.append(upgrade)
        elif upgrade.type == "unlock_weapon":
            var weapon = upgrade.value
            if weapon == "whisk" and monster_level >= 3 and "whisk" not in active_weapons:
                available.append(upgrade)
    
    return available

func select_upgrade(choice_index: int):
    var upgrade = current_upgrade_choices[choice_index]
    
    apply_upgrade(upgrade)
    
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(upgrade_panel, "scale", Vector2(0.05, 0.05), 0.25)
    tween.tween_property(upgrade_panel, "modulate", Color(1, 1, 1, 0), 0.25)
    tween.finished.connect(func(): upgrade_panel.hide())
    
    is_upgrading = false
    show_upgrade_flash(upgrade.name)

func apply_upgrade(upgrade: Dictionary):
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

func show_upgrade_flash(upgrade_name: String):
    var flash = ColorRect.new()
    var flash_color = Color(1, 0.9, 0, 0.6)
    
    if "weapon" in upgrade_name.to_lower():
        flash_color = Color(0, 1, 0.8, 0.7)
    
    flash.color = flash_color
    flash.anchors_preset = Control.PRESET_FULL_RECT
    $UI.add_child(flash)
    
    var tween = create_tween()
    tween.tween_property(flash, "modulate", Color(flash_color.r, flash_color.g, flash_color.b, 0), 1.0)
    tween.finished.connect(func(): flash.queue_free())

func update_all_ui():
    chef_level_label.text = "🐉 Chef Level: %d" % monster_level
    appetite_bar.max_value = appetite_required
    appetite_bar.value = appetite
    appetite_label.text = "🔥 Appetite: %d/%d" % [appetite, appetite_required]
    ingredients_label.text = "🍴 Chopped: %d" % ingredients_chopped
    power_label.text = "⚡ Power: %s" % get_power_description()
    update_health_ui()
    weapons_label.text = "🔫 Weapons: %s" % ", ".join(active_weapons).capitalize()

func update_health_ui():
    health_bar.max_value = chef_max_health
    health_bar.value = chef_health
    health_label.text = "💚 Health: %d/%d" % [chef_health, chef_max_health]
    
    var health_ratio = float(chef_health) / float(chef_max_health)
    if health_ratio > 0.6:
        health_bar.modulate = Color.GREEN
    elif health_ratio > 0.3:
        health_bar.modulate = Color.YELLOW
    else:
        health_bar.modulate = Color.RED

func get_power_description() -> String:
    var base_desc = ""
    match monster_level:
        1, 2: base_desc = "Novice Chef"
        3, 4: base_desc = "Skilled Chef"
        5, 6, 7: base_desc = "Master Chef"
        8, 9, 10: base_desc = "Legendary Chef"
        _: base_desc = "CULINARY GOD Lv.%d" % monster_level
    
    if active_weapons.size() > 1:
        base_desc += " (%d weapons)" % active_weapons.size()
    
    return base_desc

func update_timer_and_stats():
    var minutes = int(game_time) / 60
    var seconds = int(game_time) % 60
    game_timer_label.text = "⏰ Time: %02d:%02d" % [minutes, seconds]
    enemies_label.text = "🧅🍅 Enemies: %d" % rebellious_ingredients.size()

func find_nearest_enemies(count: int) -> Array[Area2D]:
    var tomatoes: Array[Area2D] = []
    var onions: Array[Area2D] = []
    
    for ingredient in rebellious_ingredients:
        if is_instance_valid(ingredient):
            var enemy_type = ingredient.get_meta("enemy_type", "onion")
            if enemy_type == "tomato":
                tomatoes.append(ingredient)
            else:
                onions.append(ingredient)
    
    tomatoes.sort_custom(func(a, b): return a.global_position.distance_to(monster_chef.global_position) < b.global_position.distance_to(monster_chef.global_position))
    onions.sort_custom(func(a, b): return a.global_position.distance_to(monster_chef.global_position) < b.global_position.distance_to(monster_chef.global_position))
    
    var targets: Array[Area2D] = []
    targets.append_array(tomatoes)
    targets.append_array(onions)
    
    return targets.slice(0, count)

func spawn_initial_battle():
    for i in range(3):
        spawn_onion()

func cleanup_battlefield():
    rebellious_ingredients = rebellious_ingredients.filter(func(obj): return is_instance_valid(obj))
    flying_cleavers = flying_cleavers.filter(func(obj): return is_instance_valid(obj))
    whisk_tornadoes = whisk_tornadoes.filter(func(obj): return is_instance_valid(obj))
    enemy_projectiles = enemy_projectiles.filter(func(obj): return is_instance_valid(obj))
    spice_essences = spice_essences.filter(func(obj): return is_instance_valid(obj))

func _input(event):
    if event.is_action_pressed("ui_accept"):
        for i in range(6):
            if randf() > 0.4:
                spawn_onion()
            else:
                spawn_tomato()
        print("🚨 ENEMY WAVE! Mixed ingredients incoming!")
    
    if event.is_action_pressed("ui_select"):
        level_up()
        print("💪 Testing upgrade system!")
    
    if is_upgrading:
        if event.is_action_pressed("move_left"):
            select_upgrade(0)
        elif event.is_action_pressed("move_up"):
            select_upgrade(1)
        elif event.is_action_pressed("move_right"):
            select_upgrade(2)