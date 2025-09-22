# state_machine.gd
extends Node

class_name StateMachine

var current_state: Node = null
var states: Dictionary = {}

func _ready() -> void:
    # 自動註冊所有子節點作為狀態
    for child in get_children():
        if child is State:
            add_state(child.name, child)

    # 如果有初始狀態，切換到它
    if states.size() > 0:
        var first_state = states.values()[0]
        change_state(first_state.name)

func add_state(state_name: String, state: Node) -> void:
    states[state_name] = state
    state.state_machine = self
    state.name = state_name
    add_child(state)

func change_state(new_state_name: String) -> void:
    if not states.has(new_state_name):
        return

    if current_state:
        current_state.exit()

    current_state = states[new_state_name]
    current_state.enter()

func _process(delta: float) -> void:
    if current_state:
        current_state.process(delta)

func _physics_process(delta: float) -> void:
    if current_state:
        current_state.physics_process(delta)

func _input(event: InputEvent) -> void:
    if current_state:
        current_state.input(event)

# 狀態基類
class State:
    extends Node

    var state_machine: StateMachine
    weakref var parent: Node

    func _init(parent_ref = null) -> void:
        parent = weakref(parent_ref) if parent_ref else null

    func enter() -> void:
        pass

    func exit() -> void:
        pass

    func process(delta: float) -> void:
        pass

    func physics_process(delta: float) -> void:
        pass

    func input(event: InputEvent) -> void:
        pass

    func get_parent() -> Node:
        return parent.get_ref() if parent else null
