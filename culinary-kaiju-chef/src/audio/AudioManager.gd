# AudioManager.gd - Professional audio system (Linus approved)
extends Node

# === AUDIO PLAYERS ===
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var ui_player: AudioStreamPlayer = $UIPlayer

# === AUDIO LIBRARIES ===
var music_library: Dictionary = {}
var sfx_library: Dictionary = {}
var ui_sounds: Dictionary = {}

# === SETTINGS ===
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var ui_volume: float = 0.6

# === STATE ===
var current_music: String = ""
var is_music_fading: bool = false

func _ready() -> void:
    print("🔊 AudioManager initialized - Professional audio system")
    _setup_audio_players()
    _load_audio_libraries()
    
    # Connect to events
    EventBus.play_sound.connect(_on_play_sound)
    EventBus.play_music.connect(_on_play_music)
    EventBus.stop_music.connect(_on_stop_music)

func _setup_audio_players() -> void:
    """Setup audio players with proper buses"""
    # Create audio players if they don't exist
    if not music_player:
        music_player = AudioStreamPlayer.new()
        music_player.name = "MusicPlayer"
        music_player.bus = "Music"
        add_child(music_player)
    
    if not sfx_player:
        sfx_player = AudioStreamPlayer.new()
        sfx_player.name = "SFXPlayer"
        sfx_player.bus = "SFX"
        add_child(sfx_player)
    
    if not ui_player:
        ui_player = AudioStreamPlayer.new()
        ui_player.name = "UIPlayer"
        ui_player.bus = "UI"
        add_child(ui_player)
    
    # Set volumes
    music_player.volume_db = linear_to_db(music_volume)
    sfx_player.volume_db = linear_to_db(sfx_volume)
    ui_player.volume_db = linear_to_db(ui_volume)

func _load_audio_libraries() -> void:
    """Load audio resources into libraries"""
    # Music library (would normally scan assets/audio/music/)
    music_library["menu"] = preload("res://assets/audio/music/menu_theme.ogg")
    music_library["game"] = preload("res://assets/audio/music/battle_theme.ogg")
    music_library["boss"] = preload("res://assets/audio/music/boss_theme.ogg")
    
    # SFX library (would normally scan assets/audio/sfx/)
    sfx_library["hit"] = preload("res://assets/audio/sfx/hit.wav")
    sfx_library["enemy_death"] = preload("res://assets/audio/sfx/enemy_death.wav")
    sfx_library["weapon_fire"] = preload("res://assets/audio/sfx/weapon_fire.wav")
    sfx_library["pickup_xp"] = preload("res://assets/audio/sfx/pickup_xp.wav")
    sfx_library["level_up"] = preload("res://assets/audio/sfx/level_up.wav")
    sfx_library["upgrade_select"] = preload("res://assets/audio/sfx/upgrade_select.wav")
    
    # UI sounds
    ui_sounds["button_hover"] = preload("res://assets/audio/ui/button_hover.wav")
    ui_sounds["button_click"] = preload("res://assets/audio/ui/button_click.wav")
    ui_sounds["menu_open"] = preload("res://assets/audio/ui/menu_open.wav")
    ui_sounds["menu_close"] = preload("res://assets/audio/ui/menu_close.wav")
    
    print("✅ Audio libraries loaded: %d music, %d sfx, %d ui" % [
        music_library.size(), sfx_library.size(), ui_sounds.size()
    ])

# === MUSIC SYSTEM ===

func play_music(track_name: String, fade_in: bool = true) -> void:
    """Play background music with optional fade in"""
    if not music_library.has(track_name):
        print("⚠️ Music track not found: %s" % track_name)
        return
    
    var new_track = music_library[track_name]
    
    if current_music == track_name and music_player.playing:
        return  # Already playing this track
    
    current_music = track_name
    
    if fade_in and music_player.playing:
        _fade_to_new_music(new_track)
    else:
        music_player.stream = new_track
        music_player.play()

func _fade_to_new_music(new_stream: AudioStream) -> void:
    """Fade out current music and fade in new music"""
    if is_music_fading:
        return
    
    is_music_fading = true
    var original_volume = music_player.volume_db
    
    # Fade out
    var tween = create_tween()
    tween.tween_property(music_player, "volume_db", -80.0, 1.0)
    tween.tween_callback(_start_new_music.bind(new_stream, original_volume))

func _start_new_music(new_stream: AudioStream, target_volume: float) -> void:
    """Start new music after fade out"""
    music_player.stream = new_stream
    music_player.play()
    
    # Fade in
    var tween = create_tween()
    tween.tween_property(music_player, "volume_db", target_volume, 1.0)
    tween.tween_callback(func(): is_music_fading = false)

func stop_music(fade_out: bool = true) -> void:
    """Stop background music with optional fade out"""
    if fade_out and music_player.playing:
        var tween = create_tween()
        tween.tween_property(music_player, "volume_db", -80.0, 1.0)
        tween.tween_callback(music_player.stop)
        tween.tween_callback(func(): music_player.volume_db = linear_to_db(music_volume))
    else:
        music_player.stop()
    
    current_music = ""

# === SFX SYSTEM ===

func play_sfx(sound_name: String, volume_modifier: float = 1.0, pitch_modifier: float = 1.0) -> void:
    """Play sound effect with optional volume and pitch modification"""
    if not sfx_library.has(sound_name):
        print("⚠️ SFX not found: %s" % sound_name)
        return
    
    var sound = sfx_library[sound_name]
    
    # Create temporary player for overlapping sounds
    var temp_player = AudioStreamPlayer.new()
    temp_player.bus = "SFX"
    temp_player.stream = sound
    temp_player.volume_db = linear_to_db(sfx_volume * volume_modifier)
    temp_player.pitch_scale = pitch_modifier
    
    add_child(temp_player)
    temp_player.play()
    
    # Auto-cleanup when finished
    temp_player.finished.connect(temp_player.queue_free)

func play_ui_sound(sound_name: String) -> void:
    """Play UI sound effect"""
    if not ui_sounds.has(sound_name):
        print("⚠️ UI sound not found: %s" % sound_name)
        return
    
    ui_player.stream = ui_sounds[sound_name]
    ui_player.play()

# === RANDOM AUDIO SYSTEM ===

func play_random_sfx(sound_names: Array[String], volume_modifier: float = 1.0) -> void:
    """Play random sound from array"""
    if sound_names.is_empty():
        return
    
    var random_sound = sound_names[randi() % sound_names.size()]
    var pitch_variation = randf_range(0.9, 1.1)  # Add slight pitch variation
    play_sfx(random_sound, volume_modifier, pitch_variation)

# === VOLUME CONTROL ===

func set_master_volume(volume: float) -> void:
    """Set master volume (0.0 to 1.0)"""
    master_volume = clamp(volume, 0.0, 1.0)
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))

func set_music_volume(volume: float) -> void:
    """Set music volume (0.0 to 1.0)"""
    music_volume = clamp(volume, 0.0, 1.0)
    if music_player:
        music_player.volume_db = linear_to_db(music_volume)

func set_sfx_volume(volume: float) -> void:
    """Set SFX volume (0.0 to 1.0)"""
    sfx_volume = clamp(volume, 0.0, 1.0)

func set_ui_volume(volume: float) -> void:
    """Set UI volume (0.0 to 1.0)"""
    ui_volume = clamp(volume, 0.0, 1.0)
    if ui_player:
        ui_player.volume_db = linear_to_db(ui_volume)

# === EVENT HANDLERS ===

func _on_play_sound(sound_name: String) -> void:
    """Handle play sound event"""
    play_sfx(sound_name)

func _on_play_music(track_name: String) -> void:
    """Handle play music event"""
    play_music(track_name)

func _on_stop_music() -> void:
    """Handle stop music event"""
    stop_music()

# === CONVENIENCE FUNCTIONS ===

func play_weapon_hit() -> void:
    """Play weapon hit sound with variation"""
    play_random_sfx(["hit"], 0.8)

func play_enemy_death() -> void:
    """Play enemy death sound"""
    play_sfx("enemy_death", 1.0)

func play_pickup_sound() -> void:
    """Play item pickup sound"""
    play_sfx("pickup_xp", 0.6)

func play_level_up_sound() -> void:
    """Play level up sound"""
    play_sfx("level_up", 1.2)