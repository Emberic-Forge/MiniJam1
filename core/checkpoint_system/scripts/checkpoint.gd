class_name Checkpoint extends Area3D


func _on_body_entered(body):
	if body is not Player:
		return

	CheckpointSystem.snapshot_game_state(self)
	HUD.write_message("Checkpoint reached")
	get_tree().create_timer(3.0).timeout.connect(func():
		HUD.hide_message()
		)
