# UpgradeSelectionScreen.gd - Data-driven upgrade selection (Linus approved)
extends Control
class_name UpgradeSelectionScreen

@onready var upgrade_cards_container: HBoxContainer = $VBox/UpgradeCards
@onready var level_label: Label = $VBox/Header/LevelLabel
@onready var close_button: Button = $VBox/Header/CloseButton

var current_upgrade_options: Array[Resource] = []
var upgrade_card_scene: PackedScene

func _ready() -> void:
    # Load upgrade card scene
    upgrade_card_scene = preload("res://src/ui/components/UpgradeCard.tscn")
    
    # Connect events
    EventBus.level_up_screen_opened.connect(_on_level_up_screen_opened)
    close_button.pressed.connect(_on_close_pressed)
    
    # Initially hidden
    hide()

func _on_level_up_screen_opened() -> void:
    """Show upgrade selection when player levels up"""
    _generate_upgrade_options()
    _display_upgrade_options()
    show()
    
    # Update level display
    level_label.text = "LEVEL %d!" % Game.player_level

func _generate_upgrade_options() -> void:
    """Generate 3 random upgrade options"""
    current_upgrade_options.clear()
    
    # Get available upgrades from UpgradeManager
    var available_upgrades = UpgradeManager.get_available_upgrades()
    
    # Select 3 random options
    var options_count = min(3, available_upgrades.size())
    for i in range(options_count):
        var random_upgrade = available_upgrades[randi() % available_upgrades.size()]
        if not current_upgrade_options.has(random_upgrade):
            current_upgrade_options.append(random_upgrade)
        available_upgrades.erase(random_upgrade)

func _display_upgrade_options() -> void:
    """Display upgrade options as cards"""
    # Clear existing cards
    for child in upgrade_cards_container.get_children():
        child.queue_free()
    
    # Create cards for each option
    for i in range(current_upgrade_options.size()):
        var upgrade_data = current_upgrade_options[i]
        var card = upgrade_card_scene.instantiate()
        upgrade_cards_container.add_child(card)
        
        # Initialize card
        if card.has_method("setup"):
            card.setup(upgrade_data, i)
            card.selected.connect(_on_upgrade_selected)

func _on_upgrade_selected(upgrade_data: Resource, card_index: int) -> void:
    """Handle upgrade selection"""
    print("✅ Selected upgrade: %s" % upgrade_data.get("item_name", "Unknown"))
    
    # Apply upgrade
    UpgradeManager.apply_upgrade(upgrade_data)
    
    # Emit events
    EventBus.upgrade_selected.emit(upgrade_data)
    EventBus.level_up_screen_closed.emit()
    
    # Close screen and resume game
    hide()
    Game.resume_game()

func _on_close_pressed() -> void:
    """Handle close button (skip upgrade)"""
    print("⚠️ Upgrade skipped")
    
    # Close screen and resume game
    hide()
    Game.resume_game()

func _input(event: InputEvent) -> void:
    """Handle keyboard shortcuts"""
    if not visible:
        return
    
    if event.is_action_pressed("ui_cancel"):
        _on_close_pressed()
    elif event.is_action_pressed("ui_accept"):
        # Select first option
        if current_upgrade_options.size() > 0:
            _on_upgrade_selected(current_upgrade_options[0], 0)