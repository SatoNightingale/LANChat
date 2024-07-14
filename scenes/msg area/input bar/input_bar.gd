extends HBoxContainer

var reply = null

signal send_message(text: String, reply: int)
signal goto_ref_line(line)

func _on_close_pressed():
	$Write/ReplyContainer.hide()
	reply = null


func _on_msg_edit_gui_input(event):
	if event.is_action_pressed("add_newline"):
		$Write/MsgEdit.insert_text_at_caret("\n")
	elif event.is_action_pressed("submit"):
		get_viewport().set_input_as_handled()
		_on_send_button_pressed()


func _on_send_button_pressed():
	send_message.emit($Write/MsgEdit.text, reply.msg_id if (reply != null) else -1)
	
	$Write/MsgEdit.clear()
	reply = null
	
	$Write/ReplyContainer/margin/Text/margin/cont/Reply.clear()
	$Write/ReplyContainer.hide()


func set_reply(message):
	reply = message
	
	$Write/ReplyContainer.show()
	$Write/ReplyContainer/margin/Text/margin/cont/Reply.clear()
	
	$Write/ReplyContainer/margin/Text/margin/cont/Reply.text = \
		Global.get_formatted_username(message.sender_id) + ": " + message.text


func _on_reply_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			goto_ref_line.emit(reply)
