extends ScrollContainer

signal request_open_help


func init():
	$margin/cont/open_notif_sounds.button_pressed = Global.open_notif
	$margin/cont/auto_update.button_pressed = Global.auto_update


func return_data():
	Global.open_notif = $margin/cont/open_notif_sounds.button_pressed
	Global.auto_update = $margin/cont/auto_update.button_pressed



func _on_open_help_pressed():
	request_open_help.emit()
