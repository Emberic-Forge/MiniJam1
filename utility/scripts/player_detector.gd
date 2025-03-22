class_name PlayerDetector extends Area3D

signal on_player_interact(player : Player)
signal on_reset(player : Player)

var can_be_reset : bool

func _ready() -> void:
	if !body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if !body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

	collision_mask = pow(2, 2-1) #Set to only detect the player layer
	collision_layer = 0 #Make self undetectable


func _on_body_entered(body : Variant) -> void:
	if body is not Player:
		return

	var player = body as Player
	player.on_interact.connect(_on_interact)
	print("%s found player" % self.name)
	HUD.write_message("Interact: [interact]")

func _on_body_exited(body : Variant) -> void:
	if body is not Player:
		return

	var player = body as Player
	player.on_interact.disconnect(_on_interact)
	print("%s lost player" % self.name)
	HUD.hide_message()

func _on_interact(player : Player) -> void:
	on_player_interact.emit(player)

func reset_detector(player : Player) -> void:
	if !can_be_reset:
		return
	on_reset.emit(player)
