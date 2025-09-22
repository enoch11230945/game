# EnemySpawner.gd
extends Node

@export var spawn_waves: Array[SpawnWave] = []
@export var spawn_radius: float = 400.0

var time: float = 0.0
var current_wave_index: int = 0

func _ready() -> void:
    # 預填充敵人物件池
    var base_enemy_scene = load("res://features/enemies/base_enemy/base_enemy.tscn")
    ObjectPool.pre_populate(base_enemy_scene, 100)  # 預先創建100個敵人實例

func _process(delta: float) -> void:
    time += delta

    if current_wave_index >= spawn_waves.size():
        return # 所有波次已生成

    var current_wave = spawn_waves[current_wave_index]

    if time >= current_wave.start_time:
        # 觸發波次
        spawn_enemies(current_wave)
        current_wave_index += 1

func spawn_enemies(wave: SpawnWave) -> void:
    # 在螢幕外的隨機位置生成敵人
    var player_pos = get_tree().get_first_node_in_group("player").global_position
    var screen_size = get_viewport().get_visible_rect().size

    for i in range(wave.count):
        var enemy_instance = ObjectPool.request(wave.enemy_data.scene) as Area2D

        # 計算生成位置 (圓形分佈)
        var spawn_pos = _get_random_spawn_position(player_pos, spawn_radius)

        # 將實例添加到場景樹
        get_tree().get_root().add_child(enemy_instance)
        enemy_instance.initialize(spawn_pos, wave.enemy_data)

        # 如果波次有生成間隔，等待一段時間再生成下一個
        if wave.spawn_interval > 0 and i < wave.count - 1:
            await get_tree().create_timer(wave.spawn_interval).timeout

func _get_random_spawn_position(player_pos: Vector2, radius: float) -> Vector2:
    # 在以玩家為中心、指定半徑的圓形範圍內生成隨機位置
    var angle = randf() * 2 * PI
    var distance = radius + randf() * 100  # 額外隨機距離避免重疊
    return player_pos + Vector2(cos(angle), sin(angle)) * distance

func add_wave(wave: SpawnWave) -> void:
    spawn_waves.append(wave)

func clear_waves() -> void:
    spawn_waves.clear()
    current_wave_index = 0
    time = 0.0
