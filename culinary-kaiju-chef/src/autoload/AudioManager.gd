extends Node

# 音頻管理器 - 負責所有音效和背景音樂的播放
class_name AudioManager

# 音效播放器池 - 用於同時播放多個音效
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_pool_size: int = 20

# 背景音樂播放器
var bgm_player: AudioStreamPlayer

# 音效資源緩存
var sfx_cache: Dictionary = {}

# 音量設置
var master_volume: float = 1.0
var sfx_volume: float = 0.7
var bgm_volume: float = 0.3

func _ready():
	# 創建 BGM 播放器
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	bgm_player.bus = "Music"
	
	# 創建音效播放器池
	for i in sfx_pool_size:
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.bus = "SFX"
		sfx_players.append(player)
	
	# 加載所有音效到緩存
	_load_all_sfx()
	
	# 播放背景音樂
	play_bgm("bgm")

func _load_all_sfx():
	"""預加載所有音效文件"""
	var sfx_files = [
		"click4",
		"click5", 
		"defeat",
		"drop_001",
		"drop_004",
		"impactMining_000",
		"impactMining_001",
		"impactMining_002",
		"impactMining_003",
		"impactMining_004",
		"maximize_001",
		"toggle_002",
		"victory"
	]
	
	for sfx_name in sfx_files:
		var path = "res://assets/audio/" + sfx_name + ".ogg"
		if ResourceLoader.exists(path):
			sfx_cache[sfx_name] = load(path)
			print("Loaded SFX: ", sfx_name)

func play_sfx(sfx_name: String, volume_modifier: float = 1.0):
	"""播放音效"""
	if not sfx_cache.has(sfx_name):
		print("SFX not found: ", sfx_name)
		return
	
	# 找到可用的音效播放器
	var available_player = null
	for player in sfx_players:
		if not player.playing:
			available_player = player
			break
	
	if available_player:
		available_player.stream = sfx_cache[sfx_name]
		available_player.volume_db = linear_to_db(sfx_volume * volume_modifier)
		available_player.play()

func play_bgm(bgm_name: String):
	"""播放背景音樂"""
	var path = "res://assets/audio/" + bgm_name + ".mp3"
	if ResourceLoader.exists(path):
		bgm_player.stream = load(path)
		bgm_player.volume_db = linear_to_db(bgm_volume)
		bgm_player.play()

func stop_bgm():
	"""停止背景音樂"""
	bgm_player.stop()

func set_master_volume(volume: float):
	"""設置主音量"""
	master_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))

func set_sfx_volume(volume: float):
	"""設置音效音量"""
	sfx_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))

func set_bgm_volume(volume: float):
	"""設置背景音樂音量"""
	bgm_volume = clamp(volume, 0.0, 1.0)
	bgm_player.volume_db = linear_to_db(bgm_volume)

# 便捷的音效播放函數
func play_weapon_hit():
	play_sfx("impactMining_000", 0.8)

func play_enemy_death():
	play_sfx("impactMining_001", 0.6)

func play_level_up():
	play_sfx("maximize_001", 1.0)

func play_item_pickup():
	play_sfx("drop_001", 0.7)

func play_button_click():
	play_sfx("click4", 0.8)

func play_game_over():
	play_sfx("defeat", 1.0)

func play_victory():
	play_sfx("victory", 1.0)