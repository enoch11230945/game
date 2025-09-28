# LINUS_EPIC2_META_PROGRESSION.gd - Complete Epic 2 implementation
# "Epic 2: 長期留存系統 - Meta-progression and character unlocks"
extends Control

# === META PROGRESSION SYSTEM ===
var total_gold: int = 0
var meta_upgrades: Dictionary = {
    "damage_bonus": 0,
    "health_bonus": 0,
    "speed_bonus": 0,
    "xp_bonus": 0,
    "luck_bonus": 0
}

var unlocked_characters: Array[String] = ["chef"]
var available_characters: Dictionary = {
    "chef": {"name": "Monster Chef", "cost": 0, "unlocked": true},
    "baker": {"name": "Kaiju Baker", "cost": 100, "unlocked": false},
    "butcher": {"name": "Demon Butcher", "cost": 250, "unlocked": false},
    "barista": {"name": "Giant Barista", "cost": 500, "unlocked": false}
}

var selected_character: String = "chef"

# UI Elements
var gold_label: Label
var upgrade_container: VBoxContainer
var character_container: HBoxContainer
var play_button: Button
var back_button: Button

func _ready():
    print("💰 LINUS EPIC 2 - Meta Progression System")
    print("Permanent upgrades, character unlocks, and save system")
    
    setup_ui()
    load_save_data()
    update_display()
    
    print("✅ Meta progression system ready!")

func setup_ui():
    """Create the meta progression UI"""
    # Set background
    var background = ColorRect.new()
    background.color = Color(0.1, 0.1, 0.2, 1.0)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)
    
    # Main container
    var main_vbox = VBoxContainer.new()
    main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    main_vbox.add_theme_constant_override("separation", 20)
    add_child(main_vbox)
    
    # Title
    var title = Label.new()
    title.text = "🏠 META PROGRESSION HUB"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 32)
    title.add_theme_color_override("font_color", Color.GOLD)
    main_vbox.add_child(title)
    
    # Gold display
    gold_label = Label.new()
    gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    gold_label.add_theme_font_size_override("font_size", 24)
    gold_label.add_theme_color_override("font_color", Color.YELLOW)
    main_vbox.add_child(gold_label)
    
    # Upgrades section
    var upgrades_title = Label.new()
    upgrades_title.text = "💪 PERMANENT UPGRADES"
    upgrades_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    upgrades_title.add_theme_font_size_override("font_size", 20)
    upgrades_title.add_theme_color_override("font_color", Color.CYAN)
    main_vbox.add_child(upgrades_title)
    
    upgrade_container = VBoxContainer.new()
    upgrade_container.add_theme_constant_override("separation", 10)
    main_vbox.add_child(upgrade_container)
    
    # Characters section
    var chars_title = Label.new()
    chars_title.text = "👹 CHARACTER SELECTION"
    chars_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    chars_title.add_theme_font_size_override("font_size", 20)
    chars_title.add_theme_color_override("font_color", Color.GREEN)
    main_vbox.add_child(chars_title)
    
    character_container = HBoxContainer.new()
    character_container.alignment = BoxContainer.ALIGNMENT_CENTER
    character_container.add_theme_constant_override("separation", 20)
    main_vbox.add_child(character_container)
    
    # Buttons
    var button_hbox = HBoxContainer.new()
    button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    button_hbox.add_theme_constant_override("separation", 20)
    main_vbox.add_child(button_hbox)
    
    # Play button
    play_button = Button.new()
    play_button.text = "🎮 START GAME"
    play_button.add_theme_font_size_override("font_size", 20)
    play_button.pressed.connect(_on_play_pressed)
    button_hbox.add_child(play_button)
    
    # Back button
    back_button = Button.new()
    back_button.text = "⬅️ BACK"
    back_button.add_theme_font_size_override("font_size", 16)
    back_button.pressed.connect(_on_back_pressed)
    button_hbox.add_child(back_button)
    
    # Test gold button
    var test_gold_button = Button.new()
    test_gold_button.text = "💰 +100 Test Gold"
    test_gold_button.pressed.connect(_on_test_gold_pressed)
    button_hbox.add_child(test_gold_button)
    
    create_upgrade_buttons()
    create_character_buttons()

func create_upgrade_buttons():
    """Create upgrade buttons for each stat"""
    var upgrade_info = {
        "damage_bonus": {"name": "💥 Damage Bonus", "desc": "+10% damage per level", "base_cost": 50},
        "health_bonus": {"name": "❤️ Health Bonus", "desc": "+20 HP per level", "base_cost": 75},
        "speed_bonus": {"name": "💨 Speed Bonus", "desc": "+8% speed per level", "base_cost": 60},
        "xp_bonus": {"name": "⭐ XP Bonus", "desc": "+15% XP per level", "base_cost": 100},
        "luck_bonus": {"name": "🍀 Luck Bonus", "desc": "+10% rare drops per level", "base_cost": 150}
    }
    
    for upgrade_id in upgrade_info:
        var info = upgrade_info[upgrade_id]
        var current_level = meta_upgrades.get(upgrade_id, 0)
        var cost = calculate_upgrade_cost(info.base_cost, current_level)
        
        var hbox = HBoxContainer.new()
        upgrade_container.add_child(hbox)
        
        # Upgrade info
        var info_label = Label.new()
        info_label.text = "%s (Lv.%d) - %s" % [info.name, current_level, info.desc]
        info_label.custom_minimum_size.x = 400
        hbox.add_child(info_label)
        
        # Cost and button
        var cost_label = Label.new()
        cost_label.text = "Cost: %d gold" % cost
        cost_label.add_theme_color_override("font_color", Color.YELLOW)
        hbox.add_child(cost_label)
        
        var upgrade_btn = Button.new()
        upgrade_btn.text = "UPGRADE"
        upgrade_btn.disabled = total_gold < cost or current_level >= 10
        upgrade_btn.pressed.connect(_on_upgrade_pressed.bind(upgrade_id))
        hbox.add_child(upgrade_btn)

func create_character_buttons():
    """Create character selection buttons"""
    for char_id in available_characters:
        var char_data = available_characters[char_id]
        
        var vbox = VBoxContainer.new()
        vbox.add_theme_constant_override("separation", 5)
        character_container.add_child(vbox)
        
        # Character display
        var char_display = Panel.new()
        char_display.custom_minimum_size = Vector2(120, 120)
        if char_data.unlocked:
            char_display.modulate = Color.WHITE if char_id == selected_character else Color.GRAY
        else:
            char_display.modulate = Color(0.3, 0.3, 0.3, 1.0)
        vbox.add_child(char_display)
        
        # Character icon (placeholder)
        var icon_label = Label.new()
        icon_label.text = get_character_icon(char_id)
        icon_label.add_theme_font_size_override("font_size", 48)
        icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        icon_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        char_display.add_child(icon_label)
        
        # Character name
        var name_label = Label.new()
        name_label.text = char_data.name
        name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        name_label.add_theme_font_size_override("font_size", 12)
        vbox.add_child(name_label)
        
        # Select/Unlock button
        var char_button = Button.new()
        if char_data.unlocked:
            if char_id == selected_character:
                char_button.text = "SELECTED"
                char_button.disabled = true
            else:
                char_button.text = "SELECT"
                char_button.pressed.connect(_on_character_selected.bind(char_id))
        else:
            char_button.text = "UNLOCK (%d gold)" % char_data.cost
            char_button.disabled = total_gold < char_data.cost
            char_button.pressed.connect(_on_character_unlock.bind(char_id))
        
        vbox.add_child(char_button)

func get_character_icon(char_id: String) -> String:
    """Get emoji icon for character"""
    match char_id:
        "chef": return "👨‍🍳"
        "baker": return "🧑‍🍳"
        "butcher": return "🔪"
        "barista": return "☕"
        _: return "❓"

func calculate_upgrade_cost(base_cost: int, current_level: int) -> int:
    """Calculate exponential upgrade cost"""
    return int(base_cost * pow(1.5, current_level))

func _on_upgrade_pressed(upgrade_id: String):
    """Handle upgrade purchase"""
    var base_costs = {
        "damage_bonus": 50,
        "health_bonus": 75,
        "speed_bonus": 60,
        "xp_bonus": 100,
        "luck_bonus": 150
    }
    
    var current_level = meta_upgrades.get(upgrade_id, 0)
    var cost = calculate_upgrade_cost(base_costs[upgrade_id], current_level)
    
    if total_gold >= cost and current_level < 10:
        total_gold -= cost
        meta_upgrades[upgrade_id] = current_level + 1
        save_data()
        update_display()
        print("⬆️ Upgraded %s to level %d" % [upgrade_id, meta_upgrades[upgrade_id]])

func _on_character_selected(char_id: String):
    """Handle character selection"""
    selected_character = char_id
    save_data()
    update_display()
    print("👹 Selected character: %s" % available_characters[char_id].name)

func _on_character_unlock(char_id: String):
    """Handle character unlock"""
    var char_data = available_characters[char_id]
    
    if total_gold >= char_data.cost:
        total_gold -= char_data.cost
        char_data.unlocked = true
        unlocked_characters.append(char_id)
        save_data()
        update_display()
        print("🔓 Unlocked character: %s" % char_data.name)

func _on_play_pressed():
    """Start game with selected character and upgrades"""
    print("🎮 Starting game with %s" % available_characters[selected_character].name)
    print("💪 Active upgrades:")
    for upgrade_id in meta_upgrades:
        var level = meta_upgrades[upgrade_id]
        if level > 0:
            print("  %s: Level %d" % [upgrade_id, level])
    
    # Switch to main game (would load Epic 1 implementation)
    get_tree().change_scene_to_file("res://LINUS_EPIC1_COMPLETE.tscn")

func _on_back_pressed():
    """Go back to main menu"""
    print("⬅️ Returning to main menu")
    # Would go to main menu scene
    get_tree().quit()

func _on_test_gold_pressed():
    """Add test gold for testing"""
    total_gold += 100
    save_data()
    update_display()
    print("💰 Added 100 test gold (Total: %d)" % total_gold)

func update_display():
    """Update all UI elements"""
    gold_label.text = "💰 Gold: %d" % total_gold
    
    # Clear and recreate upgrade buttons
    for child in upgrade_container.get_children():
        child.queue_free()
    
    for child in character_container.get_children():
        child.queue_free()
    
    # Wait a frame then recreate
    await get_tree().process_frame
    create_upgrade_buttons()
    create_character_buttons()

func save_data():
    """Save meta progression data"""
    var save_data = {
        "total_gold": total_gold,
        "meta_upgrades": meta_upgrades,
        "unlocked_characters": unlocked_characters,
        "selected_character": selected_character,
        "save_version": "1.0.0"
    }
    
    var file = FileAccess.open("user://meta_progression.save", FileAccess.WRITE)
    if file:
        var json_string = JSON.stringify(save_data)
        file.store_string(json_string)
        file.close()
        print("💾 Meta progression saved")
    else:
        print("❌ Failed to save meta progression")

func load_save_data():
    """Load meta progression data"""
    if FileAccess.file_exists("user://meta_progression.save"):
        var file = FileAccess.open("user://meta_progression.save", FileAccess.READ)
        if file:
            var json_string = file.get_as_text()
            file.close()
            
            var json = JSON.new()
            var parse_result = json.parse(json_string)
            
            if parse_result == OK:
                var data = json.data
                total_gold = data.get("total_gold", 0)
                meta_upgrades = data.get("meta_upgrades", meta_upgrades)
                unlocked_characters = data.get("unlocked_characters", ["chef"])
                selected_character = data.get("selected_character", "chef")
                
                # Update character unlock status
                for char_id in unlocked_characters:
                    if available_characters.has(char_id):
                        available_characters[char_id].unlocked = true
                
                print("✅ Meta progression loaded")
            else:
                print("⚠️ Failed to parse save file")
        else:
            print("⚠️ Failed to open save file")
    else:
        print("💾 No save file found, starting fresh")
        # Give some starting gold for testing
        total_gold = 200

func _input(event):
    """Handle input"""
    if event.is_action_pressed("ui_cancel"):
        _on_back_pressed()
    
    if event.is_action_pressed("ui_accept"):
        print("=== EPIC 2 STATUS ===")
        print("Total Gold: %d" % total_gold)
        print("Meta Upgrades:")
        for upgrade in meta_upgrades:
            print("  %s: Level %d" % [upgrade, meta_upgrades[upgrade]])
        print("Unlocked Characters: %s" % unlocked_characters)
        print("Selected Character: %s" % selected_character)
        print("====================")

# === INTEGRATION WITH EPIC 1 ===
func apply_meta_bonuses_to_game_stats(base_stats: Dictionary) -> Dictionary:
    """Apply meta progression bonuses to game stats"""
    var boosted_stats = base_stats.duplicate()
    
    # Apply damage bonus
    var damage_mult = 1.0 + (meta_upgrades.get("damage_bonus", 0) * 0.1)
    boosted_stats["damage"] = int(boosted_stats.get("damage", 25) * damage_mult)
    
    # Apply health bonus
    var health_bonus = meta_upgrades.get("health_bonus", 0) * 20
    boosted_stats["max_health"] = boosted_stats.get("max_health", 100) + health_bonus
    
    # Apply speed bonus
    var speed_mult = 1.0 + (meta_upgrades.get("speed_bonus", 0) * 0.08)
    boosted_stats["speed"] = boosted_stats.get("speed", 250) * speed_mult
    
    # Apply XP bonus
    var xp_mult = 1.0 + (meta_upgrades.get("xp_bonus", 0) * 0.15)
    boosted_stats["xp_multiplier"] = xp_mult
    
    # Apply luck bonus
    var luck_mult = 1.0 + (meta_upgrades.get("luck_bonus", 0) * 0.1)
    boosted_stats["luck_multiplier"] = luck_mult
    
    return boosted_stats

func get_character_starting_stats(character_id: String) -> Dictionary:
    """Get character-specific starting stats"""
    match character_id:
        "chef":
            return {"damage": 25, "max_health": 100, "speed": 250, "special": "balanced"}
        "baker":
            return {"damage": 20, "max_health": 120, "speed": 220, "special": "tank"}
        "butcher":
            return {"damage": 35, "max_health": 80, "speed": 280, "special": "glass_cannon"}
        "barista":
            return {"damage": 22, "max_health": 90, "speed": 300, "special": "speed_demon"}
        _:
            return {"damage": 25, "max_health": 100, "speed": 250, "special": "balanced"}