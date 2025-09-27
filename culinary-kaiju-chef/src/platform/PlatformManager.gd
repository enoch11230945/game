# PlatformManager.gd - Cross-platform integration (Linus approved)
extends Node

# === PLATFORM DETECTION ===
enum Platform {
    WINDOWS,
    LINUX, 
    MACOS,
    ANDROID,
    IOS,
    WEB,
    STEAM
}

var current_platform: Platform
var is_mobile: bool = false
var is_desktop: bool = false
var is_steam: bool = false

func _ready() -> void:
    print("🎮 PlatformManager initialized - Cross-platform support")
    _detect_platform()

func _detect_platform() -> void:
    """Detect current platform"""
    var os_name = OS.get_name()
    
    match os_name:
        "Windows":
            current_platform = Platform.WINDOWS
            is_desktop = true
        "Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
            current_platform = Platform.LINUX  
            is_desktop = true
        "macOS":
            current_platform = Platform.MACOS
            is_desktop = true
        "Android":
            current_platform = Platform.ANDROID
            is_mobile = true
        "iOS":
            current_platform = Platform.IOS
            is_mobile = true
        "Web":
            current_platform = Platform.WEB
        _:
            current_platform = Platform.WINDOWS
    
    print("✅ Platform detected: %s (Mobile: %s, Desktop: %s)" % [
        Platform.keys()[current_platform], is_mobile, is_desktop
    ])

func get_platform_ui_scale() -> float:
    """Get appropriate UI scale for platform"""
    if is_mobile:
        return 1.5
    else:
        return 1.0

func supports_feature(feature: String) -> bool:
    """Check if platform supports a specific feature"""
    match feature:
        "ads":
            return is_mobile
        "in_app_purchases":
            return is_mobile
        _:
            return false