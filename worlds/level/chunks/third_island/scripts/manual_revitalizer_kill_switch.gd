extends Area3D

@onready var revitalizer = $"../revitalizer"

func _on_body_entered(body : Variant) -> void:
	revitalizer.manually_kill_objects(body as Player)
