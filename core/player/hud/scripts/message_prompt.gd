class_name MessagePrompt extends RichTextLabel

@export var prompts : Dictionary[String, CompressedTexture2D]

func set_prompt(message : String) -> void:
	var result : String = ""
	for line in message.split(" "):
		var new_line : String = ""
		var img : CompressedTexture2D = get_prompt_image(line)
		if img:
			new_line = "[img=32x32]%s[/img]" % img.resource_path
		else:
			new_line = line + " "

		result += new_line
	text = result

func reset_prompt() -> void:
	text = ""

func get_prompt_image(line : String) -> CompressedTexture2D:
	for entry in prompts.keys():
		if line.contains("[%s]" % entry):
			return prompts[entry]
	return null
