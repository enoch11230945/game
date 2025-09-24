# EMERGENCY FIX - DISABLE UPGRADE SYSTEM TEMPORARILY
# src/autoload/Game.gd
extends Node

var score: int = 0
var level: int = 1
var experience: int = 0
var xp_to_next_level: int = 50  # Increased from 10 to make leveling slower

func _ready():
    # Load player's permanent data at the start of the game
    # Temporarily disabled to fix dependency issues
    # PlayerData.load_data()

    print(" GAME SYSTEM READY!")
    print("Game autoload initialized successfully")

func set_upgrade_screen(_screen):
    print(" UPGRADE SYSTEM TEMPORARILY DISABLED")
    print(" Game.set_upgrade_screen called (no-op for now)")
    # Temporarily disabled to fix null instance issues
    pass

func add_experience(amount: int):
    if get_tree().paused:
        return
    experience += amount
    if experience >= xp_to_next_level:
        level_up()

func level_up():
    experience -= xp_to_next_level
    level += 1
    xp_to_next_level = int(xp_to_next_level * 1.5)

    print(" LEVEL UP! New level:", level)
    # Temporarily disabled upgrade screen to fix issues
    # upgrade_screen.show_upgrades(dummy_upgrades)

    # Temporarily disabled EventBus to fix dependency issues
    # EventBus.emit_signal("player_leveled_up")

func _on_upgrade_chosen(upgrade_data):
    print("Player chose upgrade: ", upgrade_data.name)

func game_over():
    if not get_tree().paused:
        print("Game Over!")
        # Temporarily disabled to fix dependency issues
        # PlayerData.save_data()
        get_tree().paused = true
        # Here you would typically show a game over screen

# Removed _on_application_quit function to avoid signal issues