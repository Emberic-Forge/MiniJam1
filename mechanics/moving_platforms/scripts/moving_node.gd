extends AnimatableBody3D

@export var start_point : Node3D
@export var end_point : Node3D
@export var speed : float = 20.0
@export var wait_duration_in_seconds : float = 1.0
@export var start_delay_in_seconds : float = 0.0

var target_point : Vector3 = Vector3.ZERO
var wait_flag : bool = false
var move_flag : bool = true


func _ready() -> void:

	target_point = start_point.position
	if start_delay_in_seconds > 0:
		move_flag = false
		get_tree().create_timer(start_delay_in_seconds).timeout.connect(func():
			move_flag = true
			)
	else:
		move_flag = true

func _physics_process(delta : float) -> void:
	var dir = (target_point - position).normalized()
	var has_reached_target = (target_point - position).length() < 0.1
	if !has_reached_target && move_flag:
		position += dir * speed * delta


	if has_reached_target  && !wait_flag:
		wait_flag = true
		get_tree().create_timer(wait_duration_in_seconds).timeout.connect(func():
			_determine_target_point()
			wait_flag = false
			)

func _determine_target_point() -> void:
	var start_test := (start_point.position - target_point).length()
	var end_test := (end_point.position - target_point).length()

	target_point = end_point.position if start_test < end_test else start_point.position
