extends CanvasLayer

@export_file var main_menu_scene : String
@export_file var options_menu : String

@onready var resume : Button = $panel/margin/order/resume
@onready var options : Button = $panel/margin/order/options
@onready var to_main_menu : Button = $panel/margin/order/to_main_menu
@onready var quit : Button = $panel/margin/order/quit
@onready var animation : AnimationPlayer = $animation

var progress = []
var scene_load_status : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	resume.button_down.connect(_resume)
	quit.button_down.connect(_quit)
	to_main_menu.button_down.connect(_to_main_menu)
	options.button_down.connect(_options_menu)

	PauseSystem.on_pause.connect(_fade_in)
	PauseSystem.on_resume.connect(_fade_out)
	process_mode = Node.PROCESS_MODE_DISABLED

func _resume() -> void:
	PauseSystem.resume()


func _quit() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func _to_main_menu() -> void:
	ResourceLoader.load_threaded_request(main_menu_scene)

func _options_menu() -> void:
	var packed_scene : PackedScene = load(options_menu)
	var options_menu : OptionsMenu = packed_scene.instantiate()
	options_menu.set_player_ref(get_parent().get_child(0))
	add_child(options_menu)

func _fade_in() -> void:
	animation.play("pause_menu_fade_in")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _fade_out() -> void:
	animation.play("pause_menu_fade_out")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta : float) -> void:
	if Input.is_action_just_pressed("escape"):
		PauseSystem.resume()

	scene_load_status = ResourceLoader.load_threaded_get_status(main_menu_scene, progress)
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene = ResourceLoader.load_threaded_get(main_menu_scene)
		get_tree().change_scene_to_packed(new_scene)
