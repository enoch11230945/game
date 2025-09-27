# AnalyticsManager.gd - Professional analytics tracking (Linus approved)
extends Node

# === ANALYTICS STATE ===
var is_initialized: bool = false
var session_id: String = ""
var session_start_time: float = 0.0
var events_queue: Array[Dictionary] = []

# === PLAYER TRACKING ===
var player_id: String = ""
var current_level: int = 1
var total_playtime: float = 0.0

func _ready() -> void:
    print("📊 AnalyticsManager initialized - Professional data tracking")
    _initialize_analytics()
    
    # Connect to game events
    EventBus.game_started.connect(_on_game_started)
    EventBus.game_over.connect(_on_game_over)
    EventBus.player_level_up.connect(_on_player_level_up)
    EventBus.enemy_killed.connect(_on_enemy_killed)
    EventBus.upgrade_selected.connect(_on_upgrade_selected)
    EventBus.ad_watched_successfully.connect(_on_ad_watched)
    EventBus.iap_completed.connect(_on_iap_completed)

func _initialize_analytics() -> void:
    """Initialize analytics services"""
    # Generate unique session ID
    session_id = "session_" + str(Time.get_unix_time_from_system()) + "_" + str(randi())
    session_start_time = Time.get_unix_time_from_system()
    
    # Load or generate player ID
    player_id = PlayerData.get_player_id()
    if player_id == "":
        player_id = "player_" + str(Time.get_unix_time_from_system()) + "_" + str(randi())
        PlayerData.set_player_id(player_id)
    
    is_initialized = true
    
    # Track session start
    track_event("session_start", {
        "session_id": session_id,
        "player_id": player_id,
        "game_version": ProjectSettings.get_setting("application/config/version", "1.0.0"),
        "platform": OS.get_name()
    })
    
    print("✅ Analytics initialized - Session: %s" % session_id)

# === CORE TRACKING FUNCTIONS ===

func track_event(event_name: String, properties: Dictionary = {}) -> void:
    """Track a custom event with properties"""
    if not is_initialized:
        return
    
    var event_data = {
        "event": event_name,
        "player_id": player_id,
        "session_id": session_id,
        "timestamp": Time.get_unix_time_from_system(),
        "properties": properties
    }
    
    events_queue.append(event_data)
    
    # In production, this would send to analytics service
    print("📊 Event tracked: %s" % event_name)
    
    # Batch send events when queue gets large
    if events_queue.size() >= 10:
        _flush_events()

func _flush_events() -> void:
    """Send queued events to analytics service"""
    if events_queue.is_empty():
        return
    
    print("📤 Flushing %d analytics events" % events_queue.size())
    
    # In production, this would send to:
    # - Google Analytics
    # - Firebase Analytics
    # - Unity Analytics
    # - GameAnalytics
    # - Custom analytics service
    
    events_queue.clear()

# === GAMEPLAY ANALYTICS ===

func track_game_session(duration: float, score: int, level_reached: int) -> void:
    """Track complete game session"""
    track_event("game_session_complete", {
        "duration_seconds": duration,
        "final_score": score,
        "max_level_reached": level_reached,
        "enemies_killed": Game.enemies_killed,
        "upgrades_taken": Game.upgrades_taken
    })

func track_progression_event(event_type: String, level: int, details: Dictionary = {}) -> void:
    """Track player progression events"""
    var properties = {
        "level": level,
        "session_duration": Time.get_unix_time_from_system() - session_start_time
    }
    properties.merge(details)
    
    track_event("progression_" + event_type, properties)

func track_monetization_event(event_type: String, product_id: String, success: bool, revenue: float = 0.0) -> void:
    """Track monetization events"""
    track_event("monetization_" + event_type, {
        "product_id": product_id,
        "success": success,
        "revenue_usd": revenue,
        "player_level": current_level,
        "session_duration": Time.get_unix_time_from_system() - session_start_time
    })

# === PERFORMANCE ANALYTICS ===

func track_performance_metrics() -> void:
    """Track performance metrics"""
    var fps = Engine.get_frames_per_second()
    var memory_usage = OS.get_static_memory_usage()
    
    track_event("performance_metrics", {
        "fps": fps,
        "memory_mb": memory_usage / (1024 * 1024),
        "active_enemies": get_tree().get_nodes_in_group("enemies").size(),
        "active_projectiles": get_tree().get_nodes_in_group("projectiles").size()
    })

# === USER BEHAVIOR ANALYTICS ===

func track_ui_interaction(ui_element: String, action: String) -> void:
    """Track UI interactions"""
    track_event("ui_interaction", {
        "element": ui_element,
        "action": action,
        "screen": get_current_screen_name()
    })

func get_current_screen_name() -> String:
    """Get current screen/scene name for context"""
    var current_scene = get_tree().current_scene
    if current_scene:
        return current_scene.name
    return "unknown"

# === RETENTION ANALYTICS ===

func track_retention_metrics() -> void:
    """Track player retention data"""
    var days_since_install = PlayerData.get_days_since_install()
    var sessions_today = PlayerData.get_sessions_today()
    
    track_event("retention_metrics", {
        "days_since_install": days_since_install,
        "sessions_today": sessions_today,
        "total_sessions": PlayerData.get_total_sessions(),
        "total_playtime_hours": total_playtime / 3600.0
    })

# === EVENT HANDLERS ===

func _on_game_started() -> void:
    """Track game start"""
    current_level = 1
    track_event("game_start", {
        "player_level": Game.player_level,
        "has_premium": PlayerData.has_premium_pass(),
        "ads_removed": PlayerData.has_ads_removed()
    })

func _on_game_over(final_score: int, time_survived: float) -> void:
    """Track game over"""
    track_game_session(time_survived, final_score, current_level)
    
    track_event("game_over", {
        "survival_time": time_survived,
        "final_score": final_score,
        "max_level": current_level,
        "cause": "enemy_defeat"  # Could be more specific
    })

func _on_player_level_up(new_level: int) -> void:
    """Track level up"""
    current_level = new_level
    track_progression_event("level_up", new_level, {
        "xp_gained": Game.total_xp_collected
    })

func _on_enemy_killed(enemy: Node, xp_reward: int) -> void:
    """Track enemy kills (batched to avoid spam)"""
    # Only track every 10th kill to avoid event spam
    if Game.enemies_killed % 10 == 0:
        track_event("enemies_milestone", {
            "total_kills": Game.enemies_killed,
            "current_level": current_level
        })

func _on_upgrade_selected(upgrade_data: Resource) -> void:
    """Track upgrade selections"""
    var upgrade_name = upgrade_data.get("item_name", "unknown")
    track_event("upgrade_selected", {
        "upgrade_name": upgrade_name,
        "player_level": current_level,
        "upgrades_total": Game.upgrades_taken
    })

func _on_ad_watched(ad_type: String, reward_data: Dictionary) -> void:
    """Track ad watching"""
    track_monetization_event("ad_watched", ad_type, true, 0.0)

func _on_iap_completed(product_id: String, success: bool) -> void:
    """Track IAP completions"""
    var revenue = 0.0
    if success:
        # Get revenue from product catalog
        var product_prices = {
            "remove_ads": 1.99,
            "gold_small": 0.99,
            "gold_large": 4.99,
            "starter_pack": 2.99,
            "premium_pass": 9.99
        }
        revenue = product_prices.get(product_id, 0.0)
    
    track_monetization_event("iap_completed", product_id, success, revenue)

# === CLEANUP ===

func _exit_tree() -> void:
    """Flush remaining events on exit"""
    if is_initialized:
        track_event("session_end", {
            "session_duration": Time.get_unix_time_from_system() - session_start_time,
            "total_events": events_queue.size()
        })
        _flush_events()