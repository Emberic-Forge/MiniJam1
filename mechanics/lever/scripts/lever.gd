extends PlayerDetector

@export var target_door : Door

@onready var animation_player : AnimationPlayer = $active_lever/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	on_player_interact.connect(_activate_object)
	super()

func _activate_object(player: Player) -> void:
	animation_player.play("Use")
	get_tree().create_timer(animation_player.current_animation_length).timeout.connect(_open_door)
	on_player_interact.disconnect(_activate_object)

func _open_door() -> void:
	target_door.open_door()
