extends CanvasLayer

@export_file var scene_to_load : String
@export_file var options_menu : String

@onready var start : Button= $main_menu/button_menu/margin/VBoxContainer/start
@onready var option : Button= $main_menu/button_menu/margin/VBoxContainer/option
@onready var quit : Button= $main_menu/button_menu/margin/VBoxContainer/quit


var progress = []
var scene_load_status : int = 0

func _ready() -> void:
	start.button_down.connect(_start_game)
	quit.button_down.connect(_quit_game)
	option.button_down.connect(_options_menu)

	PauseSystem.resume()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta : float) -> void:
	scene_load_status = ResourceLoader.load_threaded_get_status(scene_to_load, progress)
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene = ResourceLoader.load_threaded_get(scene_to_load)
		get_tree().change_scene_to_packed(new_scene)
		progress = null
		scene_load_status = -2

func _start_game() -> void:
	ResourceLoader.load_threaded_request(scene_to_load)

func _options_menu() -> void:
	var packed_scene : PackedScene = load(options_menu)
	add_child(packed_scene.instantiate())

func _quit_game() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit();
