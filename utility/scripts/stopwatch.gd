extends Node3D

@onready var start : Area3D = $start
@onready var end : Area3D = $end
@onready var timer : Timer = $Timer

const START_TIME : float = 9999.9

var has_activated : bool = false


func _stopwatch_start(body : Variant) -> void:
	if has_activated:
		return
	timer.paused = false
	timer.start(START_TIME)
	has_activated = true
	print("Stopwatch Started!")

func _stopwatch_end(body : Variant) -> void:
	if !has_activated:
		return

	has_activated = false

	timer.paused = true
	var time_remaining = timer.time_left
	var result = START_TIME - time_remaining
	print("Stopwatch Stopped! Result: %f seconds" % result)
