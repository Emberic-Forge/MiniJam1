class_name Player extends CharacterBody3D

@export_group("Ground Movement")
@export var movement_speed : float = 10.0
@export_range(0.0, 10.0, 0.1) var acceleration : float = 1.0
@export_range(0.0, 10.0, 0.1) var decceleration : float = 1.0
@export_group("Air Movement")
@export var jump_height : float = 2.0
@export_range(0.0, 10.0, 0.1) var air_acceleration : float = 1.0
@export_range(0.0, 10.0, 0.1) var air_decceleration : float = 1.0
@export_group("Camera Settings")
@export var mouse_sensitivity : float = 0.5
@export_range(-180, 180, 0.1) var camera_min_vertical_rotation : float = -30.0
@export_range(-180, 180, 0.1) var camera_max_vertical_rotation : float = 60.0

@onready var camera_base : SpringArm3D = $camera_base
@onready var camera : Camera3D = $camera_base/camera

var camera_input_direction : Vector2 = Vector2.ZERO
var can_flip_gravity_flag : bool

func _get_gravity_direction() -> Vector3:
	return PhysicsServer3D.area_get_param(get_viewport().find_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR)

func _get_gravity_amount() -> float:
	return PhysicsServer3D.area_get_param(get_viewport().find_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY)

func _set_gravity_direction(new_direction : Vector3) -> void:
	PhysicsServer3D.area_set_param(get_viewport().find_world_3d().space,PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR, new_direction)

func _is_gravity_flipped() -> bool:
	var current_gravity = _get_gravity_direction()
	var result : bool = current_gravity != Vector3.DOWN
	if result:
		print("Gravity is indeed flipped!")
	return result

func _ready() -> void:
	CheckpointSystem.register_player(self)

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
	_handle_camera_control(delta)
	_handle_gravity_flip()

func _physics_process(delta : float) -> void:
	_handle_gravity(delta)
	_handle_jump()
	_handle_movement(delta)

	_DEBUG_force_respawn()

	move_and_slide()

func _handle_camera_control(delta : float) -> void:
	var is_flipped := _is_gravity_flipped()

	var target_input_x_axis = -camera_input_direction.x if is_flipped else camera_input_direction.x
	var target_input_y_axis = -camera_input_direction.y if is_flipped else camera_input_direction.y

	camera_base.rotation.x -= target_input_y_axis * delta
	camera_base.rotation.x = clamp(camera_base.rotation.x, deg_to_rad(camera_min_vertical_rotation), deg_to_rad(camera_max_vertical_rotation))

	camera_base.rotation.y -= target_input_x_axis * delta
	camera_base.rotation.z = deg_to_rad(180) if is_flipped else 0

	camera_input_direction = Vector2.ZERO

func _handle_movement(delta : float) -> void:
	var parallelInput := Input.get_axis("move_left","move_right")
	var forwardInput := Input.get_axis("move_forward", "move_backward")

	var directional_input = (camera_base.basis.x * parallelInput + camera_base.basis.z * forwardInput).normalized()
	var target_motion : Vector3

	var target_acceleration : float = acceleration if is_on_floor() else air_acceleration
	var target_decceleration : float = decceleration if is_on_floor() else air_decceleration

	if directional_input.length() > 0:
		var target_velocity = Vector3(directional_input.x * movement_speed , velocity.y, directional_input.z * movement_speed )
		target_motion = lerp(velocity, target_velocity , target_acceleration * delta)
	else:
		var target_velocity = Vector3(0, velocity.y, 0)
		target_motion = lerp(velocity, target_velocity , target_decceleration * delta)

	velocity = target_motion

func _handle_jump() -> void:
	if Input.is_action_pressed("jump") && _is_on_floor():
		var gravity : float = _get_gravity_amount()
		var gravity_direction : Vector3 = _get_gravity_direction()
		var jump_velocity : float = sqrt(2 * gravity * jump_height)

		var target_motion = -gravity_direction * jump_velocity
		velocity += target_motion


func _handle_gravity(delta : float) -> void:
	if _is_on_floor():
		return
	var gravity : float = _get_gravity_amount()
	var gravity_direction : Vector3 = _get_gravity_direction()

	var target_motion = gravity_direction * gravity * delta
	velocity += target_motion

func _handle_gravity_flip() -> void:
	if not can_flip_gravity_flag:
		return

	if Input.is_action_just_pressed("interact"):
		_flip_gravity()

func _flip_gravity() -> void:
	var gravity_direction : Vector3 = _get_gravity_direction()
	print("Old Gravity: (%f, %f, %f)" % [gravity_direction.x, gravity_direction.y, gravity_direction.z])
	gravity_direction = gravity_direction * -1

	_set_gravity_direction(gravity_direction)
	print("Gravity has flipped: (%f, %f, %f)" % [gravity_direction.x, gravity_direction.y, gravity_direction.z])


func _is_on_floor() -> bool:
	var is_gravity_flipped := _is_gravity_flipped()
	var condition : bool = (
		(is_on_floor() and !is_gravity_flipped) or
		(is_on_ceiling() and is_gravity_flipped)
	)
	return condition

func _DEBUG_force_respawn() -> void:
	if Input.is_action_just_pressed("debug_respawn"):
		CheckpointSystem.reload_to_latest_saved_game_state()

func enable_gravity_flip() -> void:
	can_flip_gravity_flag = true

func disable_gravity_flip() -> void:
	can_flip_gravity_flag = false


func rotate_camera_towards(new_rotation : Vector3) -> void:
	camera_base.rotation.x = new_rotation.x
	camera_base.rotation.y = new_rotation.y
	pass

func set_gravity_direction(new_gravity_direction : Vector3) -> void:
	_set_gravity_direction(new_gravity_direction)
	print("Gravity has flipped: (%f, %f, %f)" % [new_gravity_direction.x, new_gravity_direction.y, new_gravity_direction.z])
