extends ColorRect

# OVERRIDE THIS YOU BOZO
func get_type():
	assert(true,"ERROR: No type defined for " + self.name)

var intent = false
var placing = false

var connection = null

onready var obj = get_tree().root.get_node("Accretion").get_node("Objects")
onready var selector_box = get_node("Selector")
onready var title_bar = get_node("Title Bar")

var grab_offset = Vector2.ZERO
var mouse_inside = false

func _ready():
	self.connect("mouse_entered",self,"on_enter")
	self.connect("mouse_exited",self,"on_exit")
	
	if(title_bar):
		title_bar.connect("mouse_exited",self,"titlebar_deselect")

func select():
	mouse_inside = true
	selector_box.modulate.a = 1

func deselect():
	mouse_inside = false
	selector_box.modulate.a = 0

func on_enter():
	self.select()
	
func on_exit():
	self.deselect()

func _process(delta):
	
	if (Input.is_action_just_pressed("delete") and mouse_inside):
		if(self.get_type() != "start"):
			obj.clear_lines(self)
			obj.remove_child(self)
			self.queue_free()
	
	if (Input.is_action_just_pressed("click") and mouse_inside):
		grab_offset = self.rect_position - get_global_mouse_position() / obj.rect_scale.x
	
	if (Input.is_action_pressed("click") and mouse_inside):
		self.rect_position = get_global_mouse_position() / obj.rect_scale.x + grab_offset
		
		for object in get_parent().get_children():
			if(object.get_type() == "line"):
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

func titlebar_deselect():
	title_bar.get_node("TextEdit").release_focus()
	self.name = title_bar.get_node("TextEdit").text
	
	if(title_bar.get_node("TextEdit").text != self.name):
		title_bar.get_node("TextEdit").text = self.name
	
