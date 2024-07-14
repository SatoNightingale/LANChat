extends "res://scenes/network.gd"



func _on_peer_connected(id):
	if id != 1:
		print("connected peer: ", id)


func _on_peer_disconnected(id):
	if id != 1:
		print("disconnected peer: ", id)
		add_local_message("{" + str(id) + "} se ha desconectado")
	
	peer_data.erase(id)
	sidebar.update_peerlist()


func _on_connected_to_server():
	set_myid(multiplayer.get_unique_id())
	
	## Cuando me conecto al servidor, le mando mi información y este
	## la envía a todos los demás peers
	add_me_to_server.rpc_id(1, var_to_bytes_with_objects(userdata))
	
	print("connected to server")
	add_local_message("Conectado")
	
	topbar.set_status(Global.peer_status.CONNECTED)


func _on_connection_failed():
	print("connection failed")
	add_local_message("Conexión fallida. Por favor revisa el IP y el puerto, e intenta conectarte de nuevo")
	
	topbar.set_status(Global.peer_status.DISCONNECTED)


func _on_server_disconnected():
	print("server disconnected")
	add_local_message("Servidor desconectado")
	
	on_disconnected()







func _ready():
	connect_network_signals()
	
	topbar.request_config.connect(func(): $Config.show())
	
	Global.userdata.version = ProjectSettings.get_setting("application/config/version")
	
	get_tree().root.title = "LANChat v" + str(Global.userdata.version)
	
	#list_interfaces()


func connect_network_signals():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)


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
