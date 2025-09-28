# UpgradeCard.gd - Individual upgrade option display
extends Control
class_name UpgradeCard

@onready var card_button: Button = $CardButton
@onready var name_label: Label = $CardButton/VBox/NameLabel
@onready var description_label: Label = $CardButton/VBox/DescriptionLabel
@onready var icon_rect: TextureRect = $CardButton/VBox/IconRect

var upgrade_data: Resource
var card_index: int

signal selected(upgrade_data: Resource, card_index: int)

func _ready() -> void:
    card_button.pressed.connect(_on_card_pressed)

func setup(data: Resource, index: int) -> void:
    """Setup card with upgrade data"""
    upgrade_data = data
    card_index = index
    
    if upgrade_data:
        # Set name and description
        name_label.text = upgrade_data.upgrade_name if upgrade_data.upgrade_name else "Unknown"
        description_label.text = upgrade_data.description if upgrade_data.description else "No description"
        
        # Set icon if available
        if upgrade_data.icon_texture_path and not upgrade_data.icon_texture_path.is_empty() and icon_rect:
            var icon = load(upgrade_data.icon_texture_path)
            if icon:
                icon_rect.texture = icon
        
        # Color based on rarity
        var rarity = upgrade_data.rarity if upgrade_data.rarity else "COMMON"
        _set_card_color(rarity)

func _set_card_color(rarity: String) -> void:
    """Set card color based on rarity"""
    var color = Color.WHITE
    match rarity:
        "common":
            color = Color.LIGHT_GRAY
        "rare":
            color = Color.CORNFLOWER_BLUE
        "epic":
            color = Color.MEDIUM_PURPLE
        "legendary":
            color = Color.GOLD
    
    card_button.modulate = color

func _on_card_pressed() -> void:
    """Handle card selection"""
    selected.emit(upgrade_data, card_index)