extends Area3D

@export_file var scene_to_load : String

var progress = []
var scene_load_status : int = 0

func _on_body_entered(body : Variant) -> void:
	if body is not Player:
		return

	var player = body as Player
	player.disable_input()
	ResourceLoader.load_threaded_request(scene_to_load)

func _process(_delta : float) -> void:
	scene_load_status = ResourceLoader.load_threaded_get_status(scene_to_load, progress)
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene = ResourceLoader.load_threaded_get(scene_to_load)
		get_tree().change_scene_to_packed(new_scene)
