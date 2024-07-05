extends Control

var peer_data = Global.peer_data
var userdata = Global.userdata

@onready var msgarea = $margin/Frame/Main/MsgArea
@onready var sidebar = $margin/Frame/Main/Sidebar
@onready var topbar = $margin/Frame/TopBar

func connect_network_signals():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	

func _ready():
	connect_network_signals()
	
	topbar.request_config.connect(func(): $Config.show())
	
	get_tree().root.title = "LANChat v1.2"
	
	#list_interfaces()


func add_message(message):
	msgarea.add_message(message)


@rpc("any_peer", "call_local", "reliable")
func update_peer(bytedata, id = 0):
	if id == 0: # llamada rpc
		id = multiplayer.get_remote_sender_id()
		
	var data = bytes_to_var_with_objects(bytedata)
	peer_data[id] = data
	
	sidebar.update_peerlist()
	msgarea.update_user_messages(id)


@rpc("any_peer", "call_local", "reliable")
func add_me_to_server(bytedata):
	var new_id = multiplayer.get_remote_sender_id()
	#update_peer(data, new_id) ## Modelo 1
	var data = bytes_to_var_with_objects(bytedata)
	peer_data[new_id] = data
	
	add_message("[center]" + Global.get_formatted_username(new_id) + " se ha unido al chat[/center]")
	
	if multiplayer.is_server(): # Modelo 2
		#for id in peer_data:
			#update_peer.rpc(var_to_bytes_with_objects(peer_data[id]), id) ##
		
		for id in peer_data:
			## El nuevo se actualiza con todos los ID's
			update_peer.rpc_id(new_id, var_to_bytes_with_objects(peer_data[id]), id) ##
			## Cada ID se añade al nuevo
			update_peer.rpc_id(id, var_to_bytes_with_objects(peer_data[new_id]), new_id)


func _on_request_host():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server($Config.port, $Config.MAX_CONNECTIONS)
	multiplayer.multiplayer_peer = peer
	
	topbar.set_status(Global.peer_status.HOSTING)
	Global.myid = 1
	
	peer_data[1] = userdata
	sidebar.update_peerlist()


func _on_request_connect():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client($Config.ip, $Config.port)
	multiplayer.multiplayer_peer = peer
	
	topbar.set_status(Global.peer_status.CONNECTING)


func _on_request_update_peer():
	if Global.status_connected():
		update_peer.rpc(var_to_bytes_with_objects(userdata))


func _on_request_disconnect():
	multiplayer.multiplayer_peer = null
	
	add_message("[center]Te desconectaste[/center]")
	
	on_disconnected()


func on_disconnected():
	topbar.set_status(Global.peer_status.DISCONNECTED)
	
	peer_data.clear()
	sidebar.update_peerlist()

func _on_sidebar_beep_user(id):
	if id != Global.myid:
		msgarea.send_beep.rpc(Global.myid, id)
		msgarea.beep_user.rpc_id(id)



#region Network Signals
func _on_peer_connected(id):
	## Modelo 1: Cuando se conecta un peer, todos le mandamos nuestra información a la vez
	#add_me_to_peer.rpc_id(id, userdata)
	
	## Sincronizamos el índice de mensajes para tener los mismos IDs de mensajes
	if multiplayer.is_server():
		msgarea.set_msgindex.rpc_id(id, msgarea.msg_index)
	
	if id != 1:
		print("connected peer: ", id)

func _on_peer_disconnected(id):
	if id != 1:
		print("disconnected peer: ", id)
		add_message("[center]" + Global.get_formatted_username(id) + " se ha desconectado[/center]")
	
	peer_data.erase(id)
	sidebar.update_peerlist()

func _on_connected_to_server():
	## Modelo 2: Cuando me conecto al servidor, le mando mi información y este
	## la envía a todos los demás peers
	Global.myid = multiplayer.get_unique_id()
	
	add_me_to_server.rpc_id(1, var_to_bytes_with_objects(userdata))
	
	print("connected to server")
	add_message("[center]Conectado[/center]")
	
	topbar.set_status(Global.peer_status.CONNECTED)
	
	## Modelo 1
	#var peer_id = multiplayer.get_unique_id()
	#peer_data[peer_id] = userdata

func _on_connection_failed():
	print("connection failed")
	add_message("[center]Conexión fallida. 
		Por favor revisa el IP y el puerto, e intenta conectarte de nuevo[/center]")
	
	topbar.set_status(Global.peer_status.DISCONNECTED)

func _on_server_disconnected():
	print("server disconnected")
	add_message("[center]Servidor desconectado[/center]")
	
	on_disconnected()

#endregion


func _on_tree_exiting():
	$Config.save_data()


func list_interfaces():
	var interfaces = IP.get_local_interfaces()
	print("	Interfaces:")
	for inter in interfaces:
		print(inter.index, ": ", inter.name)
		print("friendly: ", inter.friendly)
		print("addresses(", inter.addresses.size(), "): ")
		for ip in inter.addresses:
			print(ip)
		print("-----------------------")
	
	print("\n	Addresses:")
	for addr in IP.get_local_addresses():
		print(addr)
	print("\n\n")
