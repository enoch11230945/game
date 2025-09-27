# 《彈幕天堂：美食怪獸主廚》(Culinary Kaiju Chef) - FINAL VERSION
# Following the TRUE PRD: Monster Chef vs Rebellious Food Ingredients!
extends Node2D

# Monster Chef (Player) - The giant culinary kaiju!
@onready var monster_chef: CharacterBody2D = $MonsterChef
@onready var ingredient_collector: Area2D = $MonsterChef/IngredientCollector

# Templates for spawning (hidden in-game, used as factories)
@onready var onion_template: Area2D = $OnionTemplate
@onready var cleaver_template: Area2D = $CleaverTemplate  
@onready var spice_template: Area2D = $SpiceTemplate

# UI Elements for culinary dominance display
@onready var monster_level_label: Label = $UI/ChefStatus/MonsterLevel
@onready var appetite_label: Label = $UI/ChefStatus/Appetite
@onready var ingredients_label: Label = $UI/ChefStatus/IngredientsChopped
@onready var power_label: Label = $UI/ChefStatus/CulinaryPower

# Game State following PRD's vision
var monster_level: int = 1
var appetite: int = 0
var appetite_required: int = 100
var ingredients_chopped: int = 0
var culinary_power_level: int = 1

# Active culinary battlefield
var rebellious_ingredients: Array[Area2D] = []
var flying_cleavers: Array[Area2D] = []
var spice_essences: Array[Area2D] = []

# Core game timers implementing PRD's 3-act structure  
var game_time: float = 0.0
var ingredient_spawn_timer: float = 0.0
var cleaver_attack_timer: float = 0.0
var current_game_act: int = 1  # 1=Struggle, 2=Optimization, 3=Power Fantasy

# Monster Chef properties - grows with culinary mastery!
var monster_chef_speed: float = 200.0
var chef_size_multiplier: float = 1.0
var cleaver_damage: int = 25
var cleavers_per_attack: int = 2

func _ready():
    print("🍳🐉 === CULINARY KAIJU CHEF: TRUE PRD IMPLEMENTATION === 🐉🍳")
    print("A GIANT MONSTER CHEF rises to face the REBELLIOUS INGREDIENT UPRISING!")
    print("Implementing the REAL game from your PRD...")
    
    # Hide templates (they are factories, not game objects)
    onion_template.hide()
    cleaver_template.hide()
    spice_template.hide()
    
    # Connect ingredient collector for spice essence gathering
    ingredient_collector.area_entered.connect(_on_spice_collected)
    
    # Test our beautiful autoload architecture
    test_architecture_integration()
    
    # Start the culinary war with initial rebellious ingredients!
    spawn_initial_ingredient_uprising()
    
    update_culinary_status_display()

func test_architecture_integration():
    """Verify our data-driven architecture is working"""
    var systems_online = []
    
    if EventBus: 
        EventBus.player_health_changed.emit(100, 100)
        systems_online.append("EventBus✓")
    if Game: 
        systems_online.append("Game✓")
    if ObjectPool: 
        systems_online.append("ObjectPool✓") 
    if DataManager: 
        systems_online.append("DataManager✓")
    
    print("🔧 Architecture Status: ", " ".join(systems_online))
    print("🏗️ Data-driven culinary warfare system: ONLINE")

func _process(delta):
    game_time += delta
    update_game_act_progression()
    
    # Monster Chef Movement - The mighty kaiju roams the culinary battlefield!
    handle_monster_chef_movement(delta)
    
    # Ingredient Uprising - Spawn rebellious food according to PRD difficulty curve
    handle_rebellious_ingredient_spawning(delta)
    
    # Culinary Weapons - Auto-attack system as per PRD specifications
    handle_cleaver_storm_attacks(delta)
    
    # Rebellious Ingredient AI - They approach the chef menacingly!
    update_rebellious_ingredient_behavior(delta)
    
    # Flying Cleaver Physics - Culinary projectiles in motion!
    update_flying_cleaver_trajectories(delta)
    
    # Spice Essence Collection - Magical ingredients drift toward the chef
    update_spice_essence_magnetism(delta)
    
    # Cleanup destroyed battlefield objects
    cleanup_culinary_battlefield()

func update_game_act_progression():
    """Implement PRD's 3-act dramatic structure"""
    var new_act = current_game_act
    
    # PRD specifies: 0-5min=Struggle, 5-20min=Optimization, 20-30min=Power Fantasy
    if game_time < 300:  # 0-5 minutes: Act I - The Struggle
        new_act = 1
    elif game_time < 1200:  # 5-20 minutes: Act II - Strategic Optimization  
        new_act = 2
    else:  # 20+ minutes: Act III - Power Fantasy Unleashed
        new_act = 3
    
    if new_act != current_game_act:
        current_game_act = new_act
        trigger_act_transition(current_game_act)

func trigger_act_transition(act: int):
    """Dramatic transitions between game acts as specified in PRD"""
    match act:
        1:
            print("🎭 ACT I: THE STRUGGLE FOR SURVIVAL")
            print("   The chef is vulnerable... rebellious ingredients approach!")
        2:
            print("🎭 ACT II: STRATEGIC CULINARY OPTIMIZATION") 
            print("   The chef grows in power... time for strategic upgrades!")
            unlock_advanced_culinary_techniques()
        3:
            print("🎭 ACT III: UNSTOPPABLE CULINARY POWER FANTASY")
            print("   THE CHEF ASCENDS! Witness culinary dominance!")
            activate_culinary_god_mode()

func handle_monster_chef_movement(delta: float):
    """Giant monster chef movement with appropriate kaiju weight and presence"""
    if not monster_chef:
        return
    
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    
    # Chef speed increases with culinary mastery
    var actual_speed = monster_chef_speed * (1.0 + culinary_power_level * 0.15)
    monster_chef.velocity = input_dir * actual_speed
    monster_chef.move_and_slide()
    
    # Chef faces movement direction with dramatic flair
    if input_dir.x != 0:
        var facing_direction = 1 if input_dir.x > 0 else -1
        monster_chef.scale.x = abs(monster_chef.scale.x) * facing_direction

func handle_rebellious_ingredient_spawning(delta: float):
    """Spawn rebellious ingredients following PRD's escalating difficulty curve"""
    ingredient_spawn_timer += delta
    
    var spawn_interval = calculate_ingredient_spawn_rate()
    
    if ingredient_spawn_timer >= spawn_interval:
        ingredient_spawn_timer = 0.0
        spawn_rebellious_onion_grunt()

func calculate_ingredient_spawn_rate() -> float:
    """Dynamic spawn rate based on PRD's 3-act structure and chef level"""
    var base_interval = 2.5
    
    match current_game_act:
        1:  # Act I: Sparse but threatening
            base_interval = 3.5 - (monster_level * 0.2)
        2:  # Act II: Escalating pressure requires strategic thinking
            base_interval = 2.0 - (monster_level * 0.15)  
        3:  # Act III: Overwhelming hordes for the mighty chef to dominate
            base_interval = 1.0 - (monster_level * 0.08)
    
    return max(0.4, base_interval)  # Never go below 0.4 seconds

func spawn_rebellious_onion_grunt():
    """Spawn a rebellious onion grunt - the foot soldiers of the ingredient uprising!"""
    var onion = onion_template.duplicate()
    add_child(onion)
    
    # Position around the chef in a menacing circle
    var spawn_angle = randf() * TAU
    var spawn_distance = 600 + randf() * 200
    onion.global_position = monster_chef.global_position + Vector2.RIGHT.rotated(spawn_angle) * spawn_distance
    onion.show()
    
    # Add onion-specific behavior data
    onion.set_meta("health", 25 + (monster_level * 3))  # Tougher onions as game progresses
    onion.set_meta("speed", 50.0 + (monster_level * 2))
    onion.set_meta("xp_reward", 8 + monster_level)
    onion.set_meta("ingredient_type", "rebellious_onion_grunt")
    onion.set_meta("roll_speed", 2.0 + randf() * 2.0)  # Onions roll as they move!
    
    # Connect collision detection for cleaver hits
    onion.area_entered.connect(func(area): _on_ingredient_hit_by_weapon(onion, area))
    
    rebellious_ingredients.append(onion)
    print("🧅 Rebellious Onion Grunt joins the ingredient uprising! Health: %d" % onion.get_meta("health"))

func handle_cleaver_storm_attacks(delta: float):
    """Handle the chef's signature cleaver storm attacks"""
    cleaver_attack_timer += delta
    
    # Attack speed increases with chef mastery
    var attack_interval = 1.8 - (culinary_power_level * 0.1)
    attack_interval = max(0.5, attack_interval)  # Cap minimum attack speed
    
    if cleaver_attack_timer >= attack_interval:
        cleaver_attack_timer = 0.0
        unleash_cleaver_storm()

func unleash_cleaver_storm():
    """The monster chef unleashes a devastating storm of flying cleavers!"""
    var target_ingredients = find_nearest_rebellious_ingredients(cleavers_per_attack)
    
    for i in range(cleavers_per_attack):
        var cleaver = create_flying_cleaver()
        
        # Aim at rebellious ingredients or use spread pattern
        var launch_direction: Vector2
        if i < target_ingredients.size():
            launch_direction = (target_ingredients[i].global_position - monster_chef.global_position).normalized()
        else:
            # Random spread if not enough targets
            var spread_angle = (TAU / cleavers_per_attack) * i + randf_range(-0.4, 0.4)  
            launch_direction = Vector2.RIGHT.rotated(spread_angle)
        
        launch_flying_cleaver(cleaver, launch_direction)
    
    print("🔪 CLEAVER STORM UNLEASHED! %d razor-sharp cleavers fly through the air!" % cleavers_per_attack)

func create_flying_cleaver() -> Area2D:
    """Create a flying cleaver projectile from template"""
    var cleaver = cleaver_template.duplicate()
    add_child(cleaver)
    
    # Add cleaver behavior data
    cleaver.set_meta("damage", cleaver_damage)
    cleaver.set_meta("speed", 280.0)
    cleaver.set_meta("lifetime", 4.0)
    cleaver.add_to_group("culinary_weapons")
    
    # Connect hit detection
    cleaver.area_entered.connect(func(area): _on_cleaver_hits_ingredient(cleaver, area))
    
    return cleaver

func launch_flying_cleaver(cleaver: Area2D, direction: Vector2):
    """Launch a cleaver in the specified direction"""
    cleaver.global_position = monster_chef.global_position
    cleaver.set_meta("direction", direction)
    cleaver.rotation = direction.angle()
    cleaver.show()
    
    flying_cleavers.append(cleaver)

func update_rebellious_ingredient_behavior(delta: float):
    """Update AI behavior for all rebellious ingredients"""
    for ingredient in rebellious_ingredients:
        if not is_instance_valid(ingredient):
            continue
        
        # Move toward the monster chef menacingly
        var speed = ingredient.get_meta("speed", 50.0)
        var direction_to_chef = (monster_chef.global_position - ingredient.global_position).normalized()
        ingredient.global_position += direction_to_chef * speed * delta
        
        # Onions roll as they move (authentic rebellious behavior!)
        if ingredient.get_meta("ingredient_type") == "rebellious_onion_grunt":
            var roll_speed = ingredient.get_meta("roll_speed", 2.0)
            var sprite_nodes = ingredient.get_children()
            for node in sprite_nodes:
                if node is Node2D and node.name == "OnionSprite":
                    node.rotation += roll_speed * delta
        
        # Check if ingredient reached the chef (oh no!)
        if ingredient.global_position.distance_to(monster_chef.global_position) < 60:
            print("💥 Rebellious ingredient attacks the mighty chef!")
            # Chef is tough but can take damage
            damage_monster_chef(5)
            
            # Remove the attacking ingredient
            rebellious_ingredients.erase(ingredient)
            ingredient.queue_free()

func update_flying_cleaver_trajectories(delta: float):
    """Update physics for all flying cleavers"""
    for cleaver in flying_cleavers:
        if not is_instance_valid(cleaver):
            continue
        
        # Move cleaver forward
        var direction = cleaver.get_meta("direction", Vector2.RIGHT)
        var speed = cleaver.get_meta("speed", 280.0)
        cleaver.global_position += direction * speed * delta
        
        # Spinning cleaver animation
        cleaver.rotation += 8.0 * delta
        
        # Remove if lifetime expired or too far
        var lifetime = cleaver.get_meta("lifetime", 4.0) - delta
        cleaver.set_meta("lifetime", lifetime)
        
        if lifetime <= 0 or cleaver.global_position.distance_to(monster_chef.global_position) > 900:
            flying_cleavers.erase(cleaver)
            cleaver.queue_free()

func update_spice_essence_magnetism(delta: float):
    """Update spice essences - they drift toward the mighty chef"""
    for spice in spice_essences:
        if not is_instance_valid(spice) or not monster_chef:
            continue
        
        # Magical attraction to the chef
        var direction_to_chef = (monster_chef.global_position - spice.global_position).normalized()
        var attraction_speed = 80.0 + (monster_level * 10.0)  # Stronger chefs attract ingredients faster
        spice.global_position += direction_to_chef * attraction_speed * delta
        
        # Add gentle sparkle rotation
        var sprite_nodes = spice.get_children()
        for node in sprite_nodes:
            if node is Node2D:
                node.rotation += 1.5 * delta

func _on_ingredient_hit_by_weapon(ingredient: Area2D, weapon: Area2D):
    """Handle when a culinary weapon hits a rebellious ingredient"""
    if weapon.is_in_group("culinary_weapons"):
        var damage = weapon.get_meta("damage", 20)
        damage_rebellious_ingredient(ingredient, damage)
        
        # Remove the weapon (cleavers are consumed on hit)
        if weapon in flying_cleavers:
            flying_cleavers.erase(weapon)
        weapon.queue_free()

func _on_cleaver_hits_ingredient(cleaver: Area2D, target: Area2D):
    """Handle cleaver collision with rebellious ingredient"""
    if target.is_in_group("enemies") or target.has_meta("ingredient_type"):
        var damage = cleaver.get_meta("damage", 25)
        damage_rebellious_ingredient(target, damage)
        
        # Remove cleaver on impact
        if cleaver in flying_cleavers:
            flying_cleavers.erase(cleaver)
        cleaver.queue_free()

func damage_rebellious_ingredient(ingredient: Area2D, damage: int):
    """Deal culinary damage to a rebellious ingredient"""
    var current_health = ingredient.get_meta("health", 25)
    current_health -= damage
    ingredient.set_meta("health", current_health)
    
    # Visual damage feedback - flash red
    var sprite_nodes = ingredient.get_children()
    for node in sprite_nodes:
        if node is Node2D:
            node.modulate = Color.RED
            create_tween().tween_property(node, "modulate", Color.WHITE, 0.15)
    
    print("💥 Rebellious ingredient takes %d culinary damage! Health remaining: %d" % [damage, current_health])
    
    if current_health <= 0:
        chop_rebellious_ingredient(ingredient)

func chop_rebellious_ingredient(ingredient: Area2D):
    """Successfully chop a rebellious ingredient - culinary victory!"""
    var xp_reward = ingredient.get_meta("xp_reward", 8)
    var ingredient_type = ingredient.get_meta("ingredient_type", "unknown_ingredient")
    
    print("🍴 %s EXPERTLY CHOPPED! +%d culinary experience points!" % [ingredient_type.replace("_", " ").to_upper(), xp_reward])
    
    # Spawn delicious spice essence at the chopping location
    spawn_spice_essence(ingredient.global_position, xp_reward)
    
    # Update chef's culinary progress
    ingredients_chopped += 1
    appetite += xp_reward
    
    # Check for level advancement
    if appetite >= appetite_required:
        advance_monster_chef_level()
    
    # Remove the defeated ingredient from the battlefield
    rebellious_ingredients.erase(ingredient)
    ingredient.queue_free()
    
    # Notify architecture systems
    if EventBus:
        EventBus.enemy_killed.emit(ingredient, xp_reward)
    
    update_culinary_status_display()

func spawn_spice_essence(position: Vector2, value: int):
    """Spawn delicious spice essence at the specified location"""
    var spice = spice_template.duplicate()
    add_child(spice)
    spice.global_position = position
    
    # Set spice value and visual properties
    spice.set_meta("xp_value", value)
    
    # Color-code spice by value (higher value = more golden)
    var spice_color = Color.YELLOW
    if value >= 15:
        spice_color = Color.GOLD
    elif value >= 12:
        spice_color = Color.ORANGE
    
    var sprite_nodes = spice.get_children()
    for node in sprite_nodes:
        if node is Node2D:
            node.modulate = spice_color
    
    spice.show()
    spice_essences.append(spice)
    
    print("⭐ Delicious spice essence manifests! Value: %d culinary points" % value)

func _on_spice_collected(area: Area2D):
    """Monster chef collects spice essence to grow in culinary power"""
    if area in spice_essences or area.has_meta("xp_value"):
        var xp_value = area.get_meta("xp_value", 5)
        
        print("✨ SPICE ESSENCE ABSORBED! The chef's culinary power grows! +%d" % xp_value)
        
        appetite += xp_value
        
        if appetite >= appetite_required:
            advance_monster_chef_level()
        
        spice_essences.erase(area)
        area.queue_free()
        update_culinary_status_display()

func advance_monster_chef_level():
    """Level up the monster chef - implementing PRD's progression system"""
    monster_level += 1
    appetite = 0
    appetite_required = int(appetite_required * 1.5)  # Exponential XP curve as per PRD
    culinary_power_level += 1
    
    # Physical growth - the chef becomes more imposing!
    chef_size_multiplier += 0.12
    monster_chef.scale = Vector2(chef_size_multiplier, chef_size_multiplier)
    
    # Speed increase - mastery brings swiftness
    monster_chef_speed += 18
    
    # Combat upgrades - sharper cleavers, more devastating attacks
    upgrade_culinary_combat_capabilities()
    
    print("🎉 MONSTER CHEF ASCENSION! LEVEL %d ACHIEVED!" % monster_level) 
    print("🔥 Culinary mastery deepens! New powers unlocked!")
    print("   - Chef size: %.1fx" % chef_size_multiplier)
    print("   - Movement speed: %.0f" % monster_chef_speed)
    print("   - Cleaver damage: %d" % cleaver_damage)
    print("   - Cleavers per storm: %d" % cleavers_per_attack)
    
    update_culinary_status_display()

func upgrade_culinary_combat_capabilities():
    """Upgrade the chef's combat abilities following PRD progression"""
    # Damage scaling
    cleaver_damage += 6 + (monster_level * 2)
    
    # More cleavers at certain levels
    if monster_level % 3 == 0:
        cleavers_per_attack += 1
    
    # Special upgrades at milestone levels
    match monster_level:
        5:
            print("🌟 MILESTONE: Cleaver Mastery Unlocked!")
        10:
            print("🌟 MILESTONE: Culinary Storm Lord!")
            cleavers_per_attack += 2
        15:
            print("🌟 MILESTONE: Legendary Chef Status!")
        20:
            print("👑 ULTIMATE MILESTONE: CULINARY KAIJU GOD!")
            enter_ultimate_chef_mode()

func damage_monster_chef(damage: int):
    """The mighty chef takes damage (but is very resilient)"""
    print("⚔️  Chef takes %d damage, but remains mighty!" % damage)  
    # Chef could have health system here if desired

func spawn_initial_ingredient_uprising():
    """Start the game with initial rebellious ingredients"""
    print("🚨 THE INGREDIENT UPRISING BEGINS!")
    for i in range(5):
        spawn_rebellious_onion_grunt()

func find_nearest_rebellious_ingredients(count: int) -> Array[Area2D]:
    """Find the nearest rebellious ingredients for targeting"""
    var valid_targets: Array[Area2D] = []
    
    for ingredient in rebellious_ingredients:
        if is_instance_valid(ingredient):
            valid_targets.append(ingredient)
    
    # Sort by distance to chef (closest first)
    valid_targets.sort_custom(func(a, b):
        var distance_a = a.global_position.distance_to(monster_chef.global_position)
        var distance_b = b.global_position.distance_to(monster_chef.global_position)
        return distance_a < distance_b
    )
    
    return valid_targets.slice(0, count)

func cleanup_culinary_battlefield():
    """Clean up destroyed objects from the battlefield"""
    rebellious_ingredients = rebellious_ingredients.filter(func(obj): return is_instance_valid(obj))
    flying_cleavers = flying_cleavers.filter(func(obj): return is_instance_valid(obj))
    spice_essences = spice_essences.filter(func(obj): return is_instance_valid(obj))

func unlock_advanced_culinary_techniques():
    """Unlock advanced techniques in Act II as per PRD"""
    print("🔓 Advanced Culinary Techniques Unlocked!")
    print("   - Enhanced cleaver storm patterns")
    print("   - Improved ingredient targeting")
    
    # Boost existing capabilities
    cleavers_per_attack += 1
    cleaver_damage += 10

func activate_culinary_god_mode():
    """Enter Act III power fantasy mode as specified in PRD"""
    print("👑 CULINARY GOD MODE ACTIVATED!")
    print("   The chef's power becomes overwhelming!")
    
    # Massive power boost for power fantasy phase
    monster_chef_speed *= 1.4
    cleaver_damage *= 1.8
    cleavers_per_attack *= 2
    
    print("   - God-tier movement speed: %.0f" % monster_chef_speed)
    print("   - Divine cleaver damage: %d" % cleaver_damage)
    print("   - Apocalyptic cleaver count: %d" % cleavers_per_attack)

func enter_ultimate_chef_mode():
    """Ultimate chef transformation"""
    print("💫 ULTIMATE CULINARY KAIJU TRANSFORMATION!")
    monster_chef.modulate = Color.GOLD
    chef_size_multiplier *= 1.5
    monster_chef.scale = Vector2(chef_size_multiplier, chef_size_multiplier)

func update_culinary_status_display():
    """Update the UI to show chef's culinary dominance"""
    monster_level_label.text = "🐉 Monster Chef Level: %d" % monster_level
    appetite_label.text = "🔥 Culinary Appetite: %d/%d" % [appetite, appetite_required]
    ingredients_label.text = "🍴 Ingredients Chopped: %d" % ingredients_chopped
    
    var power_description = get_culinary_power_description()
    power_label.text = "⚡ Power Level: %s" % power_description

func get_culinary_power_description() -> String:
    """Get current culinary power level description"""
    match culinary_power_level:
        1, 2: return "Novice Monster Chef"
        3, 4, 5: return "Skilled Culinary Beast"
        6, 7, 8: return "Master Chef Kaiju"
        9, 10, 11: return "Legendary Food Destroyer"
        12, 13, 14: return "Culinary Storm Lord"
        15, 16, 17: return "Divine Kitchen Destroyer"
        18, 19, 20: return "Ultimate Chef Kaiju"
        _: return "CULINARY GOD LEVEL %d" % culinary_power_level

func _input(event):
    """Debug controls for testing"""
    if event.is_action_pressed("ui_accept"):
        print("🚨 EMERGENCY INGREDIENT SWARM!")
        for i in range(10):
            spawn_rebellious_onion_grunt()
    
    if event.is_action_pressed("ui_select"):
        print("💪 INSTANT CHEF POWER BOOST!")
        advance_monster_chef_level()