extends StaticBody3D
class_name Enemy

@export var health : int
@export var damage : int
const MANA_GEM = preload("uid://d23istjoylmpw")

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if is_queued_for_deletion():
		pass
