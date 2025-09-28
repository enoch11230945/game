# AdManager.gd - Epic 3: 广告商业化系统  
# Linus principle: "Never break userspace - ads should enhance, not interrupt"
extends Node

# 广告状态
var is_ad_ready: bool = false
var ads_removed: bool = false  # 是否购买了去广告
var last_ad_time: float = 0.0
var ad_cooldown: float = 30.0  # 广告冷却时间

# 模拟广告系统 (实际项目中会使用AdMob)
var mock_ad_system: bool = true

signal ad_loaded
signal ad_failed_to_load
signal ad_watched_successfully
signal ad_closed_early

func _ready() -> void:
    # 连接事件
    EventBus.player_died.connect(_on_player_died)
    
    # 检查是否已购买去广告
    ads_removed = PlayerData.has_permanent_upgrade("remove_ads")
    
    # 预加载广告
    if not ads_removed:
        _preload_ads()

func _preload_ads() -> void:
    if mock_ad_system:
        # 模拟广告加载
        await get_tree().create_timer(1.0).timeout
        is_ad_ready = true
        ad_loaded.emit()
        print("📺 Mock ads loaded")
    else:
        # 实际AdMob代码会在这里
        # AdMob.load_rewarded_ad()
        pass

# 检查是否可以显示广告
func can_show_ad() -> bool:
    if ads_removed:
        return false
    if not is_ad_ready:
        return false
    if Time.get_ticks_msec() / 1000.0 - last_ad_time < ad_cooldown:
        return false
    return true

# 显示激励式广告：复活
func show_revive_ad() -> void:
    if not can_show_ad():
        print("❌ Cannot show revive ad")
        return
        
    print("📺 Showing revive ad...")
    _show_mock_ad("revive")

# 显示激励式广告：金币翻倍
func show_double_coins_ad() -> void:
    if not can_show_ad():
        print("❌ Cannot show double coins ad")
        return
        
    print("📺 Showing double coins ad...")
    _show_mock_ad("double_coins")

# 显示激励式广告：额外升级选择
func show_extra_upgrade_ad() -> void:
    if not can_show_ad():
        print("❌ Cannot show extra upgrade ad") 
        return
        
    print("📺 Showing extra upgrade ad...")
    _show_mock_ad("extra_upgrade")

func _show_mock_ad(ad_type: String) -> void:
    if mock_ad_system:
        # 模拟广告播放
        print("🎬 Playing mock ad for: ", ad_type)
        
        # 模拟用户观看完成 (70%概率)
        await get_tree().create_timer(2.0).timeout
        
        if randf() < 0.7:  # 70%概率观看完成
            _on_ad_watched_successfully(ad_type)
        else:
            _on_ad_closed_early(ad_type)
    else:
        # 实际广告代码
        pass

func _on_ad_watched_successfully(ad_type: String) -> void:
    print("✅ Ad watched successfully: ", ad_type)
    last_ad_time = Time.get_ticks_msec() / 1000.0
    is_ad_ready = false
    
    # 根据广告类型给予奖励
    match ad_type:
        "revive":
            EventBus.player_revived_by_ad.emit()
        "double_coins":
            _double_coins_reward()
        "extra_upgrade":
            _extra_upgrade_reward()
    
    ad_watched_successfully.emit()
    
    # 重新加载下一个广告
    call_deferred("_preload_ads")

func _on_ad_closed_early(ad_type: String) -> void:
    print("❌ Ad closed early: ", ad_type)
    ad_closed_early.emit()
    
    # 立即重新加载广告
    call_deferred("_preload_ads")

func _double_coins_reward() -> void:
    # 将本局获得的金币翻倍
    var coins_this_run = Game.score  # 假设score就是本局金币
    PlayerData.coins += coins_this_run
    EventBus.coins_changed.emit(PlayerData.coins)
    print("💰 Coins doubled! +" + str(coins_this_run))

func _extra_upgrade_reward() -> void:
    # 给玩家额外的升级选择
    EventBus.emit_signal("extra_upgrade_granted")
    print("🎁 Extra upgrade choice granted!")

func _on_player_died() -> void:
    # 玩家死亡时，如果可以显示广告，显示复活选项
    if can_show_ad():
        EventBus.emit_signal("revive_ad_available")

# 购买去除广告 (IAP)
func purchase_remove_ads() -> void:
    ads_removed = true
    PlayerData.set_permanent_upgrade("remove_ads", true)
    PlayerData.save_data()
    print("🚫 Ads removed permanently!")
    
# 获取去广告按钮的奖励 (无需观看广告)
func get_no_ad_reward(reward_type: String) -> void:
    if not ads_removed:
        return
        
    print("🎁 No-ad reward: ", reward_type)
    match reward_type:
        "revive":
            EventBus.player_revived_by_ad.emit()
        "double_coins":
            _double_coins_reward()
        "extra_upgrade":
            _extra_upgrade_reward()

# 调试：重置广告状态
func reset_ad_system() -> void:
    ads_removed = false
    is_ad_ready = false
    last_ad_time = 0.0
    _preload_ads()