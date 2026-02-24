extends Enemy

@export var target : Node
@onready var floor_ray: RayCast3D = $"Floor Ray"
@onready var hurtbox: Area3D = $Hurtbox

var mo : Vector3
var approach_dist = 0.82
var knockback : Vector3
var speed_mod : float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed_mod = randf_range(0.5,1.3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var target_dir = position.direction_to(target.position)
	mo = Vector3(target_dir.x*speed_mod,0,target_dir.z*speed_mod)*delta
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
