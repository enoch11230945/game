# AdSystem.gd - Rewarded ads integration
extends Node

signal ad_watched_successfully(ad_type: String, reward: Dictionary)

enum AdType { REVIVE, DOUBLE_GOLD, DAILY_BONUS, SKIP_UPGRADE }

func show_rewarded_ad(ad_type: AdType, context: Dictionary = {}):
	print("[AdSystem] Showing ad: ", AdType.keys()[ad_type])
	# Simulate successful ad viewing
	await get_tree().create_timer(1.0).timeout
	
	match ad_type:
		AdType.REVIVE:
			EventBus.emit_signal("player_revived_by_ad")
		AdType.DOUBLE_GOLD:
			EventBus.emit_signal("gold_multiplier_activated", 2.0)
		AdType.DAILY_BONUS:
			PlayerData.add_gold(100)
		AdType.SKIP_UPGRADE:
			EventBus.emit_signal("reroll_upgrades_requested")

func is_ad_available(ad_type: AdType) -> bool:
	return true  # Always available for testing