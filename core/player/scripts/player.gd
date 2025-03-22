class_name Player extends CharacterBody3D

@export_group("Ground Movement")
@export var walk_distance_per_second : float = 3.0
@export var sprint_distance_per_second : float = 6.0
@export_range(0.0, 10.0, 0.1) var acceleration : float = 1.0
@export_range(0.0, 10.0, 0.1) var decceleration : float = 1.0

@export_group("Air Movement")
@export var jump_height : float = 2.0
@export_range(0.0, 10.0, 0.1) var air_acceleration : float = 1.0
@export_range(0.0, 10.0, 0.1) var air_decceleration : float = 1.0
@export var fall_multiplier : float = 1.3

@export_group("Camera Settings")
@export var mouse_sensitivity : float = 0.5
@export_range(-180, 180, 0.1) var camera_min_vertical_rotation : float = -30.0
@export_range(-180, 180, 0.1) var camera_max_vertical_rotation : float = 60.0

@export_group("Animation Settings")
@export_range(0,10,0.01) var walk_anim_transition_time : float = 5
@export_range(0,10,0.01) var sprint_anim_transition_time : float = 5
@export_range(0,10,0.01) var air_anim_transition_time : float = 5
@export_range(0,10,0.01) var transition_between_air_and_ground_time : float = 5

@export_group("Camera Settings")
@export var camera : InterpolatedCamera3D

@export_group("Other")
@export var death_duration_in_seconds : float = 3.0

@onready var camera_base : SpringArm3D = $camera_base
@onready var model : Node3D = $model
@onready var animation_tree : AnimationTree = $model/player/AnimationTree
@onready var body_shape : CollisionShape3D  = $body_shape
@onready var camera_anchor : Node3D = $camera_base/camera_anchor

var camera_input_direction : Vector2 = Vector2.ZERO
var sprint_flag : bool

var ground_walk_blend_value : float
var air_anim_blend_value : float
var transition_blend_value : float

var input_state_flag : bool = true

signal on_interact

func _get_gravity_direction() -> Vector3:
	return PhysicsServer3D.area_get_param(get_viewport().find_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR)

func _get_gravity_amount() -> float:
	return PhysicsServer3D.area_get_param(get_viewport().find_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY)

func _set_gravity_direction(new_direction : Vector3) -> void:
	PhysicsServer3D.area_set_param(get_viewport().find_world_3d().space,PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR, new_direction)

func _is_gravity_flipped() -> bool:
	var current_gravity = _get_gravity_direction()
	var result : bool = current_gravity.dot(Vector3.DOWN) <= 0


	return result

func _ready() -> void:
	CheckpointSystem.register_player(self)

	camera.set_camera_anchor(camera_anchor)
	camera.set_up_direction(up_direction)
	camera.set_focus_point(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event : InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	)

	if is_camera_motion:
		camera_input_direction = event.screen_relative * mouse_sensitivity

func _process(delta : float) -> void:
	if input_state_flag:
		_handle_camera_control(delta)
		_update_animation_tree(delta)
		_handle_interactions()

	_handle_model_orientation()

	if Input.is_action_just_pressed("escape"):
		PauseSystem.pause()

func _physics_process(delta : float) -> void:
	_handle_gravity(delta)
	if input_state_flag:
		_handle_jump()
		_handle_movement(delta)

	_DEBUG_force_respawn()

	move_and_slide()

func _handle_interactions() -> void:
	if Input.is_action_just_pressed("interact") and on_interact.has_connections():
		on_interact.emit(self)
		print("Interacted!")

func _handle_model_orientation() -> void:
	var is_flipped := _is_gravity_flipped()
	model.rotation.z = deg_to_rad(180) if is_flipped else 0

func _update_animation_tree(delta : float) -> void:
	var target_value : float = 0
	var directiona_input := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_forward", "move_backward"))
	var is_sprinting := Input.is_action_pressed("sprint")

	if directiona_input.length() > 0:
		target_value = 1 if is_sprinting else 0.5

	var transition_time = sprint_anim_transition_time if is_sprinting else walk_anim_transition_time
	ground_walk_blend_value = lerp(ground_walk_blend_value, target_value, transition_time * delta)
	animation_tree.set("parameters/Ground Walk/blend_position", ground_walk_blend_value)

	var dot_product = velocity.dot(_get_gravity_direction())
	target_value = 1 if dot_product < 0 else -1 if dot_product > 0 else 0
	air_anim_blend_value = lerp(air_anim_blend_value, target_value, air_anim_transition_time * delta)
	animation_tree.set("parameters/Air Anim/blend_position", air_anim_blend_value)

	target_value = 1 if !_is_on_floor() else 0
	transition_blend_value = lerp(transition_blend_value, target_value, transition_between_air_and_ground_time * delta)
	animation_tree.set("parameters/Transition/blend_amount", transition_blend_value)

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

	var directional_input : Vector3 = (camera_base.basis.x * parallelInput + camera_base.basis.z * forwardInput).normalized()

	if _is_on_floor():
		sprint_flag = Input.is_action_pressed("sprint")

	var target_motion : Vector3

	var target_acceleration : float = acceleration if _is_on_floor() else air_acceleration
	var target_decceleration : float = decceleration if _is_on_floor() else air_decceleration

	var walk_speed = walk_distance_per_second / delta
	var sprint_speed = sprint_distance_per_second / delta

	var target_speed : float = sprint_speed if sprint_flag  else walk_speed

	if directional_input.length() > 0:
		var target_velocity = Vector3(directional_input.x * target_speed , velocity.y, directional_input.z * target_speed )
		target_motion = lerp(velocity, target_velocity , target_acceleration * delta)
	else:
		var target_velocity = Vector3(0, velocity.y, 0)
		target_motion = lerp(velocity, target_velocity , target_decceleration * delta)

	velocity = target_motion

	_rotate_model_towards_direction(velocity)

func _rotate_model_towards_direction(direction : Vector3) -> void:
	model.rotation.y = atan2(-direction.x,-direction.z)

func _handle_jump() -> void:
	var gravity_direction : Vector3 = _get_gravity_direction()
	var dot = velocity.dot(gravity_direction.normalized())
	if Input.is_action_pressed("jump") && _is_on_floor() && (is_equal_approx(dot, 0) || dot > 0) :
		var gravity : float = _get_gravity_amount()
		var jump_velocity : float = sqrt(2 * gravity * jump_height)
		var target_motion = -gravity_direction * jump_velocity
		velocity += target_motion

func _handle_gravity(delta : float) -> void:
	if _is_on_floor():
		return
	var gravity : float = _get_gravity_amount()
	var gravity_direction : Vector3 = _get_gravity_direction()

	var is_going_down := velocity.dot(gravity_direction) >= -0.1
	var target_gravity = gravity * (fall_multiplier if is_going_down else 1)
	var target_motion = gravity_direction * target_gravity * delta
	velocity += target_motion
	velocity.limit_length(30)

func _flip_gravity() -> Vector3:
	reset_velocity()
	camera.override_camera()
	camera.look_at_node(self, true)
	get_tree().create_timer(3.0).timeout.connect(func():
		camera.reset_camera()
		)
	var gravity_direction : Vector3 = _get_gravity_direction()
	print("Old Gravity: (%f, %f, %f)" % [gravity_direction.x, gravity_direction.y, gravity_direction.z])
	var new_gravity_direction = gravity_direction * -1

	set_gravity_direction(new_gravity_direction)

	return gravity_direction


func _is_on_floor() -> bool:
	return is_on_floor()

func _DEBUG_force_respawn() -> void:
	if Input.is_action_just_pressed("debug_respawn"):
		CheckpointSystem.reload_to_latest_saved_game_state()


func rotate_camera_towards(new_rotation : Vector3) -> void:
	camera_base.rotation.x = new_rotation.x
	camera_base.rotation.y = new_rotation.y
	pass

func set_gravity_direction(new_gravity_direction : Vector3) -> void:
	_set_gravity_direction(new_gravity_direction)
	_handle_model_orientation()
	up_direction = -new_gravity_direction
	camera.set_up_direction(up_direction)
	print("Gravity has been overriden: (%f, %f, %f)" % [new_gravity_direction.x, new_gravity_direction.y, new_gravity_direction.z])
	var gravity_direction = _get_gravity_direction()
	print("Gravity (%f, %f, %f), Dot Product: %f" % [gravity_direction.x, gravity_direction.y, gravity_direction.z, gravity_direction.dot(Vector3.DOWN)])

func die() -> void:
	camera.override_camera()
	camera.look_at_node(self)
	camera.move_camera_towards_point(global_position)
	disable_input()
	get_tree().create_timer(death_duration_in_seconds).timeout.connect(func():
		enable_input()
		camera.reset_camera()
		CheckpointSystem.reload_to_latest_saved_game_state()
		)
	pass


func disable_input() -> void:
	set_process_input(false)
	input_state_flag = false

func enable_input() -> void:
	set_process_input(true)
	input_state_flag = true



func reset_velocity() -> void:
	velocity = Vector3.ZERO
