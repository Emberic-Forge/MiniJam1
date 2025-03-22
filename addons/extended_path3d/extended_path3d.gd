@tool
extends EditorPlugin

const InspectorPlugin = preload("res://addons/extended_path3d/path3d_inspector.gd")
var inspector_plugin = InspectorPlugin.new()

func _enter_tree():
	inspector_plugin.get_undo_redo(get_undo_redo())
	add_inspector_plugin(inspector_plugin)

func _exit_tree():
	remove_inspector_plugin(inspector_plugin)
	inspector_plugin = null
