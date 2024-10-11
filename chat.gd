extends Node

signal settings_applied(settings: ChatSettings)
var username: String = ""
@onready var scroll_bar = $Scrollable.get_v_scroll_bar()

func scroll_to_the_end():
	await scroll_bar.changed
	scroll_bar.set_value_no_signal(scroll_bar.max_value)

func _ready():
	if FileAccess.file_exists("user://nickname"):
		username = FileAccess.open("user://nickname", FileAccess.READ).get_line()
	if username == "":
		username = "[анон]"
	$Control/SetUsernameButton.text = username
	multiplayer.peer_connected.connect(_on_peer_connected)

	var peer = ENetMultiplayerPeer.new()
	if OS.has_feature("dedicated_server"):
		peer.create_server(1488, 100)
		multiplayer.multiplayer_peer = peer
		init_chats.rpc(1)
	else:
		peer.create_client("194.87.102.218", 1488)
		multiplayer.multiplayer_peer = peer
		
	apply_settings()
	scroll_to_the_end()

func _process(_delta):
	if is_equal_approx(scroll_bar.value, scroll_bar.max_value - 620.0):
		$ScrollDownButton.hide()
	else:
		$ScrollDownButton.show()

@rpc("any_peer", "call_local", "reliable")
func update_message_list(who, what) -> void:
	var msg = Message.create_message(who, what)
	settings_applied.connect(msg.on_settings_applied)
	%MessageList.add_child(msg)

@rpc("authority", "call_local", "reliable")
func init_chats(id: int) -> void:
	var file = FileAccess.open("user://chat.txt", FileAccess.READ)
	while file.get_position() < file.get_length():
		var msg = file.get_line().split(":", true, 1)
		update_message_list.rpc_id(id, msg[0], msg[1])
	scroll_to_the_end()

@rpc("any_peer", "call_local", "reliable")
func max_verstappen() -> void:
	$Blastilka.play()

@rpc("any_peer", "call_local", "reliable")
func chay_postavte() -> void:
	$ChayPostavte.play()

func _on_peer_connected(id: int):
	if multiplayer.is_server():
		init_chats.rpc_id(1, id)

func send_message():
	if %TextField.text == "":
		return
	var txt: String = %TextField.text
	%TextField.text = txt.replace(":what:", "[img]res://what.webp[/img]")
	if %TextField.text.to_lower() == "чай поставьте":
		chay_postavte.rpc()
	if %TextField.text.containsn("max") or %TextField.text.containsn("макс"):
		max_verstappen.rpc()
	if %TextField.text.containsn("fumo"):
		retrieve_from_server("untitled.png")
	update_message_list.rpc(username, %TextField.text)
	%TextField.text = ""
	scroll_to_the_end()

func _on_set_username_button_pressed():
	$UsernameDialog.show()

func _on_line_edit_text_submitted(new_text):
	FileAccess.open("user://nickname", FileAccess.WRITE).store_line(new_text)
	username = new_text
	$Control/SetUsernameButton.text = username
	$UsernameDialog.hide()

func _on_text_field_text_submitted(_new_text):
	send_message()

func _on_timer_timeout():
	if multiplayer.is_server():
		var file = FileAccess.open("user://chat.txt", FileAccess.WRITE)
		for child in %MessageList.get_children():
			var msg := child as Message
			file.store_line(msg.who + ":" + msg.what)
		print("Stored %s messages" % %MessageList.get_child_count())

func apply_settings() -> void:
	settings_applied.emit($Settings)

func on_settings_applied(settings: ChatSettings) -> void:
	$Background/BackgroundColor.color = settings.background_color
	$Background/BackgroundTexture.texture = settings.background_image

func _on_settings_popup_popup_hide():
	apply_settings()

func _on_scroll_down_button_pressed():
	scroll_bar.value = scroll_bar.max_value


func _on_file_pick_pressed() -> void:
	$FilePick/FileDialog.show()
	


func _on_file_dialog_file_selected(path: String) -> void:
	transfer.rpc_id(1,FileAccess.get_file_as_bytes(path), path.get_file())
	print("Send_file: ", Time.get_ticks_msec())

@rpc("any_peer", "reliable", "call_local")
func transfer(data: PackedByteArray, filename: String) -> void:
	print("write_file: ", Time.get_ticks_msec())
	var sfile = FileAccess.open("user://" + filename, FileAccess.WRITE)
	sfile.store_buffer(data)
	print("received file")


func retrieve_from_server(filename: String):
	transfer.rpc_id(multiplayer.get_remote_sender_id(), FileAccess.get_file_as_bytes("user://" + filename), filename)
	
