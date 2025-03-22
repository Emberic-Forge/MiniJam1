extends Node

signal on_pause
signal on_resume

func resume() -> void:
	get_tree().paused = false
	on_resume.emit()


func pause() -> void:
	get_tree().paused = true
	on_pause.emit()

func is_paused() -> bool:
	return get_tree().paused
