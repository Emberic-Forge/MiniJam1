class_name PlayerDetector extends Area3D

signal on_player_interact(player : Player)
signal on_reset(player : Player)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	collision_mask = pow(2, 2-1) #Set to only detect the player layer
	collision_layer = 0 #Make self undetectable


func _on_body_entered(body : Variant) -> void:
	if body is not Player:
		return

	var player = body as Player
	player.on_interact.connect(_on_interact)
	print("%s found player" % self.name)

func _on_body_exited(body : Variant) -> void:
	if body is not Player:
		return

	var player = body as Player
	player.on_interact.disconnect(_on_interact)
	print("%s lost player" % self.name)

func _on_interact(player : Player) -> void:
	on_player_interact.emit(player)

func reset_detector(player : Player) -> void:
	on_reset.emit(player)
