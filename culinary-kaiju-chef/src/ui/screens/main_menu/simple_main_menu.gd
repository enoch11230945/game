# Simple Main Menu - Linus Approved Architecture
extends Control

@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready():
    new_game_button.pressed.connect(_on_new_game_pressed)
    options_button.pressed.connect(_on_options_pressed)
    quit_button.pressed.connect(_on_quit_pressed)
    
    # Set focus on the new game button
    new_game_button.grab_focus()
    
    # Connect events
    EventBus.game_started.connect(_on_game_started)

func _on_new_game_pressed():
    print("🎯 Starting Culinary Kaiju Chef - Linus Approved!")
    EventBus.game_started.emit()
    # Use clean main scene
    SceneLoader.load_scene("res://src/main/clean_main.tscn")

func _on_options_pressed():
    print("Options menu not implemented yet")

func _on_quit_pressed():
    get_tree().quit()

func _on_game_started():
    print("Game starting from main menu")