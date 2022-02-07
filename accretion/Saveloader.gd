extends Control

var start_node = preload("res://objects/Start Node.tscn")
var dialogue_node = preload("res://objects/Dialogue Node.tscn")
var value_node = preload("res://objects/Value Node.tscn")
var line_scene = preload("res://objects/Line.tscn")

var path = ""
onready var path_label = get_parent().get_node("Top Bar").get_node("Label")

var mouse_on_canvas = false

# HUGE thank you to u/T-Loy on reddit for this code >:)

func _ready():
	print(self["rect_position"]["x"])
	new_file()

func clear_canvas():
	self.rect_position = Vector2.ZERO
	for child in get_children():
		self.remove_child(child)
		child.queue_free()

func new_file():
	clear_canvas()
		
	path = ""
	path_label.text = "New File"
		
	self.add_child(start_node.instance())

func open_dialog():
	var dir = Directory.new()
	dir.open(".")
	var ptf = dir.get_current_dir().replace(" ","` ")
	var output = []
	
	OS.execute('powershell', [ptf + "/open_file.ps1"], true, output)
	
	if(output[0] != "\n"):
		path = output[0].replace("\\","/").replace("\n","")
		path_label.text = path
		
		load_file()
	
func save_dialog():
	var dir = Directory.new()
	dir.open(".")
	var ptf = dir.get_current_dir().replace(" ","` ")
	var output = []
	
	OS.execute('powershell', [ptf + "/save_file.ps1"], true, output)
	
	if(output[0] != "\n"):
		path = output[0].replace("\\","/").replace("\n","")
		path_label.text = path
	
func _input(event):
	if event is InputEventMouseMotion:
		if(Input.is_action_pressed("click") and mouse_on_canvas):
			self.rect_position += (event.relative)

func clear_lines(obj : Control, forward_only = false):
	for child in get_children():
		if(child.get_type() == "line"):
			if forward_only:
				if(obj == child.obj1):
					child.queue_free()
			else:
				if(obj == child.obj1 or obj == child.obj2):
					child.queue_free()

func load_file():
	clear_canvas()
	
	var file = File.new()
	file.open(path,File.READ)
	print(file.get_as_text())
	
	var data = JSON.parse(file.get_as_text()).get_result()
	file.close()
	
	# First pass (objects)
	for key in data.keys():
		var object = data[key]
		
		match(object["type"]):
			"dialogue":
				var node = dialogue_node.instance()
				node.get_node("Title Bar").get_node("TextEdit").text = key
				node.get_node("CharacterEdit").text = object["character"]
				node.get_node("TextEdit").text = object["dialogue"]
				
				node.rect_position.x = object["position_x"]
				node.rect_position.y = object["position_y"]
				
				node.name = key
				self.add_child(node)

	# Second pass (connections)
	for key in data.keys():
		var object = data[key]
		
		match(object["type"]):
			"dialogue":
				print(object["next"])
				if(object["next"] != null) :
					self.get_node(key).connection = self.get_node(object["next"])
					
					var line = line_scene.instance()
					line.tracking = false
					line.obj1 = self.get_node(key)
					line.obj2 = self.get_node(object["next"])
					line.render_object()
					self.add_child(line)
				
func save():
	var saver = {}
	
	if(path == ""):
		save_dialog()
	
	for object in self.get_children():
		match(object.get_type()):
			"dialogue":
				saver[object.name] = {
					"type" : object.get_type(),
					"character" : object.get_node("CharacterEdit").text,
					"dialogue" : object.get_node("TextEdit").text,
					"position_x" : object.rect_position.x,
					"position_y" : object.rect_position.y,
					"next" : object.connection.name if object.connection else null
				}
			"value":
				saver[object.name] = {
					"type" : object.get_type(),
					"value_type" : text_from_dropdown(object.get_node("TypeSelector")),
					"operation" : text_from_dropdown(object.get_node("OperationSelector")),
					"path" : object.get_node("Key").text,
					"value" : object.get_node("Value").text,
					"position_x" : object.rect_position.x,
					"position_y" : object.rect_position.y,
					"next" : object.connection.name if object.connection else null
				}
			_:
				pass
	
	get_parent().get_node("Hourglass").get_node("AnimationPlayer").play("Flash")

	var to_save = File.new()
	to_save.open(path,File.WRITE)
	to_save.store_string(JSON.print(saver, "\t"))
	to_save.close()

func text_from_dropdown(obj : OptionButton):
	return obj.get_item_text(obj.selected)

func _process(delta):
	if (Input.is_action_just_pressed("save")):
		save()
		
	if (Input.is_action_just_released("scroll_up")):
		self.rect_scale += Vector2(0.05,0.05)
		
	if (Input.is_action_just_released("scroll_down")):
		self.rect_scale -= Vector2(0.05,0.05)


func _on_Canvas_mouse_entered():
	mouse_on_canvas = true

func _on_Canvas_mouse_exited():
	mouse_on_canvas = false

func _on_Save_pressed():
	if(path != ""):
		save()

func _on_Open_pressed():
	open_dialog()

func _on_New_pressed():
	new_file()
