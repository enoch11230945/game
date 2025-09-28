# CULINARY_KAIJU_CHEF_COMPLETE.gd
# The COMPLETE implementation with proper UI and upgrade system!
extends Node2D

# Core game objects
@onready var monster_chef: CharacterBody2D = $MonsterChef
@onready var ingredient_collector: Area2D = $MonsterChef/IngredientCollector

# Templates
@onready var onion_template: Area2D = $OnionTemplate
@onready var cleaver_template: Area2D = $CleaverTemplate  
@onready var spice_template: Area2D = $SpiceTemplate

# UI System - The complete PRD implementation!
@onready var chef_level_label: Label = $UI/HUD/TopLeft/ChefLevel
@onready var appetite_bar: ProgressBar = $UI/HUD/TopLeft/AppetiteBar
@onready var appetite_label: Label = $UI/HUD/TopLeft/AppetiteLabel
@onready var ingredients_label: Label = $UI/HUD/TopLeft/IngredientsChopped
@onready var power_label: Label = $UI/HUD/TopLeft/CulinaryPower
@onready var game_timer_label: Label = $UI/HUD/TopRight/GameTimer
@onready var enemies_label: Label = $UI/HUD/TopRight/EnemiesAlive
@onready var upgrade_ui: UpgradeSelectionUI = $UI/UpgradeSelectionUI

# Game state following PRD
var monster_level: int = 1
var appetite: int = 0
var appetite_required: int = 100
var ingredients_chopped: int = 0
var culinary_power_level: int = 1

# Upgrade-able chef stats
var monster_chef_speed: float = 200.0
var chef_size_multiplier: float = 1.0
var cleaver_damage: int = 25
var cleavers_per_attack: int = 2
var attack_speed_multiplier: float = 1.0
var collection_range_multiplier: float = 1.0

# Active battlefield
var rebellious_ingredients: Array[Area2D] = []
var flying_cleavers: Array[Area2D] = []
var spice_essences: Array[Area2D] = []

# Timers
var game_time: float = 0.0
var ingredient_spawn_timer: float = 0.0
var cleaver_attack_timer: float = 0.0
var current_game_act: int = 1

func _ready():
    print("🍳🐉 === COMPLETE CULINARY KAIJU CHEF WITH UPGRADE SYSTEM === 🐉🍳")
    
    # Add to main_game group so UI can find us
    add_to_group("main_game")
    
    # Hide templates
    onion_template.hide()
    cleaver_template.hide()
    spice_template.hide()
    
    # Connect systems
    ingredient_collector.area_entered.connect(_on_spice_collected)
    
    # Start the culinary war!
    spawn_initial_ingredients()
    update_all_ui()

func _process(delta):
    game_time += delta
    
    # Chef movement
    handle_monster_chef_movement(delta)
    
    # Game systems
    handle_ingredient_spawning(delta)
    handle_cleaver_attacks(delta)
    update_rebellious_ingredients(delta)
    update_flying_cleavers(delta)
    update_spice_essences(delta)
    
    # UI updates
    update_timer_display()
    update_enemies_count()
    
    # Cleanup
    cleanup_battlefield()

func handle_monster_chef_movement(delta: float):
    """Enhanced chef movement with upgrade effects"""
    if not monster_chef:
        return
    
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var actual_speed = monster_chef_speed * (1.0 + culinary_power_level * 0.1)
    monster_chef.velocity = input_dir * actual_speed
    monster_chef.move_and_slide()
    
    if input_dir.x != 0:
        monster_chef.scale.x = abs(monster_chef.scale.x) * (1 if input_dir.x > 0 else -1)

func handle_ingredient_spawning(delta: float):
    """Spawn rebellious ingredients"""
    ingredient_spawn_timer += delta
    var spawn_interval = 2.5 - (monster_level * 0.15)
    spawn_interval = max(0.5, spawn_interval)
    
    if ingredient_spawn_timer >= spawn_interval:
        ingredient_spawn_timer = 0.0
        spawn_rebellious_onion()

func handle_cleaver_attacks(delta: float):
    """Handle cleaver storm attacks with upgrades"""
    cleaver_attack_timer += delta
    var attack_interval = (1.8 / attack_speed_multiplier) - (culinary_power_level * 0.05)
    attack_interval = max(0.3, attack_interval)
    
    if cleaver_attack_timer >= attack_interval:
        cleaver_attack_timer = 0.0
        unleash_cleaver_storm()

func spawn_rebellious_onion():
    """Spawn enhanced rebellious onion"""
    var onion = onion_template.duplicate()
    add_child(onion)
    
    # Position around chef
    var angle = randf() * TAU
    var distance = 600 + randf() * 200
    onion.global_position = monster_chef.global_position + Vector2.RIGHT.rotated(angle) * distance
    onion.show()
    
    # Enhanced onion stats
    onion.set_meta("health", 25 + (monster_level * 3))
    onion.set_meta("speed", 50.0 + (monster_level * 2))
    onion.set_meta("xp_reward", 8 + monster_level)
    onion.set_meta("roll_speed", randf_range(2.0, 4.0))
    
    # Connect collision
    onion.area_entered.connect(func(area): _on_ingredient_hit_by_weapon(onion, area))
    
    rebellious_ingredients.append(onion)

func unleash_cleaver_storm():
    """Enhanced cleaver storm with upgrade effects"""
    var targets = find_nearest_ingredients(cleavers_per_attack)
    
    for i in range(cleavers_per_attack):
        var cleaver = create_flying_cleaver()
        
        var direction: Vector2
        if i < targets.size():
            direction = (targets[i].global_position - monster_chef.global_position).normalized()
        else:
            var spread = (TAU / cleavers_per_attack) * i + randf_range(-0.3, 0.3)
            direction = Vector2.RIGHT.rotated(spread)
        
        launch_cleaver(cleaver, direction)
    
    print("🔪 ENHANCED CLEAVER STORM! %d cleavers with %d damage each!" % [cleavers_per_attack, cleaver_damage])

func create_flying_cleaver() -> Area2D:
    """Create enhanced flying cleaver"""
    var cleaver = cleaver_template.duplicate()
    add_child(cleaver)
    
    cleaver.set_meta("damage", cleaver_damage)
    cleaver.set_meta("speed", 280.0)
    cleaver.set_meta("lifetime", 4.0)
    cleaver.add_to_group("culinary_weapons")
    
    cleaver.area_entered.connect(func(area): _on_cleaver_hits_ingredient(cleaver, area))
    
    return cleaver

func launch_cleaver(cleaver: Area2D, direction: Vector2):
    """Launch cleaver with effects"""
    cleaver.global_position = monster_chef.global_position
    cleaver.set_meta("direction", direction)
    cleaver.rotation = direction.angle()
    cleaver.show()
    flying_cleavers.append(cleaver)

func update_rebellious_ingredients(delta: float):
    """Update ingredient AI"""
    for ingredient in rebellious_ingredients:
        if not is_instance_valid(ingredient):
            continue
        
        # Movement
        var speed = ingredient.get_meta("speed", 50.0)
        var direction = (monster_chef.global_position - ingredient.global_position).normalized()
        ingredient.global_position += direction * speed * delta
        
        # Rolling animation
        var roll_speed = ingredient.get_meta("roll_speed", 2.0)
        var sprite_node = ingredient.get_node_or_null("OnionSprite")
        if sprite_node:
            sprite_node.rotation += roll_speed * delta
        
        # Check collision with chef
        if ingredient.global_position.distance_to(monster_chef.global_position) < 60:
            print("💥 Ingredient attacks the chef!")
            rebellious_ingredients.erase(ingredient)
            ingredient.queue_free()

func update_flying_cleavers(delta: float):
    """Update cleaver physics"""
    for cleaver in flying_cleavers:
        if not is_instance_valid(cleaver):
            continue
        
        var direction = cleaver.get_meta("direction", Vector2.RIGHT)
        var speed = cleaver.get_meta("speed", 280.0)
        cleaver.global_position += direction * speed * delta
        cleaver.rotation += 8.0 * delta
        
        var lifetime = cleaver.get_meta("lifetime", 4.0) - delta
        cleaver.set_meta("lifetime", lifetime)
        
        if lifetime <= 0 or cleaver.global_position.distance_to(monster_chef.global_position) > 900:
            flying_cleavers.erase(cleaver)
            cleaver.queue_free()

func update_spice_essences(delta: float):
    """Update spice essence magnetism with upgrades"""
    for spice in spice_essences:
        if not is_instance_valid(spice) or not monster_chef:
            continue
        
        var direction = (monster_chef.global_position - spice.global_position).normalized()
        var attraction_speed = (80.0 + monster_level * 10) * collection_range_multiplier
        spice.global_position += direction * attraction_speed * delta
        
        # Sparkle rotation
        var sprite_node = spice.get_node_or_null("SpiceSprite")
        if sprite_node:
            sprite_node.rotation += 1.5 * delta

func _on_ingredient_hit_by_weapon(ingredient: Area2D, weapon: Area2D):
    """Handle weapon hitting ingredient"""
    if weapon.is_in_group("culinary_weapons"):
        var damage = weapon.get_meta("damage", 20)
        damage_ingredient(ingredient, damage)
        
        if weapon in flying_cleavers:
            flying_cleavers.erase(weapon)
        weapon.queue_free()

func _on_cleaver_hits_ingredient(cleaver: Area2D, target: Area2D):
    """Handle cleaver collision"""
    if target in rebellious_ingredients:
        var damage = cleaver.get_meta("damage", 25)
        damage_ingredient(target, damage)
        
        if cleaver in flying_cleavers:
            flying_cleavers.erase(cleaver)
        cleaver.queue_free()

func damage_ingredient(ingredient: Area2D, damage: int):
    """Deal damage to ingredient"""
    var current_health = ingredient.get_meta("health", 25)
    current_health -= damage
    ingredient.set_meta("health", current_health)
    
    # Flash effect
    var sprite_node = ingredient.get_node_or_null("OnionSprite")
    if sprite_node:
        sprite_node.modulate = Color.RED
        create_tween().tween_property(sprite_node, "modulate", Color.WHITE, 0.15)
    
    if current_health <= 0:
        chop_ingredient(ingredient)

func chop_ingredient(ingredient: Area2D):
    """Successfully chop ingredient"""
    var xp_reward = ingredient.get_meta("xp_reward", 8)
    
    print("🍴 INGREDIENT CHOPPED! +%d culinary experience!" % xp_reward)
    
    spawn_spice_essence(ingredient.global_position, xp_reward)
    
    ingredients_chopped += 1
    appetite += xp_reward
    
    # CHECK FOR LEVEL UP - This triggers the 3-choose-1 UI!
    if appetite >= appetite_required:
        level_up_monster_chef()
    
    rebellious_ingredients.erase(ingredient)
    ingredient.queue_free()
    
    update_all_ui()

func spawn_spice_essence(position: Vector2, value: int):
    """Spawn spice essence"""
    var spice = spice_template.duplicate()
    add_child(spice)
    spice.global_position = position
    spice.set_meta("xp_value", value)
    
    # Color by value
    var color = Color.YELLOW
    if value >= 15:
        color = Color.GOLD
    elif value >= 12:
        color = Color.ORANGE
    
    var sprite_node = spice.get_node_or_null("SpiceSprite")
    if sprite_node:
        sprite_node.modulate = color
    
    spice.show()
    spice_essences.append(spice)

func _on_spice_collected(area: Area2D):
    """Chef collects spice essence"""
    if area in spice_essences:
        var xp_value = area.get_meta("xp_value", 5)
        appetite += xp_value
        
        if appetite >= appetite_required:
            level_up_monster_chef()
        
        spice_essences.erase(area)
        area.queue_free()
        update_all_ui()

func level_up_monster_chef():
    """LEVEL UP - Trigger the PRD's 3-choose-1 upgrade system!"""
    monster_level += 1
    appetite = 0
    appetite_required = int(appetite_required * 1.4)
    culinary_power_level += 1
    
    print("🎉 LEVEL UP! Monster Chef reaches level %d!" % monster_level)
    print("🎰 Presenting upgrade choices - THE SLOT MACHINE EFFECT!")
    
    # THIS IS THE KEY - Show the 3-choose-1 upgrade UI!
    if upgrade_ui:
        upgrade_ui.present_upgrade_choices(monster_level)
    
    update_all_ui()

# UPGRADE SYSTEM - Apply effects from the 3-choose-1 UI
func apply_upgrade(upgrade: Dictionary):
    """Apply selected upgrade from the UI system"""
    print("🔥 APPLYING UPGRADE: %s" % upgrade.name)
    
    match upgrade.effect:
        "projectile_count":
            cleavers_per_attack += upgrade.value
            print("   - Cleavers per attack: %d" % cleavers_per_attack)
        
        "damage":
            cleaver_damage += upgrade.value
            print("   - Cleaver damage: %d" % cleaver_damage)
        
        "attack_speed":
            attack_speed_multiplier *= (1.0 / upgrade.value)
            print("   - Attack speed multiplier: %.2f" % attack_speed_multiplier)
        
        "movement_speed":
            monster_chef_speed += upgrade.value
            print("   - Movement speed: %.0f" % monster_chef_speed)
        
        "size_multiplier":
            chef_size_multiplier *= upgrade.value
            monster_chef.scale = Vector2(chef_size_multiplier, chef_size_multiplier)
            print("   - Chef size multiplier: %.2f" % chef_size_multiplier)
        
        "collection_range":
            collection_range_multiplier *= upgrade.value
            # Also increase collector size
            var collector_shape = ingredient_collector.get_node("CollectorShape").shape as CircleShape2D
            if collector_shape:
                collector_shape.radius *= upgrade.value
            print("   - Collection range multiplier: %.2f" % collection_range_multiplier)
    
    # Visual feedback
    show_upgrade_flash()
    update_all_ui()

func show_upgrade_flash():
    """Show satisfying upgrade flash"""
    var flash = ColorRect.new()
    flash.color = Color(1, 1, 0, 0.3)
    flash.anchors_preset = Control.PRESET_FULL_RECT
    $UI.add_child(flash)
    
    var tween = create_tween()
    tween.tween_property(flash, "modulate", Color(1, 1, 0, 0), 0.5)
    tween.finished.connect(func(): flash.queue_free())

func update_all_ui():
    """Update all UI elements"""
    chef_level_label.text = "🐉 Chef Level: %d" % monster_level
    
    appetite_bar.max_value = appetite_required
    appetite_bar.value = appetite
    appetite_label.text = "🔥 Culinary Appetite: %d/%d" % [appetite, appetite_required]
    
    ingredients_label.text = "🍴 Ingredients Chopped: %d" % ingredients_chopped
    power_label.text = "⚡ Power: %s" % get_power_description()

func get_power_description() -> String:
    """Get power level description"""
    match culinary_power_level:
        1, 2: return "Novice Monster Chef"
        3, 4, 5: return "Skilled Culinary Beast"
        6, 7, 8: return "Master Chef Kaiju" 
        9, 10: return "Legendary Food Destroyer"
        _: return "CULINARY GOD Lv.%d" % culinary_power_level

func update_timer_display():
    """Update game timer"""
    var minutes = int(game_time) / 60
    var seconds = int(game_time) % 60
    game_timer_label.text = "⏰ Time: %02d:%02d" % [minutes, seconds]

func update_enemies_count():
    """Update enemies alive count"""
    enemies_label.text = "🧅 Rebellious Ingredients: %d" % rebellious_ingredients.size()

func find_nearest_ingredients(count: int) -> Array[Area2D]:
    """Find nearest ingredients for targeting"""
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
    for i in range(5):
        spawn_rebellious_onion()

func cleanup_battlefield():
    """Clean up invalid objects"""  
    rebellious_ingredients = rebellious_ingredients.filter(func(obj): return is_instance_valid(obj))
    flying_cleavers = flying_cleavers.filter(func(obj): return is_instance_valid(obj))
    spice_essences = spice_essences.filter(func(obj): return is_instance_valid(obj))

func _input(event):
    """Debug controls"""
    if event.is_action_pressed("ui_accept"):
        for i in range(8):
            spawn_rebellious_onion()
    
    if event.is_action_pressed("ui_select"):
        level_up_monster_chef()  # Test the upgrade system!