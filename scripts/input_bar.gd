extends HBoxContainer

var reply_id = -1

signal send_message(text: String, reply: int)


func _on_close_pressed():
	$Write/ReplyContainer.hide()
	reply_id = -1


func _on_msg_edit_gui_input(event):
	if event.is_action_pressed("add_newline"):
		$Write/MsgEdit.insert_text_at_caret("\n")
	elif event.is_action_pressed("submit"):
		get_viewport().set_input_as_handled()
		_on_send_button_pressed()


func _on_send_button_pressed():
	send_message.emit($Write/MsgEdit.text, reply_id)
	
	$Write/MsgEdit.clear()
	reply_id = -1
	
	$Write/ReplyContainer/margin/Text/margin/cont/Reply.clear()
	$Write/ReplyContainer.hide()


func set_reply(message):
	reply_id = message.msg_id
	
	$Write/ReplyContainer.show()
	$Write/ReplyContainer/margin/Text/margin/cont/Reply.clear()
	
	$Write/ReplyContainer/margin/Text/margin/cont/Reply.text = \
		Global.get_formatted_username(message.sender_id) + ": " + \
		message.text
