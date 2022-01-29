extends CanvasLayer

onready var blur = get_node("Blur")

export var open = false
export var mission_out = false
export var journal_out = false

onready var ald = Nebula.get_node("Area Loading Director")

onready var button = get_node("Buttons")
onready var mission = get_node("Mission")
onready var journal = get_node("Journal")

onready var button_tween = get_node("Button Tween")
onready var mission_tween = get_node("Mission Tween")
onready var journal_tween = get_node("Journal Tween")

func tween_buttons(opacity : float, time : float):
	button_tween.stop_all()
	button_tween.interpolate_property(button,"modulate:a",button.modulate.a,opacity,time,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	button_tween.start()

func tween_mission(pos: Vector2, time : float):
	mission_tween.stop_all()
	mission_tween.interpolate_property(mission,"rect_position",mission.rect_position,pos,time,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	mission_tween.start()
	
func tween_journal(pos: Vector2, time : float):
	journal_tween.stop_all()
	journal_tween.interpolate_property(journal,"rect_position",journal.rect_position,pos,time,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	journal_tween.start()

func _process(delta):
	if(Input.is_action_just_pressed("menu") and ald.current_scene_type != "menu"):
		if(open):
			if(mission_out):
				tween_buttons(1.0,0.4)
				tween_mission(Vector2(-60,10),0.5)
				tween_journal(Vector2(310,10),0.3)
				
				mission_out = false
		
			elif(journal_out):
				tween_buttons(1.0,0.4)
				tween_mission(Vector2(-60,10),0.5)
				tween_journal(Vector2(310,10),0.3)
				
				journal_out = false
		
			else:
				blur.play_backwards("Blur")
				tween_buttons(0.0,0.4)
				tween_mission(Vector2(-70,10),0.5)
				tween_journal(Vector2(320,10),0.3)
				
		else:
			blur.play("Blur")
			tween_buttons(1.0,0.4)
			tween_mission(Vector2(-60,10),0.5)
			tween_journal(Vector2(310,10),0.3)

func _on_Resume_pressed():
	blur.play_backwards("Blur")
	tween_buttons(0.0,0.4)
	tween_mission(Vector2(-70,10),0.5)
	tween_journal(Vector2(320,10),0.3)

func _on_Left_Bracket_mouse_entered():
	if(!mission_out and !journal_out):
		tween_mission(Vector2(-55,10),0.3)

func _on_Left_Bracket_mouse_exited():
	if(!mission_out and !journal_out):
		tween_mission(Vector2(-60,10),0.3)

func _on_Right_Bracket_mouse_entered():
	if(!mission_out and !journal_out):
		tween_journal(Vector2(305,10),0.3)

func _on_Right_Bracket_mouse_exited():
	if(!mission_out and !journal_out):
		tween_journal(Vector2(310,10),0.3)


func _on_Left_Bracket_pressed():
	if(!journal_out):
		tween_buttons(0.0,0.4)
		tween_mission(Vector2(125,10),0.5)
		tween_journal(Vector2(320,10),0.3)
		
		mission_out = true

func _on_Right_Bracket_pressed():
	if(!mission_out):
		tween_buttons(0.0,0.4)
		tween_journal(Vector2(40,10),0.6)
		tween_mission(Vector2(-70,10),0.3)
		
		journal_out = true
