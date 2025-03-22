class_name InterpolatedCamera3D extends Camera3D

@export var camera_tracking_speed : float = 3.0

var override_camera_flag : bool

var snap_move_flag : bool
var snap_look_flag : bool

var camera_anchor : Node3D
var focus_point : Node3D

var look_point
var look_offset

var move_point
var move_offset

var current_look_point : Vector3
var current_move_point : Vector3

var up_direction : Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta : float) -> void:
	_handle_camera(delta)

func _handle_camera(delta : float) -> void:
	if override_camera_flag:
		if look_point:
			var target : Vector3 = (look_point.global_transform.origin) if look_point is Node3D else look_point
			if look_offset:
				target += look_offset.global_transform.origin if look_offset is Node3D else look_offset
			current_look_point = lerp(current_look_point, target, camera_tracking_speed * delta) if !snap_look_flag else target
		if move_point:
			var target = (move_point.global_transform.origin) if move_point is Node3D else move_point
			if move_offset:
				target += move_offset.global_transform.origin if move_offset is Node3D else move_offset
			current_move_point = lerp(current_move_point, target, camera_tracking_speed * delta) if !snap_move_flag else target

		snap_look_flag = false
		snap_move_flag = false
	else:
		current_look_point = lerp(current_look_point, focus_point.global_transform.origin, camera_tracking_speed * delta)
		current_move_point = lerp(global_transform.origin, camera_anchor.global_transform.origin, camera_tracking_speed * delta)

	global_position = current_move_point
	look_at(current_look_point, up_direction)

func set_camera_anchor(node_3d: Node3D) -> void:
	camera_anchor = node_3d
	global_position = camera_anchor.global_position

func set_focus_point(node_3d : Node3D) -> void:
	focus_point = node_3d

func set_up_direction(up_dir : Vector3) -> void:
	up_direction = up_dir

func look_at_point(point : Vector3, snap : bool = false, offset : Variant = null) -> void:
	look_point = point
	snap_look_flag = snap
	look_offset = offset

func look_at_node(node_3d : Node3D, snap : bool = false, offset : Variant = null) -> void:
	look_point = node_3d
	snap_look_flag = snap
	look_offset = offset


func move_camera_towards_point(point : Vector3, snap : bool = false, offset : Variant = null) -> void:
	move_point = point
	snap_move_flag = snap
	move_offset = offset


func move_camera_towards_node(node_3d : Node3D, snap : bool = false, offset : Variant = null) -> void:
	move_point = node_3d
	snap_move_flag = snap
	move_offset = offset

func override_camera() -> void:
	override_camera_flag = true


func reset_camera() -> void:
	override_camera_flag = false
	move_point = null
	look_point = null

func is_camera_overriden() -> bool:
	return override_camera_flag
