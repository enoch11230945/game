extends CanvasLayer

signal upgrade_selected(upgrade_data)

@onready var card_container = $MarginContainer/VBoxContainer/CardContainer

const UpgradeCardScene = preload("res://src/ui/components/upgrade_card.tscn")

func _ready():
    hide() # Hidden by default

func show_upgrades(upgrades: Array):
    # Clear previous cards
    for child in card_container.get_children():
        child.queue_free()

    # Create a new card for each upgrade option
    for upgrade_data in upgrades:
        var card = UpgradeCardScene.instantiate()
        card_container.add_child(card)
        card.set_data(upgrade_data)
        card.selected.connect(_on_upgrade_card_selected)
    
    get_tree().paused = true
    show()

func _on_upgrade_card_selected(upgrade_data):
    # Hide the screen, unpause the game, and emit the final signal
    hide()
    get_tree().paused = false
    emit_signal("upgrade_selected", upgrade_data)
