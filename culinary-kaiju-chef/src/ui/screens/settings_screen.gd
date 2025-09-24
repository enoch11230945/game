extends CanvasLayer

@onready var master_slider = $CenterContainer/VBoxContainer/MasterSlider
@onready var music_slider = $CenterContainer/VBoxContainer/MusicSlider
@onready var sfx_slider = $CenterContainer/VBoxContainer/SfxSlider
@onready var back_button = $CenterContainer/VBoxContainer/BackButton

var master_bus_idx: int
var music_bus_idx: int
var sfx_bus_idx: int

func _ready():
    hide()

    # Initialize audio bus indices with safety checks - FIX: Check if buses exist first
    master_bus_idx = AudioServer.get_bus_index("Master")
    music_bus_idx = AudioServer.get_bus_index("Music")
    sfx_bus_idx = AudioServer.get_bus_index("SFX")

    # Set default slider values (avoid errors if buses don't exist)
    if master_bus_idx >= 0:
        master_slider.value = AudioServer.get_bus_volume_db(master_bus_idx)
    else:
        master_slider.value = 0.0  # Default volume
        print("WARNING: Master audio bus not found, using default volume")

    if music_bus_idx >= 0:
        music_slider.value = AudioServer.get_bus_volume_db(music_bus_idx)
    else:
        music_slider.value = 0.0  # Default volume
        print("WARNING: Music audio bus not found, using default volume")

    if sfx_bus_idx >= 0:
        sfx_slider.value = AudioServer.get_bus_volume_db(sfx_bus_idx)
    else:
        sfx_slider.value = 0.0  # Default volume
        print("WARNING: SFX audio bus not found, using default volume")

    master_slider.value_changed.connect(_on_master_slider_changed)
    music_slider.value_changed.connect(_on_music_slider_changed)
    sfx_slider.value_changed.connect(_on_sfx_slider_changed)
    back_button.pressed.connect(_on_back_button_pressed)

func show_screen():
    show()
    # Refresh slider values when showing
    if master_bus_idx >= 0:
        master_slider.value = AudioServer.get_bus_volume_db(master_bus_idx)
    if music_bus_idx >= 0:
        music_slider.value = AudioServer.get_bus_volume_db(music_bus_idx)
    if sfx_bus_idx >= 0:
        sfx_slider.value = AudioServer.get_bus_volume_db(sfx_bus_idx)

func _on_master_slider_changed(value: float):
    if master_bus_idx >= 0:
        AudioServer.set_bus_volume_db(master_bus_idx, value)

func _on_music_slider_changed(value: float):
    if music_bus_idx >= 0:
        AudioServer.set_bus_volume_db(music_bus_idx, value)

func _on_sfx_slider_changed(value: float):
    if sfx_bus_idx >= 0:
        AudioServer.set_bus_volume_db(sfx_bus_idx, value)

func _on_back_button_pressed():
    hide()