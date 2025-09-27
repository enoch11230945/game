extends Node

# 音频管理器 - 管理背景音乐和音效
class_name AudioManager

# 音频播放器
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# 音量设置
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.8

# 音频资源预加载
var bgm_track: AudioStream
var sfx_library: Dictionary = {}

func _ready():
	# 创建音频播放器
	music_player = AudioStreamPlayer.new()
	sfx_player = AudioStreamPlayer.new()
	
	add_child(music_player)
	add_child(sfx_player)
	
	# 预加载音频资源
	_load_audio_resources()
	
	# 开始播放背景音乐
	play_bgm()

func _load_audio_resources():
	# 加载背景音乐
	var bgm_path = "res://assets/audio/music/bgm.mp3"
	if ResourceLoader.exists(bgm_path):
		bgm_track = load(bgm_path)
	
	# 加载音效
	var sfx_paths = {
		"click": "res://assets/audio/sfx/click4.ogg",
		"select": "res://assets/audio/sfx/click5.ogg", 
		"hit": "res://assets/audio/sfx/impactMining_000.ogg",
		"pickup": "res://assets/audio/sfx/drop_001.ogg",
		"upgrade": "res://assets/audio/sfx/maximize_001.ogg",
		"defeat": "res://assets/audio/sfx/defeat.ogg",
		"victory": "res://assets/audio/sfx/victory.ogg",
		"footstep": "res://assets/audio/sfx/footstep_carpet_000.ogg"
	}
	
	for key in sfx_paths:
		var path = sfx_paths[key]
		if ResourceLoader.exists(path):
			sfx_library[key] = load(path)

func play_bgm():
	if bgm_track and music_player:
		music_player.stream = bgm_track
		music_player.volume_db = linear_to_db(music_volume * master_volume)
		music_player.loop = true
		music_player.play()

func play_sfx(sound_name: String):
	if sfx_library.has(sound_name) and sfx_player:
		sfx_player.stream = sfx_library[sound_name]
		sfx_player.volume_db = linear_to_db(sfx_volume * master_volume)
		sfx_player.play()

func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func _update_volumes():
	if music_player:
		music_player.volume_db = linear_to_db(music_volume * master_volume)
	if sfx_player:
		sfx_player.volume_db = linear_to_db(sfx_volume * master_volume)

func stop_bgm():
	if music_player:
		music_player.stop()

func pause_bgm():
	if music_player:
		music_player.stream_paused = true

func resume_bgm():
	if music_player:
		music_player.stream_paused = false