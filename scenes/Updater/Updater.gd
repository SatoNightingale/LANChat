extends HTTPRequest


var updated_peer

func match_peer_versions(my_ver, ext_ver, matching_peer):
	if ext_ver == null:
		push_warning("El peer no tiene módulo de actualización automática")
		return
	
	var higher = versions_different(my_ver, ext_ver)
	print("higer: ", higher)
	
	if higher != 0:
		## Preguntarle al usuario si quiere actualizar
		## Si higher es 1, yo tengo la mayor versión. Si higher es 2, él tiene la mayor versión
		if higher == 1:
			ask_update_peer_confirmation.rpc_id(matching_peer, multiplayer.get_unique_id())
			#send_pck(matching_peer)
		if higher == 2:
			ask_update_peer_confirmation(matching_peer)
			#send_pck.rpc_id(matching_peer, multiplayer.get_unique_id())


func versions_different(ver1, ver2):
	var version1 = ver1.split(".")
	var version2 = ver2.split(".")
	
	for i in range(0, 4):
		print("version1[", str(i), "] = ", version1[i], " - version2[", str(i), "] = ", version2[i])
		if version1[i] != version2[i]:
			return 1 if (version1[i] > version2[i]) else 2
	
	return 0


## Esto siempre se llama en el peer que debe recibir el pck
@rpc("any_peer")
func ask_update_peer_confirmation(upd_peer):
	$Confirm_AutoUpdPeer.show()
	updated_peer = upd_peer

func _on_confirm_auto_upd_peer_confirmed():
	send_pck.rpc_id(updated_peer, multiplayer.get_unique_id())



@rpc("any_peer")
func send_pck(id):
	var pck_name = OS.get_executable_path().get_basename() + ".pck"
	## Mostrar opcionalmente una ventana de progreso de la actualización (¿cómo pinga se hará eso?)
	print("pck_name: ", pck_name)
	if FileAccess.file_exists(pck_name):
		var pck = FileAccess.get_file_as_bytes(pck_name)
		receive_pck.rpc_id(id, pck)
	else:
		push_error("El archivo .pck no existe")


@rpc("any_peer", "reliable")
func receive_pck(pckdata: PackedByteArray):
	var pck_name = OS.get_executable_path().get_basename() + ".pck"
	
	print("pck_name: ", pck_name)
	if FileAccess.file_exists(pck_name):
		DirAccess.remove_absolute(pck_name)
		var new_pck = FileAccess.open(pck_name, FileAccess.WRITE)
		new_pck.store_buffer(pckdata)
		
		OS.set_restart_on_exit(true)
		get_tree().quit()
	else:
		push_error("El archivo .pck no existe")
