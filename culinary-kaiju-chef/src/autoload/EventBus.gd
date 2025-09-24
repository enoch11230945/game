# EventBus.gd
# A global event bus for decoupled communication between game systems.
extends Node

# Dictionary to store signals that modules can subscribe to.
var signals: Dictionary = {}

# Emit a signal. Creates the signal if it doesn't exist.
func emit(signal_name: String, ...args) -> void:
    if signals.has(signal_name):
        signals[signal_name].emit(args)

# Subscribe to a signal.
func subscribe(signal_name: String, callable: Callable) -> void:
    if not signals.has(signal_name):
        signals[signal_name] = Signal()
    signals[signal_name].connect(callable)

# Unsubscribe from a signal.
func unsubscribe(signal_name: String, callable: Callable) -> void:
    if signals.has(signal_name) and signals[signal_name].is_connected(callable):
        signals[signal_name].disconnect(callable)
