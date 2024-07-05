extends PanelContainer

var tab_scene = preload("res://scenes/user_tab.tscn")

var usertabs = {}

signal beep_user(id)


func update_peerlist():
	for peer in Global.peer_data:
		if peer in usertabs:
			usertabs[peer].update(peer)
		else:
			var new_tab = tab_scene.instantiate()
			new_tab.beep_user.connect(_on_user_tab_beep_user)
			
			new_tab.update(peer)
			
			usertabs[peer] = new_tab
			
			$margin/container.add_child(new_tab)
	
	## Borra los usuarios que salieron del chat
	for tab in usertabs.keys():
		if not (tab in Global.peer_data):
			$margin/container.remove_child(usertabs[tab])
			usertabs.erase(tab)


func _on_user_tab_beep_user(id):
	beep_user.emit(id)
