extends ColorRect

var port = 7001
var ip = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

@onready var ipline = $Center/Panel/margin/cont/Connect/IPbox/LineEdit
@onready var portline = $Center/Panel/margin/cont/Connect/Portbox/LineEdit
@onready var nameline = $Center/Panel/margin/cont/Perfil/Name
@onready var colorbtn = $Center/Panel/margin/cont/Perfil/Color/ColorPicker
@onready var photoframe = $Center/Panel/margin/cont/Perfil/Photo

@onready var defaultphoto = preload("res://icon.svg")
@onready var photo_mask = preload("res://assets/photo_mask.png")
var photopath: String
var photo_max: Image

signal request_host
signal request_connect
signal request_update_peer

func _ready():
	load_data()
	_on_color_picker_color_changed(colorbtn.color)


func get_net_data():
	if nameline.text:
		Global.userdata.username = nameline.text
	
	Global.userdata.color = colorbtn.color
	
	Global.userdata.photo = photo_max.duplicate()
	
	photomax_to_userphoto()
	
	if ipline.text:
		ip = ipline.text
	else: ip = "127.0.0.1"
	
	if portline.text:
		port = int(portline.text)
	else: port = 7001

func load_data():
	var cfg = ConfigFile.new()
	var err = cfg.load("userdata.cfg")
	# Si el archivo de configuración no existe, dar la bienvenida
	if err != OK:
		print("No se pudo cargar el archivo de configuración")
		$WelcomeScreen.show()
		select_connect_config()
		show()
	
	# Tomar los valores del archivo de configuración, o bien los fallbacks si este no existe
	Global.userdata.username = cfg.get_value("user", "name", "Peer")
	Global.userdata.color = cfg.get_value("user", "color", Color(randf(), randf(), randf()))
	
	photopath = cfg.get_value("user", "photo", "")
	
	Global.userdata.photo = Image.new()
	err = Global.userdata.photo.load(photopath)
	
	if err:
		Global.userdata.photo = defaultphoto.get_image()
		photopath = ""
	
	photo_max = Global.userdata.photo.duplicate()
	
	photomax_to_userphoto()
	
	ip = cfg.get_value("connection", "ip", ip)
	port = cfg.get_value("connection", "port", port)
	
	# Setear los controles a los valores cargados
	ipline.text = ip
	portline.text = str(port)
	nameline.text = Global.userdata.username
	colorbtn.color = Global.userdata.color
	photoframe.texture = ImageTexture.create_from_image(photo_max)
	
	_on_color_picker_color_changed(Global.userdata.color)

func save_data():
	var cfg = ConfigFile.new()
	
	cfg.set_value("user", "name", Global.userdata.username)
	cfg.set_value("user", "color", Global.userdata.color)
	cfg.set_value("user", "photo", photopath)
	cfg.set_value("connection", "ip", ip)
	cfg.set_value("connection", "port", port)
	
	cfg.save("userdata.cfg")


func _on_host_pressed():
	request_host.emit()


func _on_connect_pressed():
	request_connect.emit()


func _on_close_pressed():
	get_net_data()
	request_update_peer.emit()
	hide()


func _on_welcome_screen_close_requested():
	$WelcomeScreen.hide()


func _on_name_text_submitted(_new_text):
	nameline.release_focus()


func _on_color_picker_color_changed(ncolor):
	nameline.add_theme_color_override("font_color", ncolor)


func _on_randomize_pressed():
	var random_color = Color(randf(), randf(), randf())
	colorbtn.color = random_color
	_on_color_picker_color_changed(random_color)


func select_connect_config():
	$Center/Panel/margin/cont/Perfil.hide()
	$Center/Panel/margin/cont/Connect.show()
	$Center/Panel/margin/cont/ConfigList.select(0)

func select_profile_config():
	$Center/Panel/margin/cont/Connect.hide()
	$Center/Panel/margin/cont/Perfil.show()
	$Center/Panel/margin/cont/ConfigList.select(1)

func _on_config_list_item_selected(index):
	match index:
		0: select_connect_config()
		1: select_profile_config()


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
		
		photoframe.texture = ImageTexture.create_from_image(photo_max)


func photomax_to_userphoto():
	var photo: Image = Global.userdata.photo
	var w = photo.get_width()
	var h = photo.get_height()
	var lado_m = mini(w, h)
	
	match lado_m:
		h:
			photo = photo.get_region(Rect2i((w - lado_m) / 2, 0, lado_m, lado_m))
		w:
			photo = photo.get_region(Rect2i(0, (h - lado_m) / 2, lado_m, lado_m))
	
	photo.resize(40, 40, Image.INTERPOLATE_LANCZOS)
	
	Global.userdata.photo = photo
