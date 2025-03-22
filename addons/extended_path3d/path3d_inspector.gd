extends EditorInspectorPlugin

enum MIRROR_TYPE {
	X_AXIS, Y_AXIS, Z_AXIS
}

const PATH_3D_INSPECTOR = preload("res://addons/extended_path3d/path3d_inspector.tscn")





var undo_redo : EditorUndoRedoManager

var new_curve : Curve3D
var old_curve : Curve3D

func get_undo_redo(undo_redo : EditorUndoRedoManager) -> void:
	self.undo_redo = undo_redo



func _can_handle(object):
	return object is Path3D  # Only show for Path3D nodes

func _parse_category(object : Variant, category : String):
	if category != "Path3D":
		return
	var inspector = PATH_3D_INSPECTOR.instantiate()

	var x_mirror = inspector.get_node("order/x_mirror")
	var y_mirror = inspector.get_node("order/y_mirror")
	var z_mirror = inspector.get_node("order/z_mirror")

	x_mirror.button_down.connect(mirror_curve.bind(object, MIRROR_TYPE.X_AXIS))
	y_mirror.button_down.connect(mirror_curve.bind(object, MIRROR_TYPE.Y_AXIS))
	z_mirror.button_down.connect(mirror_curve.bind(object, MIRROR_TYPE.Z_AXIS))

	add_custom_control(inspector)

func mirror_curve(path: Path3D, type : MIRROR_TYPE):
	if !path.curve:
		return

	undo_redo.create_action("Mirror %s" % type)

	old_curve = path.curve
	new_curve = Curve3D.new()

	for i in range(old_curve.point_count):
		var point = old_curve.get_point_position(i)
		if type == MIRROR_TYPE.X_AXIS:
			point.x = -point.x  # Mirroring X-axis
		elif type == MIRROR_TYPE.Y_AXIS:
			point.y = -point.y
		elif type == MIRROR_TYPE.Z_AXIS:
			point.z = -point.z

		new_curve.add_point(point, old_curve.get_point_in(i), old_curve.get_point_out(i))

	undo_redo.add_do_property(path, "curve", new_curve)
	undo_redo.add_undo_property(path, "curve", old_curve)
	undo_redo.commit_action()
	print("Mirrored Path3D Curve on %s!" % type)
