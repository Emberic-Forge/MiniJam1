extends CharacterBody3D

@export_group("Ground Movement")
@export var movement_speed : float = 10.0
@export_range(0.0, 100.0, 0.1) var acceleration : float = 1.0
@export_range(0.0, 100.0, 0.1) var decceleration : float = 1.0
@export_group("Air Movement")
@export var jump_height : float = 2.0
@export_range(0.0, 100.0, 0.1) var air_acceleration : float = 1.0
@export_range(0.0, 100.0, 0.1) var air_decceleration : float = 1.0
@export_group("Camera Settings")
@export var mouse_sensitivity : float = 0.5
@export_range(-180, 180, 0.1) var camera_min_vertical_rotation : float = -30.0
@export_range(-180, 180, 0.1) var camera_max_vertical_rotation : float = 60.0

@onready var camera_base : SpringArm3D = $camera_base
@onready var camera : Camera3D = $camera_base/camera

var camera_input_direction : Vector2 = Vector2.ZERO

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event : InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	)

	if is_camera_motion:
		camera_input_direction = event.screen_relative * mouse_sensitivity

func _process(delta : float) -> void:
	handle_camera_control(delta)
	handle_gravity(delta)
	handle_jump()
	handle_movement(delta)

	move_and_slide()
	pass

func handle_camera_control(delta : float) -> void:
	camera_base.rotation.x -= camera_input_direction.y * delta
	camera_base.rotation.x = clamp(camera_base.rotation.x, deg_to_rad(camera_min_vertical_rotation), deg_to_rad(camera_max_vertical_rotation))

	camera_base.rotation.y -= camera_input_direction.x * delta

	camera_input_direction = Vector2.ZERO

func handle_movement(delta : float) -> void:
	var parallelInput := Input.get_axis("move_left","move_right")
	var forwardInput := Input.get_axis("move_forward", "move_backward")

	var directionalInput = (camera_base.basis.x * parallelInput + camera_base.basis.z * forwardInput).normalized()
	var target_motion : Vector3

	var target_acceleration : float = acceleration if is_on_floor() else air_acceleration
	var target_decceleration : float = decceleration if is_on_floor() else air_decceleration

	if directionalInput.length() > 0:
		var target_velocity = Vector3(directionalInput.x * movement_speed , velocity.y, directionalInput.z * movement_speed )
		target_motion = lerp(velocity, target_velocity , target_acceleration * delta)
	else:
		var target_velocity = Vector3(0, velocity.y, 0)
		target_motion = lerp(velocity, target_velocity , target_decceleration * delta)

	velocity = target_motion

func handle_jump() -> void:
	if Input.is_action_pressed("jump") && is_on_floor():
		var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
		var gravity_direction : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
		var jump_velocity : float = sqrt(2 * gravity * jump_height)

		var target_motion = -gravity_direction * jump_velocity
		velocity += target_motion


func handle_gravity(delta : float) -> void:
	if is_on_floor():
		return
	var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
	var gravity_direction : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")

	var target_motion = gravity_direction * gravity * delta
	velocity += target_motion
