extends CharacterBody3D

@onready var prog_wall: StaticBody3D = $Camera3D/ProgWall

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var can_progress = false

func _physics_process(delta: float) -> void:
	process_movement(delta)
	check_progress_wall()
	move_and_slide()

func process_movement(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("in_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_on_floor():
			velocity.x = move_toward(velocity.x, direction.x*SPEED, SPEED*0.1)
			velocity.z = move_toward(velocity.z, direction.z*SPEED, SPEED*0.1)
		else: 
			velocity.x = direction.x*SPEED
			velocity.z = direction.z*SPEED
	else:
		velocity.x 		= move_toward(velocity.x, 0, SPEED*0.1)
		velocity.z = move_toward(velocity.z, 0, SPEED*0.1)

func check_progress_wall():
	if can_progress and prog_wall.get_collision_layer_value(1) == true:
		prog_wall.set_collision_layer_value(1, false)
	if !can_progress and prog_wall.get_collision_layer_value(1) == false:
		prog_wall.set_collision_layer_value(1, true)
