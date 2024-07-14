extends RichTextLabel

signal replyed(label)

var message ## el objeto mensaje que contiene esta línea
var resalt_tween ## Tween para animar el ColorRect

func init(msg, parent, onreply):
	message = msg
	msg.label = self
	text = msg.text
	parent.add_child(self)
	replyed.connect(onreply)

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			replyed.emit(self)
			resaltar()


func resaltar():
	$ColorRect.color.a = 1.0
	$ColorRect.show()
	
	if resalt_tween:
		resalt_tween.kill()
	
	resalt_tween = create_tween()
	resalt_tween.tween_property($ColorRect, "color:a", 0, 1).set_trans(Tween.TRANS_SINE)
	resalt_tween.tween_callback($ColorRect.hide)
