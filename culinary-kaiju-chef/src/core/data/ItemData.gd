# ItemData.gd
extends Resource
class_name ItemData

@export var name: String = "Item"
@export var description: String = ""
@export var icon: Texture2D
@export var rarity: Rarity = Rarity.COMMON

# Item effects - these will be processed by the upgrade system
@export var stat_modifiers: Dictionary = {} # e.g., {"damage": 1.1, "speed": 1.05}
@export var special_effects: Array[String] = [] # e.g., ["poison", "freeze", "explode"]

enum Rarity {
    COMMON,
    UNCOMMON,
    RARE,
    EPIC,
    LEGENDARY
}

func get_rarity_color() -> Color:
    match rarity:
        Rarity.COMMON:
            return Color.WHITE
        Rarity.UNCOMMON:
            return Color.GREEN
        Rarity.RARE:
            return Color.BLUE
        Rarity.EPIC:
            return Color.PURPLE
        Rarity.LEGENDARY:
            return Color.ORANGE
        _:
            return Color.WHITE