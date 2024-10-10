extends Node

var username: String = "[анон]"

func scroll_to_the_end():
	await $Scrollable.get_v_scroll_bar().changed
	$Scrollable.get_v_scroll_bar().set_value_no_signal($Scrollable.get_v_scroll_bar().max_value)

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)

	var peer = ENetMultiplayerPeer.new()
	if OS.has_feature("dedicated_server"):
		peer.create_server(1488, 100)
		multiplayer.multiplayer_peer = peer
		init_chats.rpc(1)
	else:
		peer.create_client("194.87.102.218", 1488)
		multiplayer.multiplayer_peer = peer

@rpc("any_peer", "call_local", "unreliable")
func update_message_list(who, what) -> void:
	%MessageList.add_child(Message.create_message(who, what))

@rpc("authority", "call_local", "unreliable")
func init_chats(id: int)->void :
	var file = FileAccess.open("user://chat.txt", FileAccess.READ)
	while file.get_position() < file.get_length():
		var msg = file.get_line().split(":", true, 1)
		update_message_list.rpc_id(id, msg[0], msg[1])
	scroll_to_the_end()

func _on_peer_connected(id: int):
	if multiplayer.is_server():
		init_chats.rpc_id(1, id)

func send_message():
	if %TextField.text == "":
		return
	update_message_list.rpc(username, %TextField.text)
	%TextField.text = ""
	scroll_to_the_end()

func _on_set_username_button_pressed():
	$UsernameDialog.show()

func _on_line_edit_text_submitted(new_text):
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
