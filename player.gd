extends CharacterBody3D

@onready var head = $head
@onready var crouching_collision_shape = $crouching_collision_shape
@onready var standing_collision_shape = $standing_collision_shape
@onready var ray_cast_3d = $RayCast3D
@onready var camera_3d = $head/eyes/Camera3D
@onready var eyes = $head/eyes
@onready var audio_stream_player_3d = $AudioStreamPlayer3D
const FUMOSF = preload("res://Fumo Sound Effect From Touhou Project (128kbps).mp3")

var gravity_force = 1
var current_speed = 5.0
const walking_speed = 8.0
const sprinting_speed = 8.0
const crouching_speed = 3.0
var jump_velocity = 0
var jump_velocity_grounded = 6
var jump_velocity_double_jump = 8
const mouse_sens = 0.2
var direction = Vector3.ZERO
var lerp_speed = 10.0

var crouching_depth = -0.7

# STATES
var walking = false
var sprinting = false
var crouching = false
var sliding = false

# Slide variables
var slide_timer = 0.0
var slide_timer_max = 3
var slide_vector = Vector2.ZERO
var slide_speed = 7.3
var max_slide_tilt_angle = deg_to_rad(7.0) # Maximum tilt angle when sliding
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# double jump
var double_jump_max = 1
var double_jump = 0

var current_direction = Vector3.ZERO
var target_direction = Vector3.ZERO
var acceleration = 2.0  # Adjust as needed for the desired acceleration rate

# tracer blink ability
var blink_dist = 7

# gun variables
var bullet = load("res://bullet.tscn")
var instance
@onready var gun_anim = $head/eyes/Camera3D/CIRNO/AnimationPlayer
@onready var gun_barrel = $head/eyes/Camera3D/CIRNO/gun_barrel


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "foward", "backward")
	if input_dir == Vector2.ZERO:  # Check if no movement input
		sliding = false  # Stop sliding if no movement input
		
	if Input.is_action_just_pressed("crouch") && !is_on_floor():
		print("working")
		velocity.y -= 45
		
	if Input.is_action_just_pressed("crouch"):
		if input_dir != Vector2.ZERO && is_on_floor():
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			print("Sliding")
			walking = false
			sprinting = false
			crouching = true
			current_speed = crouching_speed


	if Input.is_action_pressed("crouch"):
		head.position.y = lerp(head.position.y, 1.8 + crouching_depth, delta * lerp_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		camera_3d.rotation.z = lerp(camera_3d.rotation.z, 0.0, delta * lerp_speed) # Tilt back camera when crouching
	elif !ray_cast_3d.is_colliding():
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		head.position.y = lerp(head.position.y, 1.8, delta * lerp_speed)

		if sliding and slide_timer > 0:
			slide_timer -= delta
			if slide_timer <= 0: # Slide timer has reached 0, stop sliding
				sliding = false

		if Input.is_action_just_released("crouch"):
			sliding = false
			print("Not slidding")

		if Input.is_action_pressed("sprint"):
			current_speed = sprinting_speed
			walking = false
			sprinting = true
			crouching = false
		else:
			current_speed = walking_speed
			walking = true
			sprinting = false
			crouching = false

	if sliding:
		var slide_angle = atan2(slide_vector.x, slide_vector.y)
		if slide_angle > PI: # Adjust angle for backwards sliding
			slide_angle -= PI
		var target_camera_rotation_z = clamp(slide_angle, -max_slide_tilt_angle, max_slide_tilt_angle)
		camera_3d.rotation.z = lerp(camera_3d.rotation.z, target_camera_rotation_z, delta * lerp_speed)
	else:
		var target_camera_rotation_z = -deg_to_rad(head.rotation.y * 8)
		camera_3d.rotation.z = lerp(camera_3d.rotation.z, target_camera_rotation_z, delta * lerp_speed)

	if !is_on_floor():
		velocity.y -= (gravity * gravity_force) * delta
	if is_on_floor():
		double_jump = 0
		jump_velocity = jump_velocity_grounded

	if Input.is_action_just_pressed("ui_accept") and double_jump <= double_jump_max:
		velocity.y = jump_velocity
		double_jump += 1
		if double_jump <= 1: #sound here
			jump_velocity = jump_velocity_double_jump

	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)

	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		if sliding:
			velocity.x = direction.x * (slide_timer + 0.1) * slide_speed
			velocity.z = direction.z * (slide_timer + 0.1) * slide_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	
	# my shitty chatgpt dash script
	if Input.is_action_just_pressed("dash") && !is_on_floor():
		var blink_direction = direction.normalized()  # Normalize direction vector to preserve direction
		blink_direction.y = 0  # Set y component to 0 to exclude it from scaling
		blink_direction *= blink_dist
		direction = blink_direction

	
	# yoo im writing this with like an hour of sleep, ion understand any of this lol
	if Input.is_action_pressed("shoot"):
		if !gun_anim.is_playing():
			gun_anim.play("shoot")
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)
			$AudioStreamPlayer3D.stream = FUMOSF
			$AudioStreamPlayer3D.play()
			
	

	move_and_slide()
