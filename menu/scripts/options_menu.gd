class_name OptionsMenu extends Control

@onready var mouse_sens : HSlider = $order/contents/margin/order/mouse/margin/VBoxContainer/master/mouse_sens
@onready var back : Button = $order/back

var player : Player

func _ready():
	if player:
		mouse_sens.value = player.mouse_sensitivity
	mouse_sens.value_changed.connect(_on_slider_changed)
	back.button_down.connect(close)


func _process(delta):
	if Input.is_action_just_pressed("escape"):
		close()

func _on_slider_changed(value : float) -> void:
	player.mouse_sensitivity = value

func set_player_ref(player : Player) -> void:
	self.player = player


func close() -> void:
	queue_free()
