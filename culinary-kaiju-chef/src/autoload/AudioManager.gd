# AudioManager.gd - Global audio management system
extends Node

# Audio sources
@onready var sfx_player: AudioStreamPlayer
@onready var music_player: AudioStreamPlayer

# Audio pools for performance
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_pool_size: int = 10
var current_sfx_index: int = 0

func _ready() -> void:
	# Create main players
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Master"
	add_child(music_player)
	
	# Create SFX pool
	for i in sfx_pool_size:
		var player = AudioStreamPlayer.new()
		player.name = "SFXPlayer_%d" % i
		player.bus = "Master"
		add_child(player)
		sfx_players.append(player)
	
	# Connect to EventBus
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.weapon_fired.connect(_on_weapon_fired)
	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	
	print("AudioManager initialized with %d SFX players" % sfx_pool_size)

func play_sfx(sound_name: String, volume: float = 0.0, pitch: float = 1.0) -> void:
	# Get next available SFX player
	var player = sfx_players[current_sfx_index]
	current_sfx_index = (current_sfx_index + 1) % sfx_pool_size
	
	# For now, create simple procedural sounds
	match sound_name:
		"enemy_hit":
			_play_procedural_hit(player, volume, pitch)
		"enemy_death":
			_play_procedural_death(player, volume, pitch)
		"weapon_fire":
			_play_procedural_fire(player, volume, pitch)
		"level_up":
			_play_procedural_levelup(player, volume, pitch)
		"pickup":
			_play_procedural_pickup(player, volume, pitch)
		_:
			print("Unknown sound: ", sound_name)

func _play_procedural_hit(player: AudioStreamPlayer, volume: float, pitch: float) -> void:
	# Create a simple hit sound using AudioStreamGenerator (if available)
	# For now, just play a short beep-like sound
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = 22050
	stream.buffer_length = 0.1
	player.stream = stream
	player.volume_db = volume
	player.pitch_scale = pitch * randf_range(0.8, 1.2)
	player.play()

func _play_procedural_death(player: AudioStreamPlayer, volume: float, pitch: float) -> void:
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = 22050
	stream.buffer_length = 0.2
	player.stream = stream
	player.volume_db = volume - 5.0
	player.pitch_scale = pitch * randf_range(0.5, 0.8)
	player.play()

func _play_procedural_fire(player: AudioStreamPlayer, volume: float, pitch: float) -> void:
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = 22050
	stream.buffer_length = 0.05
	player.stream = stream
	player.volume_db = volume + 2.0
	player.pitch_scale = pitch * randf_range(1.2, 1.8)
	player.play()

func _play_procedural_levelup(player: AudioStreamPlayer, volume: float, pitch: float) -> void:
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = 22050
	stream.buffer_length = 0.5
	player.stream = stream
	player.volume_db = volume
	player.pitch_scale = pitch
	player.play()

func _play_procedural_pickup(player: AudioStreamPlayer, volume: float, pitch: float) -> void:
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = 22050
	stream.buffer_length = 0.08
	player.stream = stream
	player.volume_db = volume + 5.0
	player.pitch_scale = pitch * randf_range(1.5, 2.0)
	player.play()

# Event handlers
func _on_enemy_killed() -> void:
	play_sfx("enemy_death", -10.0, 1.0)

func _on_weapon_fired() -> void:
	play_sfx("weapon_fire", -15.0, 1.0)

func _on_damage_dealt() -> void:
	play_sfx("enemy_hit", -12.0, 1.0)

func _on_player_leveled_up(_level: int) -> void:
	play_sfx("level_up", -5.0, 1.0)

func play_music(track_name: String, loop: bool = true) -> void:
	# For now, we don't have actual music files
	# This is a placeholder for future music implementation
	print("Playing music: ", track_name)

func stop_music() -> void:
	if music_player:
		music_player.stop()

func set_master_volume(volume: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume)

func set_sfx_volume(volume: float) -> void:
	# Could create separate SFX bus in future
	pass

func set_music_volume(volume: float) -> void:
	if music_player:
		music_player.volume_db = volume