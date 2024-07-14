extends VBoxContainer

const default_port = 7001
const default_ip = "127.0.0.1" # IPv4 localhost

signal request_host
signal request_connect


func init():
	$IPbox/LineEdit.text = Global.ip
	$Portbox/LineEdit.text = str(Global.port)


func return_data():
	if $IPbox/LineEdit.text:
		Global.ip = $IPbox/LineEdit.text
	else: Global.ip = default_ip
	
	if $Portbox/LineEdit.text:
		Global.port = int($Portbox/LineEdit.text)
	else: Global.port = default_port


func _on_host_pressed():
	request_host.emit()


func _on_connect_pressed():
	request_connect.emit()
