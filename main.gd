extends Node3D

@onready var player: CharacterBody3D = $Player

var zone : int = 0
var progress_zone = false

const SMALL_ENEMY = preload("uid://cbbdtm2bx4i0u")
const ENEMY_GROUP_2 = preload("uid://c4m3fy0tshipc")

var groups = [SMALL_ENEMY,ENEMY_GROUP_2]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.progress_zone : 
		progress_zone = player.progress_zone
		zone += 1
		player.progress_zone = false
		
	if progress_zone:
		var g = groups[zone].instantiate()
		for i in g.get_children():
			i.position.x += player.cam_target.x
			i.target = player
		add_child(g)
		progress_zone = false
		
	if get_tree().get_nodes_in_group("Enemies").size() <= 0:
		player.can_progress = true
	else:
		if progress_zone == false:
			player.can_progress = false
