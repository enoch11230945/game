# main.gd
extends Node2D

@export var test_mode: bool = false

func _ready() -> void:
    # 連接事件總線
    EventBus.game_over.connect(_on_game_over)
    EventBus.game_victory.connect(_on_game_victory)

    # 初始化物件池
    _initialize_object_pools()

    # 設置測試波次（如果在測試模式）
    if test_mode:
        _setup_test_waves()

    print("Main scene ready")

func _initialize_object_pools() -> void:
    # 預填充物件池
    var base_enemy_scene = load("res://features/enemies/base_enemy/base_enemy.tscn")
    ObjectPool.pre_populate(base_enemy_scene, 50)

    var xp_gem_scene = load("res://features/items/xp_gem/xp_gem.tscn")
    ObjectPool.pre_populate(xp_gem_scene, 30)

    print("Object pools initialized")

func _setup_test_waves() -> void:
    # 創建測試波次
    var enemy_spawner = $EnemySpawner as EnemySpawner
    if enemy_spawner:

        # 載入敵人數據
        var onion_grunt_data = load("res://features/enemies/enemy_data/onion_grunt.tres")

        # 創建波次
        var wave1 = SpawnWave.new()
        wave1.start_time = 2.0
        wave1.count = 5
        wave1.enemy_data = onion_grunt_data
        wave1.spawn_interval = 0.5

        var wave2 = SpawnWave.new()
        wave2.start_time = 10.0
        wave2.count = 10
        wave2.enemy_data = onion_grunt_data
        wave2.spawn_interval = 0.3

        var wave3 = SpawnWave.new()
        wave3.start_time = 20.0
        wave3.count = 15
        wave3.enemy_data = onion_grunt_data
        wave3.spawn_interval = 0.2

        # 添加波次
        enemy_spawner.add_wave(wave1)
        enemy_spawner.add_wave(wave2)
        enemy_spawner.add_wave(wave3)

        print("Test waves set up")

func _on_game_over() -> void:
    print("Game Over!")
    # 在這裡可以添加遊戲結束邏輯

func _on_game_victory() -> void:
    print("Victory!")
    # 在這裡可以添加勝利邏輯

func _input(event: InputEvent) -> void:
    # 測試快捷鍵
    if event.is_action_pressed("ui_cancel"):
        get_tree().quit()

    # 暫停/恢復遊戲
    if event.is_action_pressed("ui_pause"):
        if get_tree().paused:
            Game.resume_game()
        else:
            Game.pause_game()
