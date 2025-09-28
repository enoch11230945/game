# GoldCoin.gd - 永久货币收集物 (Epic 2.1)
extends Area2D
class_name GoldCoin

@export var gold_value: int = 1

var is_collecting: bool = false
var collection_speed: float = 300.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
    # Connect collection trigger
    area_entered.connect(_on_area_entered)
    
    # Add to collectables group
    add_to_group("collectables")
    add_to_group("gold_coins")

func initialize(gold_amount: int) -> void:
    """初始化金币价值"""
    gold_value = gold_amount
    
    # 视觉反馈基于金币价值
    var scale_factor = 1.0 + (gold_amount / 10.0)
    sprite.scale = Vector2(scale_factor, scale_factor)
    
    # 颜色编码
    if gold_amount >= 5:
        sprite.modulate = Color.GOLD
    elif gold_amount >= 3:
        sprite.modulate = Color.YELLOW  
    else:
        sprite.modulate = Color(1.0, 0.8, 0.2, 1.0)  # Light gold

func _process(delta: float) -> void:
    if is_collecting:
        move_towards_player(delta)

func move_towards_player(delta: float) -> void:
    """向玩家移动进行收集"""
    var player = get_tree().get_first_node_in_group("player")
    if not player:
        return
    
    var direction = (player.global_position - global_position).normalized()
    global_position += direction * collection_speed * delta

func _on_area_entered(area: Area2D) -> void:
    """处理收集触发"""
    if area.is_in_group("player") or area.get_parent().is_in_group("player"):
        collect()

func collect() -> void:
    """被收集时的处理"""
    # 添加金币到永久进度
    if has_node("/root/MetaProgressionSystem"):
        var meta_system = get_node("/root/MetaProgressionSystem")
        if meta_system.has_method("add_gold"):
            meta_system.add_gold(gold_value)
    
    # 发送事件
    EventBus.gold_collected.emit(gold_value)
    
    # 音效
    if AudioManager and AudioManager.has_method("play_sfx"):
        AudioManager.play_sfx("pickup_gold")
    
    # 视觉效果
    EventBus.spawn_particle_effect.emit("gold_pickup", global_position)
    
    print("💰 Collected %d gold" % gold_value)
    
    # 移除自己
    queue_free()