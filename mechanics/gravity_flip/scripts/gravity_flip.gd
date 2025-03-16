extends PlayerDetector

@onready var animation_player : AnimationPlayer = $gravity_switch/AnimationPlayer

var previous_gravity_direction : Vector3 = Vector3.ZERO

func _ready() -> void:
	on_player_interact.connect(_flip_gravity)
	on_reset.connect(func(player: Player):
		if previous_gravity_direction != Vector3.ZERO:
			player.set_gravity_direction(previous_gravity_direction)
			previous_gravity_direction = Vector3.ZERO
		)
	animation_player.play("Idle")
	super()

func _flip_gravity(player : Player) -> void:
	previous_gravity_direction = player._flip_gravity()
