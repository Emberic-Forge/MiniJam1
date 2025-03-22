extends PlayerDetector

@export var can_reset_flip : bool = false

@onready var animation_player : AnimationPlayer = $gravity_switch/AnimationPlayer

var previous_gravity_direction : Vector3 = Vector3.ZERO


func _ready() -> void:
	can_be_reset = can_reset_flip
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
