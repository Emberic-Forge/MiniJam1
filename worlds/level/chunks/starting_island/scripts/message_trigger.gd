extends Area3D

@export_multiline var message : String


func _on_body_entered(body : Variant) -> void:
	if body is not Player:
		return

	HUD.write_message(message)
	get_tree().create_timer(6.0).timeout.connect(func():
		HUD.hide_message()
		)
