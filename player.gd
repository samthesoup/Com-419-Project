extends CharacterBody3D

@onready var prog_wall: StaticBody3D = $Camera3D/ProgWall
@onready var camera_3d: Camera3D = $Camera3D
@onready var terra_sprite_3d: AnimatedSprite3D = $TerraSprite3D
@onready var mars_sprite_3d: AnimatedSprite3D = $MarsSprite3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_timer: Timer = $AttackTimer


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

enum player_state{
	idle,
	jump,
	attack,
	special
}

var state = player_state.idle
var pre_state = state

@export var can_progress = false

var cam_target : Vector3
var swapped = false

func _ready() -> void:
	cam_target = camera_3d.position

func _physics_process(delta: float) -> void:
	process_movement(delta)
	process_camera()
	process_attacking()
	process_swapping()
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

func _on_progress_trigger_body_entered(_body: Node3D) -> void:
	cam_target.x += 8.495*2
	print("progress")

func process_camera():
	if camera_3d.position != cam_target:
		camera_3d.position = camera_3d.position.lerp(cam_target,0.1)

func process_swapping():
	if Input.is_action_just_pressed("in_swap") and is_on_floor():
		swapped = !swapped
	if !swapped:
		if state == player_state.idle:
			animation_player.play("Terra Idle")
	else:
		if state == player_state.idle:
			animation_player.play("Mars Idle")

func process_attacking():
	if Input.is_action_just_pressed("in_attack"):
		if state != player_state.attack:
			pre_state = state
			state = player_state.attack
			attack_timer.start(0.5)
	if !swapped:
		if state == player_state.attack:
			animation_player.play("Terra Attack")
	

func _on_attack_timer_timeout() -> void:
	state = pre_state
