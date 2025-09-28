# ArenaTimeManager.gd - Stub class for missing ArenaTimeManager
class_name ArenaTimeManager
extends Node

var time: float = 0.0

func _ready():
    set_process(true)

func _process(delta):
    time += delta

func get_time_elapsed() -> float:
    return time