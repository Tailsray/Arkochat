class_name ChatSettings
extends Node

var background_color: Color = Color.hex(0x0000ffff)
var background_image: Texture = null
var text_username_color: Color = Color.hex(0x00ff00ff)
var text_message_color: Color = Color.hex(0xffff00ff)

func open_settings() -> void:
	$SettingsPopup.show()

func _on_background_color_picker_color_changed(color: Color) -> void:
	background_color = color

func _on_text_username_color_picker_color_changed(color: Color) -> void:
	text_username_color = color

func _on_text_message_color_picker_color_changed(color: Color) -> void:
	text_message_color = color

func _on_background_image_picker_pressed():
	%BackgroundImagePicker.show()

func _on_background_image_picker_file_selected(path):
	background_image = ImageTexture.create_from_image(Image.load_from_file(path))
	background_image.set_size_override(Vector2i(1280, 720))
