extends Node

class_name Global

static var peer_data: Dictionary = {}

static var myid = 1

static var userdata = {
	"username": "",
	"color": "",
	"photo": ""
}

enum peer_status{
	HOSTING,
	CONNECTING,
	CONNECTED,
	DISCONNECTED
}
static var status = peer_status.DISCONNECTED

static func get_peer_data(id, key):
	if id in peer_data:
		var ret = peer_data[id][key]
		#if ret != null: print(ret)
		return ret
	elif id == myid:
		return userdata[key]
	else:
		print("ERROR: No se encuentra la propiedad \"", key, "\" en los datos de ID ", id)
		return null


static func get_formatted_username(id) -> String:
	#if peer_data.size() != 0: ## Si está conectado, algo tiene que haber en peer_data
	#return "ERROR_NO_EXISTE_ID"
	var username = get_peer_data(id, "username")
	
	if username != null:
		return ("[color=" + get_peer_data(id, "color").to_html() + "]" + username + "[/color]")
	else:
		return "<Usuario>"
		
	#if id in peer_data:
		#return ("[color=" + peer_data[id].color.to_html() + "]" + peer_data[id].username + "[/color]")
	#elif id == 1:
		#return ("[color=" + userdata.color.to_html() + "]" +
			#userdata.username + "[/color]")
	#else:
		#print("Error: intento de acceder a clave inexistente " + str(id) + " en peer_data")


static func status_connected():
	return status == peer_status.CONNECTED or status == peer_status.HOSTING

