extends PanelContainer

signal request_host
signal request_connect
signal request_config
signal request_break_connection




func set_status(st):
	Global.status = st
	
	match Global.status:
		Global.peer_status.HOSTING:
			$margin/row/PeerState.text = "Servidor"
		Global.peer_status.CONNECTING:
			$margin/row/PeerState.text = "Conectando..."
		Global.peer_status.CONNECTED:
			$margin/row/PeerState.text = "Conectado"
	
	if Global.status != Global.peer_status.DISCONNECTED:
		$margin/row/Connection/Host.hide()
		$margin/row/Connection/Connect.hide()
		$margin/row/Connection/Disconnect.show()
	else:
		$margin/row/PeerState.text = "Desconectado"
		$margin/row/Connection/Host.show()
		$margin/row/Connection/Connect.show()
		$margin/row/Connection/Disconnect.hide()


func _on_host_pressed():
	request_host.emit()


func _on_connect_pressed():
	request_connect.emit()


func _on_config_pressed():
	request_config.emit()


func _on_disconnect_pressed():
	request_break_connection.emit()
	set_status(Global.peer_status.DISCONNECTED)
