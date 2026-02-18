extends CharacterBody3D

@onready var prog_wall: StaticBody3D = $Camera3D/ProgWall
@onready var camera_3d: Camera3D = $Camera3D
@onready var terra_sprite_3d: AnimatedSprite3D = $TerraSprite3D
@onready var mars_sprite_3d: AnimatedSprite3D = $MarsSprite3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hp_bar: ColorRect = $HUD/HPBar

const DAMAGE_COUNTER = preload("uid://c27gmi8psvjw8")

const SPEED = 3.5
const JUMP_VELOCITY = 4.5

enum player_state{
	idle,
	moving,
	jump,
	attack,
	special
}

var state = player_state.idle
var pre_state = state

var hp = 100.0
var iframes = 0

@export var can_progress = false

var cam_target : Vector3
var swapped = false
var damage = 10

func _ready() -> void:
	cam_target = camera_3d.position

func _physics_process(delta: float) -> void:
	if iframes > 0 :
		iframes -= 1
	process_movement(delta)
	process_camera()
	process_attacking()
	process_swapping()
	check_progress_wall()
	update_hud()
	move_and_slide()

func process_movement(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("in_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir.x < 0:
		rotation.y = deg_to_rad(180)
	if input_dir.x > 0:
		rotation.y = deg_to_rad(0)
	var direction := (Vector3(input_dir.x, 0, input_dir.y)).normalized()
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
	if Input.is_action_just_pressed("in_swap") and (state == player_state.moving or state == player_state.idle):
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
	if !swapped:
		if state == player_state.attack:
			animation_player.play("Terra Attack")
	else:
		if state == player_state.attack:
			animation_player.play("Mars_Attack")

func update_hud():
	hp_bar.size.x = hp / 100.0 * 832.0
	if hp_bar.size.x <= 0 : hp_bar.size.x = 0

func _on_hurtbox_body_entered(body: Node3D) -> void:
	var dc = DAMAGE_COUNTER.instantiate()
	dc.position = body.position
	dc.position.y += 0.5
	dc.text = str(damage)
	get_tree().root.add_child(dc)
	body.health -= damage


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Terra Attack":
		state = pre_state
	if anim_name == "Mars_Attack":
		state = pre_state

func p_damage(amnt):
	if iframes <= 0:
		hp -= amnt
		iframes = 100
