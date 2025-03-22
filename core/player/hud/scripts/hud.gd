class_name HUD extends CanvasLayer

@onready var message_prompt : MessagePrompt = $message_prompt

static var hud_ref : HUD

func _ready() -> void:
	hud_ref = self

static func write_message(message : String) -> void:
	hud_ref.message_prompt.set_prompt(message)
	pass

static func hide_message() -> void:
	hud_ref.message_prompt.reset_prompt()
