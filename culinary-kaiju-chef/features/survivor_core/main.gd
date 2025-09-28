extends Node


@export var end_screen_scene: PackedScene

# Remove broken preload
# var paused_menu_scene = preload("res://scenes/ui/pause_menu.tscn")


func _ready():
	%Player.health_component.died.connect(on_player_died)



func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		# Create simple pause functionality without missing scene
		get_tree().paused = not get_tree().paused
		get_tree().root.set_input_as_handled()


func on_player_died():
	# Simplified without missing EndScreen class
	print("Player died - Game Over")
	# var end_screen_instance = end_screen_scene.instantiate() as EndScreen
	# add_child(end_screen_instance) 
	# end_screen_instance.set_defeat()
	PlayerData.save_game_data()
