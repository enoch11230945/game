# ItemData.gd
extends Resource
class_name ItemData

enum ItemType { PASSIVE, WEAPON_UPGRADE }

@export var type: ItemType = ItemType.PASSIVE
@export var description: String = ""
# Add other common properties for items
