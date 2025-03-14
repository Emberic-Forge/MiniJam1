extends Area3D


func _on_body_entered(body : Variant) -> void:
	if body is not Player:
		return

	body.enable_gravity_flip()


func _on_body_exited(body : Variant) -> void:
	if body is not Player:
		return

	body.disable_gravity_flip()
