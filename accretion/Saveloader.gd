extends Control

var path = "res://output.json"

var mouse_on_canvas = false
	
func _input(event):
	if event is InputEventMouseMotion:
		if(Input.is_action_pressed("click") and mouse_on_canvas):
			self.rect_position += (event.relative)

func save(pth : String):
	var saver = {}
	
	for object in get_children():
		match(object.type):
			"dialogue":
				saver[object.name] = {
					"type" : object.type,
					"character" : object.get_node("CharacterEdit").text,
					"dialogue" : object.get_node("TextEdit").text,
					"position_x" : object.rect_position.x,
					"position_y" : object.rect_position.y,
					"next" : object.connection.name
				}
			_:
				pass
		
	var to_save = File.new()
	to_save.open(pth,File.WRITE)
	to_save.store_string(JSON.print(saver))
	to_save.close()

func _process(delta):
	if (Input.is_action_just_pressed("save")):
		save(path)
		
	if (Input.is_action_just_released("scroll_up")):
		print("e")
		self.rect_scale += Vector2(0.05,0.05)
		
	if (Input.is_action_just_released("scroll_down")):
		print("e")
		self.rect_scale -= Vector2(0.05,0.05)


func _on_Canvas_mouse_entered():
	mouse_on_canvas = true

func _on_Canvas_mouse_exited():
	mouse_on_canvas = false
