class_name Door extends Node3D

@onready var animation_player : AnimationPlayer = $archway_gate/AnimationPlayer

func _ready() -> void:
	animation_player.play("Close")

func open_door() -> float:
	animation_player.play("Open")
	return animation_player.current_animation_length
