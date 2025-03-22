extends Node

var player_reference : Player

var latest_saved_checkpoint_player_transform : Transform3D
var latest_saved_gravity_direction : Vector3

var world_state

func register_player(player : Player) -> void:
	player_reference = player

func snapshot_game_state(incoming_node : Node3D) -> void:
	latest_saved_checkpoint_player_transform = incoming_node.global_transform
	latest_saved_gravity_direction = player_reference._get_gravity_direction()

	world_state = _get_all_children(incoming_node.get_tree().get_root())
	print("Created a snapshot of the current game state!")


func reload_to_latest_saved_game_state() -> void:
	player_reference.global_transform.origin = latest_saved_checkpoint_player_transform.origin
	player_reference.set_gravity_direction(latest_saved_gravity_direction)
	player_reference.reset_velocity()
	player_reference.camera.reset_camera()

	for node in world_state:
		if !node:
			push_warning("World State has invalid data!")
			continue
		if node is PlayerDetector:
			node.reset_detector(player_reference)
		if node is Node3D && node.has_method("reset"):
			node.reset()

	print("Reloaded to latest snapshot")


func _search_through_tree():
	pass


func _get_all_children(in_node, array := []):
	array.push_back(in_node)
	for child in in_node.get_children():
		array = _get_all_children(child, array)
	return array
