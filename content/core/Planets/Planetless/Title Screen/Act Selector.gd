extends Control

onready var lines = get_parent().get_node("Act Selector Lines")

func construct_act_selector():
	for chapter in Nebula.get_node("Registry Director").chapter_registry:
		var ch = Nebula.get_node("Registry Director").chapter_registry[chapter]
		
		ch.get_node("Button").connect("pressed",self,"select_chapter",[chapter])
		self.add_child(ch)
		
	for child in self.get_children():
		if(len(child.dependent_acts) == 0):
			draw_lines(child.chapter_name)
			
func draw_lines(name : String):
	for child in self.get_children():
		if(child.dependent_acts.has(name)):
			var line = Line2D.new()
			line.points = [self.get_node(name).rect_position + self.get_node(name).rect_size / 2, child.rect_position + child.rect_size / 2]
			line.width = 2
			line.gradient = load("res://core/Planets/Planetless/Title Screen/Save Slot Stuff/good_gradient.tres")
			
			lines.add_child(line)
			
			draw_lines(child.chapter_name)

func select_chapter(chapter):
	var sgd = Nebula.get_node("Save Game Director")
	var ch = Nebula.get_node("Registry Director").chapter_registry[chapter]
	
	sgd.target_chapter = chapter
	sgd.target_time = ch.time
	
	get_parent().get_node("Act Selector Animation").play("Fade Out")
	yield(get_tree().create_timer(3.5), "timeout")
	
	sgd.initialize_save()
	sgd.load_game()
