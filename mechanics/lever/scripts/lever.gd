extends PlayerDetector

@export var target_door : Door

@onready var animation_player : AnimationPlayer = $active_lever/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	on_player_interact.connect(_activate_object)
	can_be_reset = false
	super()

func _activate_object(player: Player) -> void:
	animation_player.play("Use")
	player.disable_input()
	get_tree().create_timer(animation_player.current_animation_length).timeout.connect(_open_door.bind(player))
	on_player_interact.disconnect(_activate_object)

func _open_door(player: Player) -> void:
	player.camera.override_camera()
	player.camera.look_at_node(target_door)
	var duration = target_door.open_door()
	get_tree().create_timer(duration).timeout.connect(func():
		player.camera.reset_camera()
		player.enable_input()
		)
