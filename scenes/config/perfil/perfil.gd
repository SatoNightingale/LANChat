extends VBoxContainer


@onready var defaultphoto = preload("res://scenes/config/perfil/default.png")
@onready var photo_mask = preload("res://scenes/config/perfil/photo_mask.png")
var photopath: String
var photo_max: Image


func init(path):
	photopath = path
	
	set_photo()
	
	_on_color_picker_color_changed(Global.userdata.color)
	
	$Name.text = Global.userdata.username
	$Color/ColorPicker.color = Global.userdata.color
	$Photo.texture = ImageTexture.create_from_image(photo_max)
	
	Global.format_my_username()


func return_data():
	if $Name.text:
		Global.userdata.username = $Name.text
	
	Global.userdata.color = $Color/ColorPicker.color
	
	Global.format_my_username()
	
	Global.userdata.photo = photomax_to_userphoto()


func set_photo():
	photo_max = Image.new()
	var err = photo_max.load(photopath)
	
	if err:
		photo_max = defaultphoto.get_image()
		photopath = ""
	
	Global.userdata.photo = photomax_to_userphoto()



func _on_photo_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			DisplayServer.file_dialog_show("Buscar imagen", ".", "", false, \
				DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, \
				["*.png, *.jpg, *.jpeg, *.bmp", "*"], imagecallback)

func imagecallback(status, selected_paths, _selected_filter_index):
	if status:
		photopath = selected_paths[0]
		photo_max = Image.load_from_file(photopath)
		var _err = photo_max.generate_mipmaps() ##
		
		$Photo.texture = ImageTexture.create_from_image(photo_max)


func photomax_to_userphoto():
	var photo: Image = photo_max.duplicate()
	var w = photo.get_width()
	var h = photo.get_height()
	var lado_m = mini(w, h)
	
	match lado_m:
		h:
			photo = photo.get_region(Rect2i((w - lado_m) / 2, 0, lado_m, lado_m))
		w:
			photo = photo.get_region(Rect2i(0, (h - lado_m) / 2, lado_m, lado_m))
	
	photo.resize(40, 40, Image.INTERPOLATE_LANCZOS)
	
	return photo




func _on_name_text_submitted(_new_text):
	$Name.release_focus()


func _on_color_picker_color_changed(ncolor):
	$Name.add_theme_color_override("font_color", ncolor)


func _on_randomize_pressed():
	var random_color = Color(randf(), randf(), randf())
	$Color/ColorPicker.color = random_color
	_on_color_picker_color_changed(random_color)
