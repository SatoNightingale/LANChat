extends Node

class_name Global

static var ip
static var port
const MAX_CONNECTIONS = 20

static var peer_data: Dictionary = {}

static var myid = 1:
	set(id):
		formatted_usernames.erase(myid)
		myid = id
		formatted_usernames[myid] = userdata.formatted_username


static var userdata = {
	"username": "",
	"color": "",
	"photo": "",
	"version": ""
}

static var formatted_usernames = {}

enum peer_status{
	HOSTING,
	CONNECTING,
	CONNECTED,
	DISCONNECTED
}
static var status = peer_status.DISCONNECTED

static var open_notif = true
static var auto_update = true


static func get_peer_data(id, key):
	if id in peer_data:
		var ret = peer_data[id][key]
		#if ret != null: print(ret)
		return ret
	elif id == myid:
		return userdata[key]
	else:
		push_error("No se encuentra la propiedad \"", key, "\" en los datos de ID ", id)
		return null


static func add_peer_data(id, data):
	peer_data[id] = data
	formatted_usernames[id] = data.formatted_username


static func get_formatted_username(id) -> String:
	#if peer_data.size() != 0: ## Si está conectado, algo tiene que haber en peer_data
	#return "ERROR_NO_EXISTE_ID"
	
	#var username = get_peer_data(id, "username")
	#
	#if username != null:
		#return ("[color=" + get_peer_data(id, "color").to_html() + "]" + username + "[/color]")
	#else:
		#return "<Usuario>"
	
	if id in peer_data:
		return peer_data[id].formatted_username
	elif id == myid:
		return userdata.formatted_username
	else:
		push_error("No se encuentra el ID ", str(id))
		return "<Usuario>"


static func format_my_username():
	userdata.formatted_username = "[color=" + userdata.color.to_html() + "]" + userdata.username + "[/color]"


static func status_connected():
	return status == peer_status.CONNECTED or status == peer_status.HOSTING

