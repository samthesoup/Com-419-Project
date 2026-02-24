extends Enemy

@export var target : Node
@onready var floor_ray: RayCast3D = $"Floor Ray"
@onready var hurtbox: Area3D = $Hurtbox

var approach_dist = 0.82
var knockback : Vector3

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
		mo.y += -2*delta
	
	if knockback != Vector3.ZERO:
		mo += knockback*delta
		knockback = Vector3.ZERO
	
	move_and_collide(mo)
	
	var p = hurtbox.get_overlapping_bodies()
	if p.size() > 0:
		p[0].p_damage(damage)
	
	if health <= 0:
		queue_free()
