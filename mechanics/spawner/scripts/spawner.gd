extends Node3D

@export_file() var player_file_path : String

func _ready() -> void:
	var player_scene = load(player_file_path)
	_spawn_player.call_deferred(player_scene)

func _spawn_player(player_scene : PackedScene) -> void:
	var player_ins = player_scene.instantiate()
	get_parent().get_parent().add_child(player_ins)

	player_ins.get_child(0).set_gravity_direction(global_basis.z)
	player_ins.global_position = global_position

	CheckpointSystem.snapshot_game_state(self)
