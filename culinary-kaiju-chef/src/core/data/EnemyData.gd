extends Resource
class_name EnemyData

@export var scene: PackedScene
@export var scene_path: String
@export var health: int = 10
@export var speed: float = 100.0
@export var damage: int = 5
@export var xp_value: int = 10

func get_scene() -> PackedScene:
    if scene:
        return scene
    elif scene_path:
        return load(scene_path)
    return null