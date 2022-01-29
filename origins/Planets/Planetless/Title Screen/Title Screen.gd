extends CanvasLayer

export var clickable = false
var out = false

func _ready():
	get_parent().get_node("Missingpixel Card/Background").modulate.a = 1
	
	yield(get_tree().create_timer(0.5), "timeout")
	if(Nebula.get_node("Save Game Director").firstboot):
		get_parent().get_node("Visuals/Title Screen Animation").play("Content Warning In")
	else:
		get_parent().get_node("Visuals/Title Screen Animation").play("Title Screen")

func _input(event):
	if(clickable and !out and (event is InputEventKey)):
		if(Nebula.get_node("Save Game Director").firstboot):
			out = true
			Nebula.get_node("Save Game Director").initialize_slot("starfarer")
			get_parent().get_node("Functionals/Act Selector").select_act("Act 1")
			
		else:
			out = true
			get_parent().get_node("Visuals/Title Screen Animation").stop()
			get_parent().get_node("Visuals/Title Screen Animation").play("Move Up")

func fade_away():
	var flash = get_parent().get_node("Visuals/Flash")
	var ft = flash.get_node("Tween")
	print("fade")
	ft.interpolate_property(flash, "modulate:a", flash.modulate.a, 0.0, 0.7, Tween.TRANS_QUAD, Tween.EASE_IN)
	ft.start()

func _on_No_pressed():
	get_parent().get_node("Visuals/Title Screen Animation").play("Content Warning Out to Title")
