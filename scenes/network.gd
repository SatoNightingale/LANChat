extends Control

var peer_data = Global.peer_data
var userdata = Global.userdata

@onready var msgarea = $margin/Frame/Main/MsgArea
@onready var sidebar = $margin/Frame/Main/Sidebar
@onready var topbar = $margin/Frame/TopBar



func add_local_message(message):
	msgarea.add_message("[center]" + message + "[/center]")

func add_program_message(id, message):
	msgarea.add_program_message.rpc_id(id, "[center]" + message + "[/center]")

func set_myid(id):
	var old_id = Global.myid
	Global.myid = id
	msgarea.update_user_id(old_id, id)


@rpc("any_peer", "call_local", "reliable")
func update_peer(bytedata, id = 0):
	if id == 0:
		id = multiplayer.get_remote_sender_id()
	
	var data = bytes_to_var_with_objects(bytedata)
	#peer_data[id] = data
	
	Global.add_peer_data(id, data)
	
	sidebar.update_peerlist()
	msgarea.update_user_messages(id)


@rpc("any_peer", "call_local", "reliable")
func add_me_to_server(bytedata):
	var new_id = multiplayer.get_remote_sender_id()
	
	var data = bytes_to_var_with_objects(bytedata)
	
	if Global.auto_update:
		await $Updater.match_peer_versions(Global.userdata.version, data.version, new_id)
	
	#peer_data[new_id] = data
	Global.add_peer_data(new_id, data)
	
	if multiplayer.is_server():
		for id in peer_data:
			## El nuevo se actualiza con todos los ID's
			update_peer.rpc_id(new_id, var_to_bytes_with_objects(peer_data[id]), id) ##
			## Cada ID se añade al nuevo
			update_peer.rpc_id(id, var_to_bytes_with_objects(peer_data[new_id]), new_id)
			
			## Notificar a cada ID, menos el que acaba de entrar
			if id != new_id:
				add_program_message(id, "{" + str(new_id) + "} se ha unido al chat")
		
		## Sincronizamos el índice de mensajes para tener los mismos IDs de mensajes
		msgarea.set_msgindex.rpc_id(new_id, msgarea.msg_index)


func _on_request_host():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(Global.port, Global.MAX_CONNECTIONS)
	multiplayer.multiplayer_peer = peer
	
	topbar.set_status(Global.peer_status.HOSTING)
	Global.myid = 1
	
	#peer_data[1] = userdata
	Global.add_peer_data(1, userdata)
	sidebar.update_peerlist()


func _on_request_connect():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(Global.ip, Global.port)
	multiplayer.multiplayer_peer = peer
	
	topbar.set_status(Global.peer_status.CONNECTING)


func _on_request_update_peer():
	if Global.status_connected():
		update_peer.rpc(var_to_bytes_with_objects(userdata))
	else:
		msgarea.update_user_messages(Global.myid)


func _on_request_disconnect():
	multiplayer.multiplayer_peer = null
	
	add_local_message("Te desconectaste")
	
	on_disconnected()


func on_disconnected():
	topbar.set_status(Global.peer_status.DISCONNECTED)
	
	peer_data.clear()
	Global.formatted_usernames.clear() ##
	
	sidebar.update_peerlist()



func _on_sidebar_beep_user(id):
	if id != Global.myid:
		msgarea.send_beep.rpc(Global.myid, id)
		msgarea.beep_user.rpc_id(id)



func _on_tree_exiting():
	$Config.save_data()


