extends VBoxContainer

var label: PackedScene = preload("res://scenes/msg line.tscn")
var reply ## el objeto message al que responde este mensaje

signal respond_msg(line)
signal goto_ref_line(line)

func init(senderid, firstline, onrespond, onclick):
	update_user(senderid)
	add_line(firstline)
	respond_msg.connect(onrespond)
	goto_ref_line.connect(onclick)

func update_user(id):
	$Box/Msgbox/Username.text = Global.get_formatted_username(id)
	$Box/PhotoMask/Photo.texture = ImageTexture.create_from_image(
		Global.get_peer_data(id, "photo"))



func set_reply(rep_msg):
	reply = rep_msg
	$Reply.show()
	$Reply/Label.text = Global.get_formatted_username(rep_msg.sender_id) + \
		": " + rep_msg.text
	$Reply/Label.visible_characters = 45

func _on_line_selected(who):
	respond_msg.emit(who)

func _on_line_clicked(who):
	goto_ref_line.emit(who)

func add_line(msg):
	var line = label.instantiate()
	
	line.init(msg, $Box/Msgbox/Lines, _on_line_selected)
	msg.talk = self
	
	return line


func _on_label_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			goto_ref_line.emit(reply.talk)
			reply.label.resaltar()
