# upgrade_card.gd
extends PanelContainer

# Signal emitted when the card is chosen by the player.
# We will pass the upgrade data resource back.
signal chosen(upgrade)

@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var description_label: Label = $MarginContainer/VBoxContainer/DescriptionLabel

var upgrade_data

func _ready() -> void:
    # Make the container clickable
    gui_input.connect(_on_gui_input)

func set_upgrade_data(data) -> void:
    self.upgrade_data = data
    # Assuming the data is a Resource with 'name' and 'description' properties
    # (like WeaponData or ItemData)
    name_label.text = upgrade_data.get("name", "Unnamed Upgrade")
    description_label.text = upgrade_data.get("description", "No description.")

func _on_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
        chosen.emit(upgrade_data)