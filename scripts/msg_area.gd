extends Node

var msg_talk: PackedScene = preload("res://scenes/msg talk.tscn")
var msg_line: PackedScene = preload("res://scenes/msg line.tscn")

class message:
	var sender_id ## la ID del usuario que envió el mensaje
	var msg_id ## la ID del mensaje
	var text ## el texto del mensaje
	var ref ## referencia al mensaje al que responde este mensaje
	var label: Node ## el msg_line que contiene el texto del mensaje
	var talk: Node ## el msg_talk que contiene este mensaje

var msg_list = {}
var msg_index = 0

var last_talk = null
var last_msg = null
var obj_pulldown = null


@rpc("authority", "reliable")
func set_msgindex(index):
	msg_index = index
	print("My index is ", index, ", received from peer ", multiplayer.get_remote_sender_id())

func update_user_messages(id):
	var msg: message
	
	for elm in msg_list:
		msg = msg_list[elm]
		
		## Si el autor del mensaje es el ID a actualizar,
		if msg.sender_id == id:
			msg.talk.update_user(id)
		## O si hace referencia a un mensaje del ID a actualizar
		if msg.ref:
			if msg.ref.sender_id == id:
					msg.talk.set_reply(msg.ref)


func add_program_message(msg):
	var line = msg_line.instantiate()
	msg.label = line
	line.text = msg.text
	
	$Messages/List.add_child(line)
	return line

func add_message(contenido, id = -1, reply = null):
	var msg = message.new()
	msg.sender_id = id # esto puede dar error si no estoy conectado
	msg.text = contenido
	msg.ref = reply
	
	if id != -1:
		msg.msg_id = msg_index
		
		if !reply and last_msg and last_msg.sender_id == id:
			last_talk.add_line(msg)
		else:
			var talk = msg_talk.instantiate()
			talk.init(id, msg, _on_talk_request_respond_msg, _on_talk_goto_ref_line)
			
			if reply: talk.set_reply(reply)
			
			$Messages/List.add_child(talk, true)
			
			last_talk = talk
		
		msg_list[msg_index] = msg
		last_msg = msg
		msg_index += 1
		obj_pulldown = msg.label
	else:
		obj_pulldown = add_program_message(msg)
		last_talk = null
		last_msg = null
	
	if id == Global.myid:
		bajar_scroll_bar()
	else: pedir_bajar_scrollbar()
	
	play_msg_sound(reply)


func pedir_bajar_scrollbar():
	var scroll_v = $Messages.scroll_vertical
	var page = $Messages.get_v_scroll_bar().page
	var max_scroll = $Messages.get_v_scroll_bar().max_value
	
	if scroll_v + page == max_scroll:
		bajar_scroll_bar()

func bajar_scroll_bar():
	await $Messages.get_v_scroll_bar().changed
	#await get_tree().process_frame
	
	$Messages.ensure_control_visible(obj_pulldown)


func play_msg_sound(reply):
	## sound_msg_in: cuando el programa tiene el focus
	## sound_msg_out: cuando el programa no tiene el focus o está minimizado
	## sound_beep: cuando te responden con el programa minimizado, o cuando te pitan
	if get_tree().root.mode == Window.MODE_MINIMIZED:
		if reply:
			$sound_beep.play()
		else:
			$sound_msg_out.play()
	elif DisplayServer.window_is_focused():
		$sound_msg_in.play()
	else:
		$sound_msg_out.play()

@rpc("any_peer")
func beep_user():
	$sound_beep.play()

@rpc("any_peer", "call_local", "reliable")
func send_beep(sender_id, receiver_id):
	add_message("[center]" + Global.get_formatted_username(sender_id) + \
	" le ha pitado a " + Global.get_formatted_username(receiver_id) + "[/center]")


func _on_talk_request_respond_msg(line):
	$InputBar.set_reply(line.message)

func _on_talk_goto_ref_line(line):
	$Messages.ensure_control_visible(line)


func _on_input_bar_send_message(text, reply):
	if Global.status_connected():
		send_message.rpc(text, reply)
	else:
		send_message(text, reply)


@rpc("any_peer", "call_local", "reliable")
func send_message(Message, reply = -1):
	var id = multiplayer.get_remote_sender_id()
	if id == 0: id = Global.myid
	
	var rep = null
	if (reply in msg_list): rep = msg_list[reply]
		
	add_message(Message, id, rep)



var rdy = false
func _on_messages_resized():
	## El primer resize no se cuenta, es el de inicialización
	if rdy:
		pedir_bajar_scrollbar()
	else:
		rdy = true
