class_name UpgradeData
extends Resource

@export var id: String
@export var upgrade_name: String
@export var description: String

# The key of the stat to be modified in PlayerData.modifiers
@export var target_stat: String 

# The value to multiply the modifier by (e.g., 1.1 for +10%)
@export var multiplier: float = 1.0
