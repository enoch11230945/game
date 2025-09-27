# FINAL_GAME_WITH_UPGRADES.gd
# Complete Culinary Kaiju Chef with 3-choose-1 upgrade system!
extends Node2D

# Core game objects
@onready var monster_chef: CharacterBody2D = $MonsterChef
@onready var ingredient_collector: Area2D = $MonsterChef/IngredientCollector
@onready var onion_template: Area2D = $OnionTemplate
@onready var cleaver_template: Area2D = $CleaverTemplate  
@onready var spice_template: Area2D = $SpiceTemplate

# UI Elements
@onready var chef_level_label: Label = $UI/HUD/TopLeft/ChefLevel
@onready var appetite_bar: ProgressBar = $UI/HUD/TopLeft/AppetiteBar
@onready var appetite_label: Label = $UI/HUD/TopLeft/AppetiteLabel
@onready var ingredients_label: Label = $UI/HUD/TopLeft/IngredientsChopped
@onready var power_label: Label = $UI/HUD/TopLeft/CulinaryPower

# UPGRADE SYSTEM UI - The 3-choose-1 "slot machine effect"!
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

# Upgrade-able stats
var monster_chef_speed: float = 200.0
var cleaver_damage: int = 25
var cleavers_per_attack: int = 2
var attack_speed_multiplier: float = 1.0
var chef_size_multiplier: float = 1.0

# Game objects
var rebellious_ingredients: Array[Area2D] = []
var flying_cleavers: Array[Area2D] = []
var spice_essences: Array[Area2D] = []

# Timers
var ingredient_spawn_timer: float = 0.0
var cleaver_attack_timer: float = 0.0

# Upgrade choices (the PRD's "slot machine effect")
var upgrade_options = [
    {"name": "🔪 Extra Cleavers", "desc": "Throw +2 more cleavers per attack!", "type": "cleavers", "value": 2},
    {"name": "⚔️ Sharp Blades", "desc": "Cleavers deal +15 more damage!", "type": "damage", "value": 15},
    {"name": "⚡ Lightning Speed", "desc": "Attack 25% faster!", "type": "speed", "value": 0.75},
    {"name": "💪 Chef Vigor", "desc": "Move 30% faster!", "type": "movement", "value": 30},
    {"name": "🐉 Kaiju Growth", "desc": "Grow 20% larger!", "type": "size", "value": 1.2},
    {"name": "🌟 Spice Magnet", "desc": "Attract ingredients from farther!", "type": "magnet", "value": 1.5}
]

var current_upgrade_choices: Array[Dictionary] = []
var is_upgrading: bool = false

func _ready():
    print("🍳🐉 === COMPLETE CULINARY KAIJU CHEF WITH UPGRADE SYSTEM === 🐉🍳")
    
    # Hide templates
    onion_template.hide()
    cleaver_template.hide()
    spice_template.hide()
    upgrade_panel.hide()
    
    # Connect systems
    ingredient_collector.area_entered.connect(_on_spice_collected)
    option_a.pressed.connect(func(): select_upgrade(0))
    option_b.pressed.connect(func(): select_upgrade(1))
    option_c.pressed.connect(func(): select_upgrade(2))
    
    # Start game
    spawn_initial_ingredients()
    update_ui()

func _process(delta):
    if is_upgrading:
        return  # Pause game during upgrades
    
    # Chef movement
    handle_chef_movement(delta)
    
    # Game systems
    handle_spawning(delta)
    handle_combat(delta)
    update_objects(delta)
    
    # Cleanup
    cleanup()

func handle_chef_movement(delta: float):
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    monster_chef.velocity = input_dir * monster_chef_speed
    monster_chef.move_and_slide()
    
    if input_dir.x != 0:
        monster_chef.scale.x = abs(monster_chef.scale.x) * (1 if input_dir.x > 0 else -1)

func handle_spawning(delta: float):
    ingredient_spawn_timer += delta
    if ingredient_spawn_timer > 2.0:
        ingredient_spawn_timer = 0.0
        spawn_onion()

func handle_combat(delta: float):
    cleaver_attack_timer += delta
    var attack_interval = 1.5 / attack_speed_multiplier
    if cleaver_attack_timer > attack_interval:
        cleaver_attack_timer = 0.0
        throw_cleavers()

func spawn_onion():
    var onion = onion_template.duplicate()
    add_child(onion)
    
    var angle = randf() * TAU
    var distance = 600
    onion.global_position = monster_chef.global_position + Vector2.RIGHT.rotated(angle) * distance
    onion.show()
    
    onion.set_meta("health", 30)
    onion.set_meta("xp", 10)
    onion.area_entered.connect(func(area): hit_onion(onion, area))
    
    rebellious_ingredients.append(onion)

func throw_cleavers():
    for i in range(cleavers_per_attack):
        var cleaver = cleaver_template.duplicate()
        add_child(cleaver)
        
        cleaver.global_position = monster_chef.global_position
        
        var direction: Vector2
        if rebellious_ingredients.size() > i:
            var target = rebellious_ingredients[i]
            direction = (target.global_position - monster_chef.global_position).normalized()
        else:
            var angle = (TAU / cleavers_per_attack) * i
            direction = Vector2.RIGHT.rotated(angle)
        
        cleaver.set_meta("direction", direction)
        cleaver.set_meta("damage", cleaver_damage)
        cleaver.rotation = direction.angle()
        cleaver.show()
        
        flying_cleavers.append(cleaver)
    
    print("🔪 Threw %d cleavers with %d damage each!" % [cleavers_per_attack, cleaver_damage])

func update_objects(delta: float):
    # Update onions
    for onion in rebellious_ingredients:
        if is_instance_valid(onion):
            var dir = (monster_chef.global_position - onion.global_position).normalized()
            onion.global_position += dir * 60 * delta
            
            # Onion rolling animation
            var sprite = onion.get_node_or_null("OnionSprite")
            if sprite:
                sprite.rotation += 3.0 * delta
    
    # Update cleavers
    for cleaver in flying_cleavers:
        if is_instance_valid(cleaver):
            var dir = cleaver.get_meta("direction", Vector2.RIGHT)
            cleaver.global_position += dir * 300 * delta
            cleaver.rotation += 8.0 * delta
    
    # Update spice
    for spice in spice_essences:
        if is_instance_valid(spice):
            var dir = (monster_chef.global_position - spice.global_position).normalized()
            spice.global_position += dir * 100 * delta

func hit_onion(onion: Area2D, weapon: Area2D):
    if weapon in flying_cleavers:
        var damage = weapon.get_meta("damage", 25)
        var health = onion.get_meta("health", 30) - damage
        onion.set_meta("health", health)
        
        # Flash effect
        var sprite = onion.get_node_or_null("OnionSprite")
        if sprite:
            sprite.modulate = Color.RED
            create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.2)
        
        if health <= 0:
            chop_onion(onion)
        
        flying_cleavers.erase(weapon)
        weapon.queue_free()

func chop_onion(onion: Area2D):
    var xp = onion.get_meta("xp", 10)
    
    # Spawn spice essence
    var spice = spice_template.duplicate()
    add_child(spice)
    spice.global_position = onion.global_position
    spice.set_meta("xp", xp)
    spice.show()
    spice_essences.append(spice)
    
    # Update stats
    ingredients_chopped += 1
    appetite += xp
    
    # CHECK FOR LEVEL UP - THE KEY MOMENT!
    if appetite >= appetite_required:
        level_up()
    
    rebellious_ingredients.erase(onion)
    onion.queue_free()
    
    update_ui()
    print("🍴 Onion chopped! +%d XP" % xp)

func _on_spice_collected(area: Area2D):
    if area in spice_essences:
        var xp = area.get_meta("xp", 5)
        appetite += xp
        
        if appetite >= appetite_required:
            level_up()
        
        spice_essences.erase(area)
        area.queue_free()
        update_ui()

func level_up():
    """THE MAIN EVENT - Level up with 3-choose-1 upgrade system!"""
    monster_level += 1
    appetite = 0
    appetite_required = int(appetite_required * 1.4)
    
    print("🎉 LEVEL UP! Level %d reached!" % monster_level)
    print("🎰 PRESENTING UPGRADE CHOICES - THE SLOT MACHINE EFFECT!")
    
    # Show the 3-choose-1 upgrade UI!
    show_upgrade_choices()
    
    update_ui()

func show_upgrade_choices():
    """Present 3 random upgrade choices - PRD's addictive mechanic!"""
    # Generate 3 random upgrade options
    upgrade_options.shuffle()
    current_upgrade_choices = [
        upgrade_options[0],
        upgrade_options[1],
        upgrade_options[2]
    ]
    
    # Update UI
    upgrade_title.text = "🎉 CULINARY MASTERY UNLOCKED! 🎉\nLevel %d - Choose your evolution:" % monster_level
    
    option_a.text = current_upgrade_choices[0].name + "\n" + current_upgrade_choices[0].desc
    option_b.text = current_upgrade_choices[1].name + "\n" + current_upgrade_choices[1].desc
    option_c.text = current_upgrade_choices[2].name + "\n" + current_upgrade_choices[2].desc
    
    # Show panel with dramatic effect
    upgrade_panel.show()
    upgrade_panel.scale = Vector2(0.3, 0.3)
    upgrade_panel.modulate = Color(1, 1, 1, 0)
    
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(upgrade_panel, "scale", Vector2(1, 1), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
    tween.tween_property(upgrade_panel, "modulate", Color.WHITE, 0.3)
    
    # Pause game
    is_upgrading = true
    
    print("📜 Upgrade choices:")
    print("   A: %s" % current_upgrade_choices[0].name)
    print("   B: %s" % current_upgrade_choices[1].name)
    print("   C: %s" % current_upgrade_choices[2].name)

func select_upgrade(choice_index: int):
    """Player selects an upgrade - apply it and continue!"""
    var upgrade = current_upgrade_choices[choice_index]
    
    print("✨ UPGRADE SELECTED: %s" % upgrade.name)
    
    # Apply the upgrade effect
    apply_upgrade(upgrade)
    
    # Hide upgrade panel
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(upgrade_panel, "scale", Vector2(0.1, 0.1), 0.2)
    tween.tween_property(upgrade_panel, "modulate", Color(1, 1, 1, 0), 0.2)
    tween.finished.connect(func(): upgrade_panel.hide())
    
    # Resume game
    is_upgrading = false
    
    # Show upgrade flash effect
    show_upgrade_flash()

func apply_upgrade(upgrade: Dictionary):
    """Apply the selected upgrade to game stats"""
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

func show_upgrade_flash():
    """Show satisfying upgrade flash effect"""
    var flash = ColorRect.new()
    flash.color = Color(1, 1, 0, 0.4)
    flash.anchors_preset = Control.PRESET_FULL_RECT
    $UI.add_child(flash)
    
    var tween = create_tween()
    tween.tween_property(flash, "modulate", Color(1, 1, 0, 0), 0.6)
    tween.finished.connect(func(): flash.queue_free())
    
    print("🔥 CULINARY POWER SURGE! The chef grows stronger!")

func update_ui():
    chef_level_label.text = "🐉 Chef Level: %d" % monster_level
    appetite_bar.max_value = appetite_required
    appetite_bar.value = appetite
    appetite_label.text = "🔥 Appetite: %d/%d" % [appetite, appetite_required]
    ingredients_label.text = "🍴 Chopped: %d" % ingredients_chopped
    
    var power_desc = "Novice Chef"
    if monster_level >= 5:
        power_desc = "Master Chef"
    elif monster_level >= 3:
        power_desc = "Skilled Chef"
    power_label.text = "⚡ Power: %s" % power_desc

func spawn_initial_ingredients():
    for i in range(3):
        spawn_onion()

func cleanup():
    rebellious_ingredients = rebellious_ingredients.filter(func(obj): return is_instance_valid(obj))
    flying_cleavers = flying_cleavers.filter(func(obj): return is_instance_valid(obj))
    spice_essences = spice_essences.filter(func(obj): return is_instance_valid(obj))

func _input(event):
    if event.is_action_pressed("ui_accept"):
        for i in range(5):
            spawn_onion()
    
    if event.is_action_pressed("ui_select"):
        level_up()  # Test the upgrade system!
    
    # Keyboard shortcuts for upgrades
    if is_upgrading:
        if event.is_action_pressed("move_left"):
            select_upgrade(0)
        elif event.is_action_pressed("move_up"):
            select_upgrade(1)
        elif event.is_action_pressed("move_right"):
            select_upgrade(2)