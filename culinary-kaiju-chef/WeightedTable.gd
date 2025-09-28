# WeightedTable.gd - Stub class for missing WeightedTable
class_name WeightedTable
extends RefCounted

var items: Array = []
var weights: Array = []

func add_item(item, weight: float = 1.0):
    items.append(item)
    weights.append(weight)

func pick_item():
    if items.is_empty():
        return null
    
    var total_weight = 0.0
    for weight in weights:
        total_weight += weight
    
    var random_value = randf() * total_weight
    var current_weight = 0.0
    
    for i in range(items.size()):
        current_weight += weights[i]
        if random_value <= current_weight:
            return items[i]
    
    return items[-1]