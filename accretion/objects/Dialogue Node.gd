extends ColorRect

var type = "dialogue"

var intent = false
var placing = false
var obj = null

var connection = null

onready var selector_box = get_node("Selector")
var grab_offset = Vector2.ZERO
var mouse_inside = false

func select():
	mouse_inside = true
	selector_box.modulate.a = 1

func deselect():
	mouse_inside = false
	selector_box.modulate.a = 0

func _on_Dialogue_Node_mouse_entered():
	self.select()
	
func _on_Dialogue_Node_mouse_exited():
	self.deselect()

func _process(delta):
	
	if (Input.is_action_just_pressed("delete") and mouse_inside):
		get_parent().remove_child(self)
		self.queue_free()
	
	if (Input.is_action_just_pressed("click") and mouse_inside):
		grab_offset = self.rect_position - get_global_mouse_position() / obj.rect_scale.x
	
	if (Input.is_action_pressed("click") and mouse_inside):
		self.rect_position = get_global_mouse_position() / obj.rect_scale.x + grab_offset
		
		for object in get_parent().get_children():
			if(object.type == "line"):
				if(object.obj1 == self or object.obj2 == self):
					object.render_object()

	if (Input.is_action_just_released("click") and placing):
		self.deselect()
		placing = false
		
	if (Input.is_action_just_pressed("rightclick") and mouse_inside):
		var line = load("res://objects/Line.tscn").instance()
		line.obj1 = self
		line.tracking = true
		
		obj.add_child(line)

func _on_Titlebar_mouse_exited():
	self.get_node("Titlebar/TextEdit").release_focus()
	self.name = self.get_node("Titlebar/TextEdit").text
	
	if(self.get_node("Titlebar/TextEdit").text != self.name):
		self.get_node("Titlebar/TextEdit").text = self.name
	
