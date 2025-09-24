# upgrade_screen.gd
extends CanvasLayer

@export var upgrade_card_scene: PackedScene
# For now, we'll use a simple array of possible upgrades.
# In a real game, this would come from a more complex system.
@export var available_upgrades: Array[Resource]

@onready var card_container: HBoxContainer = $MarginContainer/CardContainer

func _ready() -> void:
    # Hide until needed
    hide()
    # Listen for the level up event
    EventBus.subscribe("player_leveled_up", show_options)

func show_options() -> void:
    # Clear any previous options
    for child in card_container.get_children():
        child.queue_free()

    # Get 3 unique random upgrades
    var choices = get_random_upgrades(3)
    if choices.is_empty():
        # No upgrades available, just unpause
        get_tree().paused = false
        return

    for upgrade_data in choices:
        var card = upgrade_card_scene.instantiate()
        card_container.add_child(card)
        card.set_upgrade_data(upgrade_data)
        card.chosen.connect(_on_upgrade_chosen)
    
    show()

func get_random_upgrades(count: int) -> Array:
    var selected_upgrades = []
    var available_copy = available_upgrades.duplicate()
    available_copy.shuffle()
    
    for i in range(min(count, available_copy.size())):
        selected_upgrades.append(available_copy[i])
        
    return selected_upgrades

func _on_upgrade_chosen(upgrade_data) -> void:
    # Here you would have logic to apply the upgrade to the player
    # For example: Player.add_weapon(upgrade_data) or Player.apply_passive_effect(upgrade_data)
    print("Player chose upgrade: ", upgrade_data.resource_name)

    # Hide the screen and unpause the game
    hide()
    get_tree().paused = false
