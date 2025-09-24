extends Node2D

func _ready():
    print("🎮 Player is ready!")
    print("✅ You should see a green square on the screen")
    print("🎯 If you see this message, the game is working!")

func _process(_delta):
    # Simple input test
    if Input.is_action_pressed("move_left"):
        print("⬅️ Left pressed")
    if Input.is_action_pressed("move_right"):
        print("➡️ Right pressed")
    if Input.is_action_pressed("move_up"):
        print("⬆️ Up pressed")
    if Input.is_action_pressed("move_down"):
        print("⬇️ Down pressed")
