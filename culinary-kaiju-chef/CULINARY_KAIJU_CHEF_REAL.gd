# 《彈幕天堂：美食怪獸主廚》REAL IMPLEMENTATION
# Following the actual PRD - Monster Chef vs Rebellious Food Ingredients!
extends Node2D

# Monster Chef (Player) - The giant culinary kaiju!
@onready var monster_chef: CharacterBody2D = $MonsterChef
@onready var ingredient_collector: Area2D = $MonsterChef/IngredientCollector

# UI System for culinary dominance display
@onready var monster_level_label: Label = $UI/ChefStatus/MonsterLevel
@onready var appetite_label: Label = $UI/ChefStatus/Appetite  
@onready var ingredients_label: Label = $UI/ChefStatus/IngredientsChopped
@onready var power_label: Label = $UI/ChefStatus/CulinaryPower

# Game State - The Chef's Culinary Empire
var monster_level: int = 1
var appetite: int = 0
var appetite_required: int = 100
var ingredients_chopped: int = 0
var culinary_power_level: int = 1

# Active Culinary Battlefield
var rebellious_ingredients: Array[Area2D] = []
var culinary_weapons: Array[Node2D] = []
var spice_essences: Array[Area2D] = []

# Core Game Timers - Following PRD's 3-act structure
var game_time: float = 0.0
var ingredient_spawn_timer: float = 0.0
var weapon_attack_timer: float = 0.0
var current_game_act: int = 1  # 1=Struggle, 2=Optimization, 3=Power Fantasy

# Monster Chef Properties - Grows with culinary mastery!
var monster_chef_speed: float = 180.0
var chef_size_multiplier: float = 1.0

# Weapon System - Data-driven culinary arsenal
var active_weapons: Array[Dictionary] = []

func _ready():
    print("🍳🐉 === CULINARY KAIJU CHEF: THE REAL DEAL === 🐉🍳")
    print("A GIANT MONSTER CHEF rises to face the REBELLIOUS INGREDIENT UPRISING!")
    print("Following the TRUE PRD vision...")
    
    # Initialize with basic cleaver weapon as per PRD
    add_culinary_weapon("cleaver_storm", {
        "damage": 25,
        "attack_speed": 1.5,
        "projectile_count": 2,
        "name": "Basic Cleaver Storm"
    })
    
    # Connect ingredient collector
    ingredient_collector.area_entered.connect(_on_spice_collected)
    
    # Start the culinary war!
    spawn_initial_rebellious_ingredients()
    
    # Test autoload integration
    test_autoload_systems()
    
    update_ui()

func test_autoload_systems():
    """Verify our beautiful architecture is working"""
    var systems_status = []
    if EventBus: 
        EventBus.player_health_changed.emit(100, 100)
        systems_status.append("EventBus✓")
    if Game: 
        systems_status.append("Game✓")
    if ObjectPool: 
        systems_status.append("ObjectPool✓")
    if DataManager: 
        systems_status.append("DataManager✓")
    
    print("🔧 Architecture Status: ", " ".join(systems_status))

func _process(delta):
    game_time += delta
    update_game_act()
    
    # Monster Chef Movement - The kaiju roams the culinary battlefield!
    handle_monster_chef_movement(delta)
    
    # Ingredient Spawning - Following PRD's difficulty curve
    handle_ingredient_spawning(delta)
    
    # Culinary Weapon System - Auto-attack the rebellious ingredients
    handle_culinary_weapons(delta)
    
    # Rebellious Ingredient AI - They approach menacingly!
    update_rebellious_ingredients(delta)
    
    # Cleanup destroyed objects
    cleanup_invalid_objects()

func update_game_act():
    """Implement PRD's 3-act structure"""
    var new_act = current_game_act
    
    if game_time < 300:  # 0-5 minutes: Struggle Phase
        new_act = 1
    elif game_time < 1200:  # 5-20 minutes: Optimization Phase  
        new_act = 2
    else:  # 20+ minutes: Power Fantasy Phase
        new_act = 3
    
    if new_act != current_game_act:
        current_game_act = new_act
        transition_to_act(current_game_act)

func transition_to_act(act: int):
    """Dramatic transitions between game acts as per PRD"""
    match act:
        1:
            print("🎭 ACT I: THE STRUGGLE - Survival against ingredient uprising!")
        2:
            print("🎭 ACT II: OPTIMIZATION - Strategic culinary mastery!")
            # Unlock more weapon types
            unlock_advanced_culinary_techniques()
        3:
            print("🎭 ACT III: POWER FANTASY - The chef's unstoppable reign!")
            # Massive power spike
            enter_culinary_god_mode()

func handle_monster_chef_movement(delta: float):
    """Giant monster chef movement with satisfying weight"""
    if not monster_chef:
        return
    
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    
    # Apply chef's growing power to movement
    var actual_speed = monster_chef_speed * (1.0 + culinary_power_level * 0.1)
    monster_chef.velocity = input_dir * actual_speed
    monster_chef.move_and_slide()
    
    # Chef faces movement direction with appropriate drama
    if input_dir.x != 0:
        var facing = 1 if input_dir.x > 0 else -1
        monster_chef.scale.x = abs(monster_chef.scale.x) * facing
    
    # Screen shake when the mighty chef moves!
    if input_dir.length() > 0.5 and monster_level >= 3:
        add_screen_shake(0.5)

func handle_ingredient_spawning(delta: float):
    """Spawn rebellious ingredients following PRD difficulty curve"""
    ingredient_spawn_timer += delta
    
    # Spawn rate based on current act and chef level
    var spawn_interval = get_ingredient_spawn_interval()
    
    if ingredient_spawn_timer >= spawn_interval:
        ingredient_spawn_timer = 0.0
        spawn_rebellious_ingredient()

func get_ingredient_spawn_interval() -> float:
    """Dynamic spawning based on PRD's 3-act structure"""
    var base_interval = 2.0
    
    match current_game_act:
        1:  # Struggle - Sparse but deadly
            base_interval = 3.0 - (monster_level * 0.2)
        2:  # Optimization - Increasing pressure
            base_interval = 1.5 - (monster_level * 0.1)  
        3:  # Power Fantasy - Overwhelming hordes for the chef to dominate
            base_interval = 0.8 - (monster_level * 0.05)
    
    return max(0.3, base_interval)

func spawn_rebellious_ingredient():
    """Spawn various types of rebellious food ingredients"""
    var ingredient_type = choose_ingredient_type()
    var ingredient = create_ingredient(ingredient_type)
    
    if ingredient:
        position_ingredient_around_chef(ingredient)
        rebellious_ingredients.append(ingredient)
        
        print("🧅 Rebellious %s joins the ingredient uprising!" % ingredient_type)

func choose_ingredient_type() -> String:
    """Choose ingredient type based on game progression"""
    var available_types = ["onion_grunt"]
    
    if monster_level >= 3:
        available_types.append("tomato_ranger")
    if monster_level >= 5:
        available_types.append("carrot_berserker")
    if monster_level >= 8:
        available_types.append("broccoli_tank")
    
    return available_types[randi() % available_types.size()]

func create_ingredient(type: String) -> Area2D:
    """Factory method for creating different ingredient types"""
    match type:
        "onion_grunt":
            return create_onion_grunt()
        "tomato_ranger": 
            return create_tomato_ranger()
        _:
            return create_onion_grunt()  # Default fallback

func create_onion_grunt() -> Area2D:
    """Create a rebellious onion grunt - the basic foot soldier"""
    var onion = Area2D.new()
    onion.add_to_group("rebellious_ingredients")
    onion.add_to_group("enemies")
    onion.collision_layer = 4
    onion.collision_mask = 8
    
    # Visual representation of angry onion
    var sprite_node = Node2D.new()
    var onion_body = ColorRect.new()
    onion_body.size = Vector2(24, 24)
    onion_body.position = Vector2(-12, -12)
    onion_body.color = Color(0.85, 0.7, 0.95, 1)
    sprite_node.add_child(onion_body)
    
    var angry_face = ColorRect.new()
    angry_face.size = Vector2(12, 6)
    angry_face.position = Vector2(-6, -3)
    angry_face.color = Color(0.8, 0.2, 0.2, 1)
    sprite_node.add_child(angry_face)
    
    onion.add_child(sprite_node)
    
    # Collision shape
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 12
    collision.shape = shape
    onion.add_child(collision)
    
    # Add behavior data
    onion.set_meta("health", 30)
    onion.set_meta("speed", 45.0)
    onion.set_meta("xp_reward", 8)
    onion.set_meta("ingredient_type", "onion_grunt")
    
    add_child(onion)
    return onion

func position_ingredient_around_chef(ingredient: Area2D):
    """Position ingredient in circle around chef"""
    var angle = randf() * TAU
    var distance = 500 + randf() * 200
    ingredient.global_position = monster_chef.global_position + Vector2.RIGHT.rotated(angle) * distance

func handle_culinary_weapons(delta: float):
    """Handle all active culinary weapons"""
    weapon_attack_timer += delta
    
    for weapon_data in active_weapons:
        weapon_data.timer += delta
        if weapon_data.timer >= weapon_data.attack_speed:
            weapon_data.timer = 0.0
            fire_culinary_weapon(weapon_data)

func fire_culinary_weapon(weapon_data: Dictionary):
    """Fire a culinary weapon at rebellious ingredients"""
    match weapon_data.type:
        "cleaver_storm":
            fire_cleaver_storm(weapon_data)
        _:
            fire_cleaver_storm(weapon_data)  # Default

func fire_cleaver_storm(weapon_data: Dictionary):
    """Fire a storm of cleavers at the rebellious ingredients"""
    var targets = find_nearest_ingredients(weapon_data.projectile_count)
    
    for i in range(weapon_data.projectile_count):
        var cleaver = create_flying_cleaver()
        
        # Aim at targets or random spread
        var direction: Vector2
        if i < targets.size():
            direction = (targets[i].global_position - monster_chef.global_position).normalized()
        else:
            var angle = randf() * TAU
            direction = Vector2.RIGHT.rotated(angle)
        
        launch_projectile(cleaver, direction, weapon_data)
    
    print("🔪 CLEAVER STORM! %d cleavers unleashed!" % weapon_data.projectile_count)

func create_flying_cleaver() -> Area2D:
    """Create a flying cleaver projectile"""
    var cleaver = Area2D.new()
    cleaver.add_to_group("culinary_weapons") 
    cleaver.collision_layer = 8
    cleaver.collision_mask = 4
    
    # Visual cleaver
    var sprite = Node2D.new()
    var blade = ColorRect.new()
    blade.size = Vector2(6, 16)
    blade.position = Vector2(-3, -8)
    blade.color = Color(0.9, 0.9, 1, 1)
    sprite.add_child(blade)
    
    var handle = ColorRect.new()
    handle.size = Vector2(4, 8)
    handle.position = Vector2(-2, 4)
    handle.color = Color(0.4, 0.2, 0.1, 1)
    sprite.add_child(handle)
    
    cleaver.add_child(sprite)
    
    # Collision
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 6
    collision.shape = shape
    cleaver.add_child(collision)
    
    # Connect hit detection
    cleaver.area_entered.connect(func(area): _on_cleaver_hit(cleaver, area))
    
    add_child(cleaver)
    return cleaver

func launch_projectile(projectile: Area2D, direction: Vector2, weapon_data: Dictionary):
    """Launch a projectile in the specified direction"""
    projectile.global_position = monster_chef.global_position
    projectile.set_meta("direction", direction)
    projectile.set_meta("speed", 250.0)
    projectile.set_meta("damage", weapon_data.damage)
    projectile.set_meta("lifetime", 4.0)
    
    culinary_weapons.append(projectile)

func update_rebellious_ingredients(delta: float):
    """Update AI for all rebellious ingredients"""
    for ingredient in rebellious_ingredients:
        if not is_instance_valid(ingredient):
            continue
        
        update_ingredient_ai(ingredient, delta)

func update_ingredient_ai(ingredient: Area2D, delta: float):
    """AI for individual ingredient"""
    if not monster_chef:
        return
    
    var speed = ingredient.get_meta("speed", 50.0)
    var direction = (monster_chef.global_position - ingredient.global_position).normalized()
    ingredient.global_position += direction * speed * delta
    
    # Rotate if it's an onion (they roll!)
    if ingredient.get_meta("ingredient_type") == "onion_grunt":
        var sprites = ingredient.get_children()
        if sprites.size() > 0:
            sprites[0].rotation += 2.0 * delta

func _on_cleaver_hit(cleaver: Area2D, target: Area2D):
    """Handle cleaver hitting an ingredient"""
    if target.is_in_group("rebellious_ingredients"):
        var damage = cleaver.get_meta("damage", 20)
        damage_ingredient(target, damage)
        
        # Remove cleaver
        if cleaver in culinary_weapons:
            culinary_weapons.erase(cleaver)
        cleaver.queue_free()

func damage_ingredient(ingredient: Area2D, damage: int):
    """Deal damage to a rebellious ingredient"""
    var current_health = ingredient.get_meta("health", 30)
    current_health -= damage
    ingredient.set_meta("health", current_health)
    
    # Flash effect
    var sprites = ingredient.get_children()
    if sprites.size() > 0:
        sprites[0].modulate = Color.RED
        create_tween().tween_property(sprites[0], "modulate", Color.WHITE, 0.2)
    
    print("💥 Ingredient takes %d damage! Health: %d" % [damage, current_health])
    
    if current_health <= 0:
        chop_ingredient(ingredient)

func chop_ingredient(ingredient: Area2D):
    """Successfully chop a rebellious ingredient!"""
    var xp_reward = ingredient.get_meta("xp_reward", 5)
    var ingredient_type = ingredient.get_meta("ingredient_type", "unknown")
    
    print("🍴 %s CHOPPED! +%d culinary experience!" % [ingredient_type.capitalize(), xp_reward])
    
    # Spawn spice essence
    spawn_spice_essence(ingredient.global_position, xp_reward)
    
    # Update stats
    ingredients_chopped += 1
    appetite += xp_reward
    
    # Check for level up
    if appetite >= appetite_required:
        level_up_monster_chef()
    
    # Remove ingredient
    rebellious_ingredients.erase(ingredient)
    ingredient.queue_free()
    
    update_ui()

func spawn_spice_essence(position: Vector2, value: int):
    """Spawn delicious spice essence"""
    var spice_scene = preload("res://features/items/spice_essence/SpiceEssence.tscn")
    var spice: Area2D
    
    if ObjectPool:
        spice = ObjectPool.request(spice_scene)
    else:
        spice = spice_scene.instantiate()
    
    if spice:
        add_child(spice)
        spice.global_position = position
        if spice.has_method("initialize_spice"):
            spice.initialize_spice(value)
        spice_essences.append(spice)

func _on_spice_collected(area: Area2D):
    """Chef collects spice essence"""
    if area.is_in_group("collectables"):
        var xp_value = area.get_meta("xp_value", 5)
        appetite += xp_value
        
        if appetite >= appetite_required:
            level_up_monster_chef()
        
        spice_essences.erase(area)
        area.queue_free()
        update_ui()

func level_up_monster_chef():
    """The monster chef grows in culinary power!"""
    monster_level += 1
    appetite = 0
    appetite_required = int(appetite_required * 1.4)
    culinary_power_level += 1
    
    # Chef grows bigger and more powerful!
    chef_size_multiplier += 0.15
    monster_chef.scale = Vector2(chef_size_multiplier, chef_size_multiplier)
    monster_chef_speed += 15
    
    # Upgrade weapons
    upgrade_culinary_arsenal()
    
    print("🎉 MONSTER CHEF LEVEL UP! Level %d achieved!" % monster_level)
    print("🔥 Culinary power increased! New arsenal capabilities unlocked!")
    
    update_ui()

func upgrade_culinary_arsenal():
    """Upgrade the chef's culinary weapons"""
    for weapon in active_weapons:
        if weapon.type == "cleaver_storm":
            weapon.damage += 5
            if monster_level % 2 == 0:
                weapon.projectile_count += 1
            if monster_level % 3 == 0:
                weapon.attack_speed *= 0.9  # Faster attacks

func add_culinary_weapon(type: String, stats: Dictionary):
    """Add a new culinary weapon to the chef's arsenal"""
    var weapon_data = stats.duplicate()
    weapon_data.type = type
    weapon_data.timer = 0.0
    active_weapons.append(weapon_data)

func find_nearest_ingredients(count: int) -> Array[Area2D]:
    """Find nearest rebellious ingredients"""
    var valid_ingredients: Array[Area2D] = []
    
    for ingredient in rebellious_ingredients:
        if is_instance_valid(ingredient):
            valid_ingredients.append(ingredient)
    
    # Sort by distance
    valid_ingredients.sort_custom(func(a, b):
        return a.global_position.distance_to(monster_chef.global_position) < b.global_position.distance_to(monster_chef.global_position)
    )
    
    return valid_ingredients.slice(0, count)

func cleanup_invalid_objects():
    """Clean up destroyed objects"""
    rebellious_ingredients = rebellious_ingredients.filter(func(obj): return is_instance_valid(obj))
    culinary_weapons = culinary_weapons.filter(func(obj): return is_instance_valid(obj))
    spice_essences = spice_essences.filter(func(obj): return is_instance_valid(obj))
    
    # Update flying projectiles
    for weapon in culinary_weapons:
        if not is_instance_valid(weapon):
            continue
            
        var direction = weapon.get_meta("direction", Vector2.RIGHT)
        var speed = weapon.get_meta("speed", 200.0)
        weapon.global_position += direction * speed * get_process_delta_time()
        
        # Remove if too far or lifetime expired
        var lifetime = weapon.get_meta("lifetime", 3.0) - get_process_delta_time()
        weapon.set_meta("lifetime", lifetime)
        
        if lifetime <= 0 or weapon.global_position.distance_to(monster_chef.global_position) > 800:
            culinary_weapons.erase(weapon)
            weapon.queue_free()

func spawn_initial_rebellious_ingredients():
    """Spawn initial wave of rebellious ingredients"""
    for i in range(4):
        spawn_rebellious_ingredient()

func unlock_advanced_culinary_techniques():
    """Unlock advanced weapons in Act II"""
    print("🔓 Advanced culinary techniques unlocked!")
    # Could add new weapon types here

func enter_culinary_god_mode():
    """Enter the power fantasy phase"""
    print("👑 CULINARY GOD MODE ACTIVATED!")
    monster_chef_speed *= 1.5
    
    # Massively upgrade all weapons
    for weapon in active_weapons:
        weapon.damage *= 2
        weapon.projectile_count *= 2
        weapon.attack_speed *= 0.5

func add_screen_shake(intensity: float):
    """Add screen shake effect"""
    # Simple screen shake implementation
    pass

func update_ui():
    """Update the culinary dominance display"""
    monster_level_label.text = "Monster Chef Level: %d" % monster_level
    appetite_label.text = "Culinary Appetite: %d/%d" % [appetite, appetite_required]
    ingredients_label.text = "Ingredients Chopped: %d" % ingredients_chopped
    
    var power_description = get_culinary_power_description()
    power_label.text = "Culinary Power: %s" % power_description

func get_culinary_power_description() -> String:
    """Get description of current culinary power level"""
    match culinary_power_level:
        1: return "Novice Chef"
        2, 3: return "Skilled Cook"
        4, 5: return "Master Chef"
        6, 7, 8: return "Culinary Artist"
        9, 10: return "Legendary Chef"
        _: return "CULINARY KAIJU GOD Lv.%d" % culinary_power_level

func _input(event):
    """Debug controls"""
    if event.is_action_pressed("ui_accept"):
        print("🚨 EMERGENCY INGREDIENT INVASION!")
        for i in range(8):
            spawn_rebellious_ingredient()
    
    if event.is_action_pressed("ui_select"):
        print("💪 CHEF POWER BOOST!")
        level_up_monster_chef()