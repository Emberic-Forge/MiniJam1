extends PlayerDetector

@export var duration_in_seconds : float = 10
@export var objects_to_affect : Array[Node3D]

@export_group("Animation Settings")
@export_range(1,10, 0.1) var animation_transition_time : float = 5.0

@export_group("Visual Settings")
@export var active_color : Color
@export var inactive_color : Color
@export_range(1,10, 0.1) var color_transition_time : float = 5.0

@onready var orb : MeshInstance3D = $revitalize_statue/orb
@onready var animation_tree : AnimationTree = $revitalize_statue/AnimationTree

var animation_value : float
var color_value : Color

var target_color_value : Color
var local_timer : Timer

static var is_one_active : bool

func _ready() -> void:
	_kill_objects(null)
	on_player_interact.connect(_revive_objects)

	var material = orb.mesh.surface_get_material(0)
	orb.set_surface_override_material(0,material.duplicate())
	super()

func _process(delta : float) -> void:
	_update_animation_state(delta)
	_update_orb_color(delta)

func _set_object_state(new_state : bool, player : Player) -> void:
	for obj in objects_to_affect:
		if obj is PlayerDetector && player:
			obj.reset_detector(player)

		obj.process_mode = 0 if new_state else 4
		if new_state:
			obj.show()
		else:
			obj.hide()



func _revive_objects(player : Player) -> void:
	if is_one_active:
		return

	is_one_active = true
	local_timer = Timer.new()
	add_child(local_timer)
	local_timer.start(duration_in_seconds)
	local_timer.timeout.connect(_kill_objects.bind(player))
	_set_object_state(true, player)

	set_color_on_orb(active_color)
	set_animation_state_on_orb(true)

func _kill_objects(player : Player) -> void:
	if local_timer:
		local_timer.queue_free()
	_set_object_state(false, player)

	set_color_on_orb(inactive_color)
	set_animation_state_on_orb(false)
	is_one_active = false

func set_color_on_orb(new_color : Color) -> void:
	target_color_value = new_color


func set_animation_state_on_orb(new_state : bool) -> void:
	animation_value = 1.0 if new_state else 0.0


func _update_animation_state(delta : float) -> void:
	const ANIMATION_SET_STATE := "parameters/Set_State/blend_amount"

	var cur_val : float = animation_tree.get(ANIMATION_SET_STATE)
	cur_val = lerp(cur_val, animation_value, animation_transition_time * delta)
	animation_tree.set(ANIMATION_SET_STATE, cur_val)

func _update_orb_color(delta : float) -> void:
	const ALBEDO_COLOR := "albedo_color"
	const EMISSION_COLOR := "emission"

	color_value = lerp(color_value, target_color_value, color_transition_time * delta)
	orb.get_surface_override_material(0).set(ALBEDO_COLOR, color_value)
	orb.get_surface_override_material(0).set(EMISSION_COLOR, color_value)

func manually_kill_objects(player : Player) -> void:
	if local_timer:
		local_timer.stop()
	_kill_objects(player)
