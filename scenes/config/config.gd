extends ColorRect

@onready var connection = $Center/Panel/margin/cont/Connect
@onready var perfil = $Center/Panel/margin/cont/Perfil
@onready var misc = $Center/Panel/margin/cont/Misc


signal request_update_peer

func _ready():
	load_data()


func get_net_data():
	connection.return_data()
	perfil.return_data()
	misc.return_data()


func load_data():
	var cfg = ConfigFile.new()
	var err = cfg.load("userdata.cfg")
	
	# Si el archivo de configuración no existe, dar la bienvenida
	if err != OK:
		push_warning("No se pudo cargar el archivo de configuración")
		$WelcomeScreen.show()
		select_connect_configs()
		show()
	
	# Tomar los valores del archivo de configuración, o bien los fallbacks si este no existe
	Global.ip = cfg.get_value("connection", "ip", connection.default_ip)
	Global.port = cfg.get_value("connection", "port", connection.default_port)
	Global.userdata.username = cfg.get_value("user", "name", "Peer")
	Global.userdata.color = cfg.get_value("user", "color", Color(randf(), randf(), randf()))
	Global.open_notif = cfg.get_value("misc", "open_notif_sounds", true)
	Global.auto_update = cfg.get_value("misc", "auto_update", true)
	
	# Setear los controles a los valores cargados
	connection.init()
	perfil.init(cfg.get_value("user", "photo", ""))
	misc.init()

func save_data():
	var cfg = ConfigFile.new()
	
	cfg.set_value("user", "name", Global.userdata.username)
	cfg.set_value("user", "color", Global.userdata.color)
	cfg.set_value("user", "photo", perfil.photopath)
	cfg.set_value("connection", "ip", Global.ip)
	cfg.set_value("connection", "port", Global.port)
	cfg.set_value("misc", "open_notif_sounds", Global.open_notif)
	cfg.set_value("misc", "auto_update", Global.auto_update)
	
	cfg.save("userdata.cfg")


func select_connect_configs():
	connection.show()
	perfil.hide()
	misc.hide()
	$Center/Panel/margin/cont/ConfigList.select(0)

func select_profile_configs():
	connection.hide()
	perfil.show()
	misc.hide()
	$Center/Panel/margin/cont/ConfigList.select(1)

func select_personalization_configs():
	perfil.hide()
	connection.hide()
	misc.show()
	$Center/Panel/margin/cont/ConfigList.select(2)

func _on_config_list_item_selected(index):
	match index:
		0: select_connect_configs()
		1: select_profile_configs()
		2: select_personalization_configs()



func _on_close_pressed():
	get_net_data()
	request_update_peer.emit()
	hide()


func _on_welcome_screen_close_requested():
	$WelcomeScreen.hide()


func _on_misc_request_open_help():
	$WelcomeScreen.show()


func _on_rich_text_label_meta_clicked(meta):
	OS.shell_open(meta)
