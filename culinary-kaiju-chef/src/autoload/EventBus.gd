# EventBus.gd
# A global event bus for decoupled communication between game systems.
extends Node

# Core game events
signal player_health_changed(current_health: int, max_health: int)
signal player_experience_gained(amount: int, current_xp: int, required_xp: int)
signal player_leveled_up(new_level: int)
signal player_died
signal player_revived_by_ad

# Combat events
signal enemy_spawned(enemy: Node)
signal enemy_killed(enemy: Node, xp_reward: int)
signal weapon_fired(weapon: Node, projectile: Node)
signal damage_dealt(source: Node, target: Node, amount: int)

# UI events
signal upgrade_screen_opened
signal upgrade_screen_closed
signal upgrade_selected(upgrade_data: Resource)

# Meta progression events
signal coins_changed(new_amount: int)
signal permanent_upgrade_purchased(upgrade_data: Resource)

# Dictionary to store custom signals
var _custom_signals: Dictionary = {}

# Emit a custom signal by name
func emit_signal_by_name(signal_name: String, args: Array = []) -> void:
    if has_signal(signal_name):
        if args.size() == 0:
            get(signal_name).emit()
        elif args.size() == 1:
            get(signal_name).emit(args[0])
        elif args.size() == 2:
            get(signal_name).emit(args[0], args[1])
        elif args.size() == 3:
            get(signal_name).emit(args[0], args[1], args[2])
        elif args.size() == 4:
            get(signal_name).emit(args[0], args[1], args[2], args[3])

# Create and emit custom signals dynamically
func emit_custom(signal_name: String, args: Array = []) -> void:
    if not _custom_signals.has(signal_name):
        _custom_signals[signal_name] = Signal()
    
    if args.is_empty():
        _custom_signals[signal_name].emit()
    else:
        _custom_signals[signal_name].emit.callv(args)

# Connect to custom signals
func connect_custom(signal_name: String, callable: Callable) -> void:
    if not _custom_signals.has(signal_name):
        _custom_signals[signal_name] = Signal()
    _custom_signals[signal_name].connect(callable)