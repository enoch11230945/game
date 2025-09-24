extends PanelContainer

signal selected(upgrade_data)

var upgrade_data

func _ready():
    # Connect to button press instead of gui input
    $MarginContainer/VBoxContainer/Button.pressed.connect(_on_button_pressed)

func set_data(data):
    self.upgrade_data = data
    $MarginContainer/VBoxContainer/NameLabel.text = upgrade_data.name
    $MarginContainer/VBoxContainer/DescriptionLabel.text = upgrade_data.description
    # $MarginContainer/VBoxContainer/TextureRect.texture = load(upgrade_data.icon_path)

func _on_button_pressed():
    emit_signal("selected", upgrade_data)
