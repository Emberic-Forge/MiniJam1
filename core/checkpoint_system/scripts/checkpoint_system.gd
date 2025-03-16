extends Node

var player_reference : Player

var latest_saved_checkpoint_pos : Vector3
var latest_saved_checkpoint_rot : Vector3
var latest_saved_gravity_direction : Vector3

func register_player(player : Player) -> void:
	player_reference = player

func snapshot_game_state(incoming_node : Node3D) -> void:
	latest_saved_checkpoint_pos = incoming_node.global_position
	latest_saved_checkpoint_rot = incoming_node.global_rotation
	latest_saved_gravity_direction = player_reference._get_gravity_direction()
	print("Created a snapshot of the current game state!")


func reload_to_latest_saved_game_state() -> void:
	player_reference.position = latest_saved_checkpoint_pos
	player_reference.rotate_camera_towards(latest_saved_checkpoint_rot)
	player_reference.set_gravity_direction(latest_saved_gravity_direction)
	print("Reloaded to latest snapshot")
