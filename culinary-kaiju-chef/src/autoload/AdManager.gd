# AdManager.gd - Ethical monetization system (Linus-approved)
# "Never break userspace for money - ethical ads only" - Linus Philosophy
extends Node

# === AD STATE ===
var is_ad_system_initialized: bool = false
var rewarded_ads_available: bool = true
var last_ad_shown_time: float = 0.0
var ads_shown_this_session: int = 0

# === AD LIMITS (Respectful monetization) ===
const MAX_ADS_PER_SESSION = 10
const MIN_TIME_BETWEEN_ADS = 60.0  # 1 minute cooldown

# === AD TYPES ===
enum AdType {
    EXTRA_LIFE,
    DOUBLE_GOLD,
    DAILY_REWARD,
    UPGRADE_REROLL
}

# === REWARD CONFIGURATIONS ===
var ad_rewards = {
    AdType.EXTRA_LIFE: {"type": "revival", "value": 1},
    AdType.DOUBLE_GOLD: {"type": "gold_multiplier", "value": 2.0},
    AdType.DAILY_REWARD: {"type": "daily_bonus", "value": 100},
    AdType.UPGRADE_REROLL: {"type": "reroll", "value": 1}
}

func _ready():
    print("📺 AdManager initialized - Ethical monetization ready")
    initialize_ad_system()
    
    # Connect to game events
    EventBus.ad_requested.connect(_on_ad_requested)
    EventBus.game_over.connect(_on_game_over)

func initialize_ad_system():
    """Initialize advertisement SDK (placeholder for actual implementation)"""
    # In a real implementation, this would initialize AdMob, Unity Ads, etc.
    is_ad_system_initialized = true
    rewarded_ads_available = true
    print("📺 Ad system ready (Placeholder - integrate real SDK)")

func can_show_ad() -> bool:
    """Check if an ad can be shown (respects user experience)"""
    if not is_ad_system_initialized:
        return false
    
    if not rewarded_ads_available:
        return false
    
    if ads_shown_this_session >= MAX_ADS_PER_SESSION:
        print("📺 Ad limit reached for this session (%d/%d)" % [ads_shown_this_session, MAX_ADS_PER_SESSION])
        return false
    
    var time_since_last_ad = Time.get_ticks_msec() / 1000.0 - last_ad_shown_time
    if time_since_last_ad < MIN_TIME_BETWEEN_ADS:
        print("📺 Ad cooldown active (%.1fs remaining)" % [MIN_TIME_BETWEEN_ADS - time_since_last_ad])
        return false
    
    return true

func request_rewarded_ad(ad_type: AdType, context: String = ""):
    """Request a rewarded ad with specific type"""
    print("📺 Ad requested: %s (%s)" % [AdType.keys()[ad_type], context])
    
    if not can_show_ad():
        EventBus.ad_failed.emit(AdType.keys()[ad_type], "Cannot show ad")
        return
    
    # Show ad confirmation dialog first
    show_ad_confirmation_dialog(ad_type, context)

func show_ad_confirmation_dialog(ad_type: AdType, context: String):
    """Show user-friendly confirmation before ad"""
    var ad_type_name = AdType.keys()[ad_type]
    var reward_info = ad_rewards.get(ad_type, {})
    
    print("📺 Showing ad confirmation for: %s" % ad_type_name)
    
    # In a real implementation, show a nice dialog with:
    # "Watch a short ad to [get reward]? [Watch Ad] [No Thanks]"
    
    # For now, simulate user acceptance
    simulate_ad_playback(ad_type, context)

func simulate_ad_playback(ad_type: AdType, context: String):
    """Simulate ad playback (replace with real SDK integration)"""
    print("📺 Playing ad... (Simulated)")
    
    # Track ad show
    ads_shown_this_session += 1
    last_ad_shown_time = Time.get_ticks_msec() / 1000.0
    
    # Simulate ad completion after delay
    await get_tree().create_timer(1.0).timeout
    
    # Ad completed successfully
    handle_ad_completion(ad_type, context, true)

func handle_ad_completion(ad_type: AdType, context: String, success: bool):
    """Handle ad completion and give rewards"""
    var ad_type_name = AdType.keys()[ad_type]
    
    if success:
        print("✅ Ad completed successfully: %s" % ad_type_name)
        give_ad_reward(ad_type)
        EventBus.ad_watched_successfully.emit(ad_type_name, ad_rewards.get(ad_type, {}))
    else:
        print("❌ Ad failed or was skipped: %s" % ad_type_name)
        EventBus.ad_failed.emit(ad_type_name, "Ad not completed")

func give_ad_reward(ad_type: AdType):
    """Give the appropriate reward for the ad type"""
    var reward = ad_rewards.get(ad_type, {})
    
    match ad_type:
        AdType.EXTRA_LIFE:
            handle_extra_life_reward()
        AdType.DOUBLE_GOLD:
            handle_double_gold_reward()
        AdType.DAILY_REWARD:
            handle_daily_reward(reward.get("value", 100))
        AdType.UPGRADE_REROLL:
            handle_upgrade_reroll_reward()

func handle_extra_life_reward():
    """Handle extra life reward (revive player)"""
    print("💚 Extra life granted via ad!")
    
    # Revive player if dead
    if Game.is_game_over:
        Game.is_game_over = false
        # Reset player health to 50%
        var player = get_tree().get_first_node_in_group("player")
        if player and player.has_method("revive"):
            player.revive(Game.get_total_health() / 2)
        
        # Visual effects
        EventBus.screen_flash_requested.emit(Color.GREEN, 0.5)
        EventBus.play_sound.emit("revive")
        
        print("💚 Player revived via ad reward!")

func handle_double_gold_reward():
    """Handle double gold reward"""
    var bonus_gold = Game.current_run_gold
    Game.current_run_gold += bonus_gold
    
    print("💰 Gold doubled via ad! Bonus: %d gold" % bonus_gold)
    EventBus.gold_collected.emit(bonus_gold)
    EventBus.play_sound.emit("gold_bonus")

func handle_daily_reward(amount: int):
    """Handle daily reward bonus"""
    PlayerData.add_gold(amount)
    print("🎁 Daily reward bonus: %d gold" % amount)
    EventBus.play_sound.emit("daily_reward")

func handle_upgrade_reroll_reward():
    """Handle upgrade reroll reward"""
    # Signal upgrade manager to provide new choices
    var new_upgrades = UpgradeManager.get_random_upgrades(3)
    EventBus.show_upgrade_screen.emit(new_upgrades)
    print("🎲 Upgrade choices rerolled via ad!")
    EventBus.play_sound.emit("reroll")

# === AD OPPORTUNITY DETECTION ===

func _on_game_over(final_score: int, time_survived: float):
    """Check for ad opportunities on game over"""
    # Offer extra life if player survived for a reasonable time
    if time_survived > 120.0 and can_show_ad():  # 2+ minutes
        offer_extra_life_ad()
    
    # Always offer double gold if available
    if Game.current_run_gold > 0 and can_show_ad():
        offer_double_gold_ad()

func offer_extra_life_ad():
    """Offer extra life ad when player dies"""
    print("📺 Offering extra life ad...")
    # This would show a UI button: "Watch ad to continue?"
    EventBus.ad_requested.emit("EXTRA_LIFE")

func offer_double_gold_ad():
    """Offer double gold ad at end of run"""
    print("📺 Offering double gold ad...")
    # This would show a UI button: "Watch ad to double your gold?"
    EventBus.ad_requested.emit("DOUBLE_GOLD")

func _on_ad_requested(ad_type: String):
    """Handle ad request from UI or other systems"""
    var ad_enum_value = AdType.get(ad_type)
    if ad_enum_value != null:
        request_rewarded_ad(ad_enum_value, "user_requested")
    else:
        print("❌ Unknown ad type requested: %s" % ad_type)

# === IAP SYSTEM (In-App Purchases) ===

var iap_products = {
    "remove_ads": {
        "name": "Remove Ads",
        "description": "Remove all ads and get instant rewards",
        "price": "$2.99",
        "product_id": "com.culinarykaiju.removeads"
    },
    "gold_pack_small": {
        "name": "Gold Pack (Small)",
        "description": "1000 gold coins",
        "price": "$0.99",
        "product_id": "com.culinarykaiju.gold1000"
    },
    "gold_pack_large": {
        "name": "Gold Pack (Large)",
        "description": "5000 gold coins + bonus",
        "price": "$4.99",
        "product_id": "com.culinarykaiju.gold5000"
    },
    "starter_pack": {
        "name": "Chef's Starter Pack",
        "description": "Remove ads + 2000 gold + exclusive skin",
        "price": "$7.99",
        "product_id": "com.culinarykaiju.starterpack"
    }
}

var ads_removed: bool = false

func request_iap(product_id: String):
    """Request in-app purchase"""
    print("💳 IAP requested: %s" % product_id)
    
    if not iap_products.has(product_id):
        print("❌ Unknown IAP product: %s" % product_id)
        EventBus.iap_completed.emit(product_id, false)
        return
    
    # Simulate IAP process (replace with real store integration)
    simulate_iap_purchase(product_id)

func simulate_iap_purchase(product_id: String):
    """Simulate IAP purchase (replace with real implementation)"""
    print("💳 Processing purchase... (Simulated)")
    
    # Simulate processing delay
    await get_tree().create_timer(2.0).timeout
    
    # Simulate successful purchase (90% success rate for testing)
    var success = randf() > 0.1
    
    if success:
        handle_iap_success(product_id)
        EventBus.iap_completed.emit(product_id, true)
    else:
        print("❌ IAP failed: %s" % product_id)
        EventBus.iap_completed.emit(product_id, false)

func handle_iap_success(product_id: String):
    """Handle successful IAP and give rewards"""
    print("✅ IAP successful: %s" % product_id)
    
    match product_id:
        "remove_ads":
            ads_removed = true
            PlayerData.save_game_data()
            print("📺 Ads removed permanently!")
        
        "gold_pack_small":
            PlayerData.add_gold(1000)
            print("💰 1000 gold added!")
        
        "gold_pack_large":
            PlayerData.add_gold(5500)  # 5000 + 500 bonus
            print("💰 5500 gold added (with bonus)!")
        
        "starter_pack":
            ads_removed = true
            PlayerData.add_gold(2000)
            PlayerData.unlock_character("premium_chef")
            print("🎁 Starter pack activated!")
    
    # Visual feedback
    EventBus.screen_flash_requested.emit(Color.GOLD, 0.5)
    EventBus.play_sound.emit("purchase_success")

func are_ads_removed() -> bool:
    """Check if ads have been removed via IAP"""
    return ads_removed

# === DAILY REWARDS SYSTEM ===

var last_daily_reward_date: String = ""
var daily_reward_streak: int = 0

func check_daily_reward():
    """Check if daily reward is available"""
    var today = Time.get_date_string_from_system()
    
    if last_daily_reward_date != today:
        offer_daily_reward()

func offer_daily_reward():
    """Offer daily reward (with optional ad bonus)"""
    var base_reward = 50
    daily_reward_streak += 1
    
    # Streak bonus
    var streak_bonus = min(daily_reward_streak * 10, 100)
    var total_reward = base_reward + streak_bonus
    
    PlayerData.add_gold(total_reward)
    last_daily_reward_date = Time.get_date_string_from_system()
    
    print("🎁 Daily reward: %d gold (streak: %d)" % [total_reward, daily_reward_streak])
    
    # Offer ad to double the reward
    if can_show_ad() and not are_ads_removed():
        print("📺 Offering daily reward ad bonus...")

func get_daily_reward_info() -> Dictionary:
    """Get info about today's daily reward"""
    var today = Time.get_date_string_from_system()
    var is_available = last_daily_reward_date != today
    
    var base_reward = 50
    var streak_bonus = min(daily_reward_streak * 10, 100)
    var total_reward = base_reward + streak_bonus
    
    return {
        "available": is_available,
        "base_reward": base_reward,
        "streak_bonus": streak_bonus,
        "total_reward": total_reward,
        "streak": daily_reward_streak,
        "can_double_with_ad": can_show_ad()
    }

# === ANALYTICS & DEBUGGING ===

func get_monetization_stats() -> Dictionary:
    """Get monetization statistics"""
    return {
        "ads_shown_this_session": ads_shown_this_session,
        "ads_removed": ads_removed,
        "daily_streak": daily_reward_streak,
        "last_ad_time": last_ad_shown_time,
        "can_show_ad": can_show_ad()
    }

func print_monetization_stats():
    """Print monetization statistics"""
    var stats = get_monetization_stats()
    print("=== MONETIZATION STATS ===")
    print("Ads shown this session: %d/%d" % [stats.ads_shown_this_session, MAX_ADS_PER_SESSION])
    print("Ads removed: %s" % stats.ads_removed)
    print("Daily streak: %d" % stats.daily_streak)
    print("Can show ad: %s" % stats.can_show_ad)
    print("=========================")

func reset_session_limits():
    """Reset session limits (call on app restart)"""
    ads_shown_this_session = 0
    last_ad_shown_time = 0.0
    print("📺 Ad session limits reset")