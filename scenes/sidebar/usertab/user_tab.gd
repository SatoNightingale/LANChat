extends PanelContainer

var user_id

signal beep_user(id)

func update(id):
	user_id = id
	
	$Container/Name/Label.text = Global.get_formatted_username(user_id)
	$Container/Name/Label.tooltip_text = Global.get_peer_data(user_id, "username")
	
	$Container/Photo/Mask/Image.texture = ImageTexture.create_from_image(
		Global.get_peer_data(user_id, "photo"))


func _on_button_pressed():
	beep_user.emit(user_id)
