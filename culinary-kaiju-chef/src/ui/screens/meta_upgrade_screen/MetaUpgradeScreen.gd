# MetaUpgradeScreen.gd - 元升级界面 (Epic 2.1)
extends Control

# UI 节点引用
@onready var gold_label: Label = $VBox/TopBar/GoldLabel
@onready var upgrades_container: VBoxContainer = $VBox/ScrollContainer/UpgradesContainer
@onready var back_button: Button = $VBox/TopBar/BackButton

# 引用元进程系统
var meta_system: Node

func _ready() -> void:
    print("💰 MetaUpgradeScreen initialized")
    
    # 获取元进程系统引用
    meta_system = get_node_or_null("/root/MetaProgressionSystem")
    if not meta_system:
        print("❌ MetaProgressionSystem not found!")
        return
    
    # 连接按钮事件
    back_button.pressed.connect(_on_back_pressed)
    
    # 连接金币变化事件
    EventBus.gold_collected.connect(_on_gold_changed)
    
    # 初始化界面
    refresh_ui()

func refresh_ui() -> void:
    """刷新整个界面"""
    update_gold_display()
    populate_upgrades()

func update_gold_display() -> void:
    """更新金币显示"""
    gold_label.text = "金币: %d" % PlayerData.total_gold

func populate_upgrades() -> void:
    """填充升级列表"""
    # 清空现有升级卡片
    for child in upgrades_container.get_children():
        child.queue_free()
    
    if not meta_system or not meta_system.has_method("get_all_upgrades_info"):
        return
    
    # 获取升级信息
    var upgrades_info = meta_system.get_all_upgrades_info()
    
    # 简化显示 - 直接列出所有升级
    for upgrade_info in upgrades_info:
        create_upgrade_card(upgrade_info)

func create_upgrade_card(upgrade_info: Dictionary) -> void:
    """创建升级卡片"""
    # 创建升级卡片容器
    var card_container = HBoxContainer.new()
    card_container.custom_minimum_size = Vector2(0, 80)
    
    # 升级信息标签
    var info_container = VBoxContainer.new()
    info_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    var name_label = Label.new()
    name_label.text = upgrade_info.name
    info_container.add_child(name_label)
    
    var desc_label = Label.new()
    desc_label.text = upgrade_info.description
    desc_label.modulate = Color(0.8, 0.8, 0.8, 1.0)
    info_container.add_child(desc_label)
    
    var level_label = Label.new()
    level_label.text = "等级: %d/%d" % [upgrade_info.current_level, upgrade_info.max_level]
    level_label.modulate = Color(0.7, 0.9, 1.0, 1.0)
    info_container.add_child(level_label)
    
    card_container.add_child(info_container)
    
    # 升级按钮
    var upgrade_button = Button.new()
    if upgrade_info.can_purchase and upgrade_info.next_cost > 0:
        upgrade_button.text = "升级 %d金币" % upgrade_info.next_cost
        upgrade_button.disabled = false
        upgrade_button.pressed.connect(_on_upgrade_pressed.bind(upgrade_info.id))
    elif upgrade_info.current_level >= upgrade_info.max_level:
        upgrade_button.text = "已满级"
        upgrade_button.disabled = true
    else:
        upgrade_button.text = "需要%d金币" % upgrade_info.next_cost
        upgrade_button.disabled = true
    
    upgrade_button.custom_minimum_size = Vector2(120, 40)
    card_container.add_child(upgrade_button)
    
    # 添加到容器
    upgrades_container.add_child(card_container)

func _on_upgrade_pressed(upgrade_id: String) -> void:
    """处理升级按钮点击"""
    if not meta_system or not meta_system.has_method("purchase_upgrade"):
        return
    
    var success = meta_system.purchase_upgrade(upgrade_id)
    if success:
        # 刷新界面
        refresh_ui()
        print("✅ Successfully purchased upgrade: %s" % upgrade_id)
    else:
        print("❌ Failed to purchase upgrade: %s" % upgrade_id)

func _on_back_pressed() -> void:
    """返回主菜单"""
    print("🔙 Returning to main menu")
    queue_free()

func _on_gold_changed(amount: int) -> void:
    """金币变化时刷新显示"""
    update_gold_display()
    refresh_ui()