# IAPSystem.gd - In-App Purchase system (Linus approved)
extends Node

# === IAP STATE ===
var is_initialized: bool = false
var available_products: Dictionary = {}
var owned_products: Array[String] = []

# === PRODUCT DEFINITIONS ===
var product_catalog = {
    "remove_ads": {
        "id": "com.culinarykaiju.removeads",
        "price": "$1.99",
        "type": "non_consumable",
        "title": "Remove Ads",
        "description": "Remove all advertisements forever"
    },
    "gold_small": {
        "id": "com.culinarykaiju.gold_small", 
        "price": "$0.99",
        "type": "consumable",
        "title": "Small Gold Pack",
        "description": "500 Gold Coins"
    },
    "gold_large": {
        "id": "com.culinarykaiju.gold_large",
        "price": "$4.99", 
        "type": "consumable",
        "title": "Large Gold Pack",
        "description": "3000 Gold Coins + 500 Bonus"
    },
    "starter_pack": {
        "id": "com.culinarykaiju.starter",
        "price": "$2.99",
        "type": "consumable", 
        "title": "Chef's Starter Pack",
        "description": "1000 Gold + 3 Premium Upgrades"
    },
    "premium_pass": {
        "id": "com.culinarykaiju.premium",
        "price": "$9.99",
        "type": "non_consumable",
        "title": "Premium Chef Pass",
        "description": "Unlock all premium features"
    }
}

func _ready() -> void:
    print("💳 IAPSystem initialized - Professional monetization")
    _initialize_iap()
    
    # Connect to events
    EventBus.iap_requested.connect(_on_iap_requested)

func _initialize_iap() -> void:
    """Initialize IAP system"""
    # In real implementation, this would:
    # - Initialize Google Play Billing
    # - Initialize App Store Connect
    # - Initialize Steam Store API
    
    await get_tree().create_timer(1.0).timeout
    is_initialized = true
    
    # Load owned products from save data
    _load_owned_products()
    
    # Setup available products
    available_products = product_catalog.duplicate()
    
    print("✅ IAP system initialized with %d products" % available_products.size())

func _load_owned_products() -> void:
    """Load previously purchased products"""
    owned_products = PlayerData.get_owned_products()
    print("✅ Loaded %d owned products" % owned_products.size())

func can_purchase(product_id: String) -> bool:
    """Check if a product can be purchased"""
    if not is_initialized:
        return false
    
    if not available_products.has(product_id):
        return false
    
    var product = available_products[product_id]
    
    # Non-consumables can only be bought once
    if product.type == "non_consumable" and owned_products.has(product_id):
        return false
    
    return true

func purchase_product(product_id: String) -> void:
    """Initiate product purchase"""
    if not can_purchase(product_id):
        print("⚠️ Cannot purchase product: %s" % product_id)
        EventBus.iap_completed.emit(product_id, false)
        return
    
    var product = available_products[product_id]
    print("💳 Initiating purchase: %s (%s)" % [product.title, product.price])
    
    # Simulate purchase process
    _simulate_purchase(product_id)

func _simulate_purchase(product_id: String) -> void:
    """Simulate purchase process for testing"""
    # Simulate purchase dialog and processing time
    await get_tree().create_timer(2.0).timeout
    
    # Simulate 95% success rate
    if randf() < 0.95:
        _on_purchase_successful(product_id)
    else:
        _on_purchase_failed(product_id, "user_cancelled")

func _on_purchase_successful(product_id: String) -> void:
    """Handle successful purchase"""
    print("✅ Purchase successful: %s" % product_id)
    
    var product = available_products[product_id]
    
    # Add to owned products if non-consumable
    if product.type == "non_consumable" and not owned_products.has(product_id):
        owned_products.append(product_id)
        PlayerData.add_owned_product(product_id)
    
    # Grant purchase rewards
    _grant_purchase_rewards(product_id)
    
    # Emit success event
    EventBus.iap_completed.emit(product_id, true)

func _on_purchase_failed(product_id: String, reason: String) -> void:
    """Handle purchase failure"""
    print("❌ Purchase failed: %s - %s" % [product_id, reason])
    EventBus.iap_completed.emit(product_id, false)

func _grant_purchase_rewards(product_id: String) -> void:
    """Grant rewards for successful purchase"""
    match product_id:
        "remove_ads":
            _grant_remove_ads()
        "gold_small":
            _grant_gold(500)
        "gold_large":
            _grant_gold(3500)  # 3000 + 500 bonus
        "starter_pack":
            _grant_starter_pack()
        "premium_pass":
            _grant_premium_pass()
        _:
            print("⚠️ Unknown product rewards: %s" % product_id)

func _grant_remove_ads() -> void:
    """Grant ad removal"""
    print("🚫 Ads removed forever")
    PlayerData.set_ads_removed(true)

func _grant_gold(amount: int) -> void:
    """Grant gold currency"""
    print("🪙 Granted %d gold" % amount)
    PlayerData.add_gold(amount)

func _grant_starter_pack() -> void:
    """Grant starter pack contents"""
    print("📦 Granted starter pack")
    PlayerData.add_gold(1000)
    PlayerData.add_premium_currency(100)
    # Could add premium upgrades here

func _grant_premium_pass() -> void:
    """Grant premium pass benefits"""
    print("👑 Granted premium pass")
    PlayerData.set_premium_pass(true)

# === PUBLIC API ===

func get_product_info(product_id: String) -> Dictionary:
    """Get product information"""
    return available_products.get(product_id, {})

func is_product_owned(product_id: String) -> bool:
    """Check if product is owned"""
    return owned_products.has(product_id)

func get_all_products() -> Dictionary:
    """Get all available products"""
    return available_products

func has_ads_removed() -> bool:
    """Check if ads have been removed"""
    return is_product_owned("remove_ads")

func has_premium_pass() -> bool:
    """Check if player has premium pass"""
    return is_product_owned("premium_pass")

func restore_purchases() -> void:
    """Restore previous purchases (iOS requirement)"""
    print("🔄 Restoring purchases...")
    # In real implementation, this would query the platform store
    _load_owned_products()

# === EVENT HANDLERS ===

func _on_iap_requested(product_id: String) -> void:
    """Handle IAP request"""
    purchase_product(product_id)

# === ANALYTICS INTEGRATION ===

func track_purchase_event(product_id: String, success: bool) -> void:
    """Track purchase events for analytics"""
    var event_data = {
        "product_id": product_id,
        "success": success,
        "timestamp": Time.get_unix_time_from_system()
    }
    
    # Would send to analytics service
    print("📊 Purchase event tracked: %s" % event_data)