extends Control

func set_selector():
	if(Nebula.get_node("Save Game Director").get_cheat_status()):
		get_node("Worldshaper").visible = true
		self.rect_position.x = -32.5

func dc_pressed(diff : String):
	Nebula.get_node("Save Game Director").initialize_slot(diff)
	get_parent().get_node("Act Selector").construct_act_selector()
	
	get_parent().get_node("Difficulty Selector Animation").play_backwards("Pop In")
	
	get_parent().get_node("Act Selector Animation").play("Fade In")

func _on_Button_pressed():
	dc_pressed("starfarer")

func _on_LK_button_pressed():
	dc_pressed("lorekeeper")
