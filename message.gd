class_name Message
extends Control

var who: String:
	get:
		return %LabelWho.text
	set(value):
		%LabelWho.text = value

var what: String:
	get:
		return %LabelWhat.text
	set(value):
		%LabelWhat.text = value

static func create_message(strWho, strWhat) -> Message:
	var msg: Message = load("res://message.tscn").instantiate()
	msg.who = strWho
	msg.what = strWhat
	return msg

func on_settings_applied(settings: ChatSettings) -> void:
	%LabelWho.add_theme_color_override("font_color", settings.text_username_color)
	%LabelWhat.modulate = settings.text_message_color
