extends Area3D

@export var node_to_look_at : Node3D

var player_ref : Player

func _on_body_entered(body : Variant) -> void:
	if body is not Player:
		return

	player_ref = body as Player
	player_ref.camera.override_camera()
	player_ref.camera.look_at_node(node_to_look_at)

	get_tree().create_timer(25.0).timeout.connect(func():
		player_ref.camera.reset_camera()
		)

func _process(_delta : float) -> void:
	if !player_ref || !player_ref.camera.is_camera_overriden():
		return
	var dir : Vector3 = (player_ref.global_position - node_to_look_at.global_position).normalized()
	player_ref.camera.move_camera_towards_node(player_ref,true, dir * 10)
