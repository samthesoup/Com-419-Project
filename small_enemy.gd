extends Enemy

@export var target : Node
@onready var floor_ray: RayCast3D = $"Floor Ray"

var approach_dist = 0.82

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var target_dir = position.direction_to(target.position)
	var mo : Vector3 = Vector3(target_dir.x,0,target_dir.z)*delta
	if position.distance_to(target.position) <= approach_dist:
		mo = Vector3(0,0,0)
	if !floor_ray.is_colliding():
		mo.y = -3*delta
	move_and_collide(mo)
	
	if health <= 0:
		queue_free()


func _on_hurtbox_body_entered(body: Node3D) -> void:
	body.p_damage(damage)
