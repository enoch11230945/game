extends CanvasLayer

@onready var start_button = $CenterContainer/VBoxContainer/StartButton
@onready var settings_button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton
@onready var settings_screen = $SettingsScreen

# FORCE CACHE INVALIDATION - MODIFIED AT: 2025-01-23 11:30:00 UTC
const GAME_SCENE = "res://src/main/main.tscn"

# ADDITIONAL DEBUG INFO FOR CACHE TESTING
const CACHE_TEST_STRING = "CACHE_INVALIDATED_2025_01_23_11_30"

func _ready():
    print("MAIN MENU READY!")
    print("Main menu scene loaded")
    start_button.pressed.connect(_on_start_button_pressed)
    settings_button.pressed.connect(_on_settings_button_pressed)
    quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed():
    print("START GAME BUTTON PRESSED!")
    print("Changing scene to:", GAME_SCENE)
    var result = get_tree().change_scene_to_file(GAME_SCENE)
    print("Scene change result:", result)
    if result != OK:
        print("ERROR: Failed to change scene!")
        print("Error code:", result)
    else:
        print("Scene change initiated successfully")

func _on_settings_button_pressed():
    settings_screen.show_screen()

func _on_quit_button_pressed():
    get_tree().quit()