extends Node3D

@export var is_collectable : bool = true

@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("Idle")

func _on_player_detector_body_entered(body : Variant) -> void:
	if not is_collectable or body is not Player:
		return

	queue_free()
