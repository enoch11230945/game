# AdSystem.gd - Professional ad integration (Linus approved)
extends Node

# === AD STATE ===
var is_initialized: bool = false
var ads_available: bool = false
var last_ad_time: float = 0.0
var ad_cooldown: float = 30.0  # 30 seconds between ads

# === AD TYPES ===
enum AdType {
    REWARDED,
    INTERSTITIAL,
    BANNER
}

# === REWARD TRACKING ===
var pending_rewards: Dictionary = {}

func _ready() -> void:
    print("📱 AdSystem initialized - Professional monetization")
    _initialize_ads()
    
    # Connect to events
    EventBus.ad_requested.connect(_on_ad_requested)

func _initialize_ads() -> void:
    """Initialize ad SDK (placeholder for real implementation)"""
    # In a real implementation, this would initialize:
    # - Google AdMob SDK for mobile
    # - Steam Ads API for Steam
    # - Unity Ads, etc.
    
    # For now, simulate initialization
    await get_tree().create_timer(1.0).timeout
    is_initialized = true
    ads_available = true
    print("✅ Ad SDK initialized")

func can_show_ad(ad_type: AdType) -> bool:
    """Check if an ad can be shown"""
    if not is_initialized or not ads_available:
        return false
    
    # Check cooldown
    var current_time = Time.get_ticks_msec() / 1000.0
    if current_time - last_ad_time < ad_cooldown:
        return false
    
    return true

func show_rewarded_ad(reward_type: String, reward_value: int) -> void:
    """Show rewarded video ad"""
    if not can_show_ad(AdType.REWARDED):
        print("⚠️ Cannot show rewarded ad right now")
        EventBus.ad_failed.emit("rewarded", "cooldown_or_unavailable")
        return
    
    print("📱 Showing rewarded ad for: %s (%d value)" % [reward_type, reward_value])
    
    # Store pending reward
    pending_rewards[reward_type] = reward_value
    
    # Simulate ad viewing (in real implementation, this would show actual ad)
    _simulate_ad_viewing(AdType.REWARDED, reward_type, reward_value)

func show_interstitial_ad() -> void:
    """Show full-screen interstitial ad"""
    if not can_show_ad(AdType.INTERSTITIAL):
        print("⚠️ Cannot show interstitial ad right now")
        return
    
    print("📱 Showing interstitial ad")
    _simulate_ad_viewing(AdType.INTERSTITIAL, "", 0)

func _simulate_ad_viewing(ad_type: AdType, reward_type: String, reward_value: int) -> void:
    """Simulate ad viewing process"""
    # Update last ad time
    last_ad_time = Time.get_ticks_msec() / 1000.0
    
    # Simulate ad duration
    var ad_duration = 30.0 if ad_type == AdType.REWARDED else 5.0
    await get_tree().create_timer(ad_duration).timeout
    
    # Simulate 90% success rate
    if randf() < 0.9:
        _on_ad_completed_successfully(ad_type, reward_type, reward_value)
    else:
        _on_ad_failed(ad_type, "user_closed_early")

func _on_ad_completed_successfully(ad_type: AdType, reward_type: String, reward_value: int) -> void:
    """Handle successful ad completion"""
    print("✅ Ad completed successfully")
    
    if ad_type == AdType.REWARDED and reward_type != "":
        # Grant reward
        var reward_data = {
            "type": reward_type,
            "value": reward_value
        }
        
        EventBus.ad_watched_successfully.emit("rewarded", reward_data)
        _grant_reward(reward_type, reward_value)
    
    # Clean up pending rewards
    if pending_rewards.has(reward_type):
        pending_rewards.erase(reward_type)

func _on_ad_failed(ad_type: AdType, reason: String) -> void:
    """Handle ad failure"""
    print("❌ Ad failed: %s" % reason)
    
    var ad_type_string = "rewarded" if ad_type == AdType.REWARDED else "interstitial"
    EventBus.ad_failed.emit(ad_type_string, reason)
    
    # Clean up pending rewards
    pending_rewards.clear()

func _grant_reward(reward_type: String, reward_value: int) -> void:
    """Grant reward to player"""
    match reward_type:
        "revive":
            _grant_revive_reward()
        "double_xp":
            _grant_double_xp_reward(reward_value)
        "gold":
            _grant_gold_reward(reward_value)
        "premium_currency":
            _grant_premium_currency_reward(reward_value)
        _:
            print("⚠️ Unknown reward type: %s" % reward_type)

func _grant_revive_reward() -> void:
    """Grant player revive"""
    print("💚 Granted player revive")
    # Implementation would revive player
    EventBus.player_revived_by_ad.emit()

func _grant_double_xp_reward(duration_minutes: int) -> void:
    """Grant double XP boost"""
    print("⚡ Granted %d minutes of double XP" % duration_minutes)
    # Implementation would activate XP boost

func _grant_gold_reward(amount: int) -> void:
    """Grant gold currency"""
    print("🪙 Granted %d gold" % amount)
    PlayerData.add_gold(amount)

func _grant_premium_currency_reward(amount: int) -> void:
    """Grant premium currency"""
    print("💎 Granted %d premium currency" % amount)
    PlayerData.add_premium_currency(amount)

# === PUBLIC API ===

func offer_revive_ad() -> void:
    """Offer revive ad to player"""
    show_rewarded_ad("revive", 1)

func offer_double_xp_ad() -> void:
    """Offer double XP ad"""
    show_rewarded_ad("double_xp", 30)  # 30 minutes

func offer_gold_reward_ad() -> void:
    """Offer gold reward ad"""
    var gold_amount = randi_range(50, 200)
    show_rewarded_ad("gold", gold_amount)

func get_ad_status() -> Dictionary:
    """Get current ad system status"""
    return {
        "initialized": is_initialized,
        "available": ads_available,
        "can_show_rewarded": can_show_ad(AdType.REWARDED),
        "can_show_interstitial": can_show_ad(AdType.INTERSTITIAL),
        "time_until_next_ad": max(0, ad_cooldown - (Time.get_ticks_msec() / 1000.0 - last_ad_time))
    }

# === EVENT HANDLERS ===

func _on_ad_requested(ad_type: String) -> void:
    """Handle ad request event"""
    match ad_type:
        "revive":
            offer_revive_ad()
        "double_xp":
            offer_double_xp_ad()
        "gold":
            offer_gold_reward_ad()
        "interstitial":
            show_interstitial_ad()
        _:
            print("⚠️ Unknown ad request type: %s" % ad_type)