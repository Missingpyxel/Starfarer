extends Node

export var parallax_scale = 0
onready var camera = get_parent().get_parent().get_parent().get_node("Camera Director")

func _ready():
	Nebula.connect("camera_delta",self,"parallax_offset")

func parallax_offset(offset:Vector2):
	self.position -= (offset*parallax_scale)

func _process(delta):
	var x_offset = self.position.x - camera.position.x
	var y_offset = self.position.y - camera.position.y
	
	if(x_offset < -320):
		self.position.x += 640
	
	if(x_offset > 320):
		self.position.x -= 640

	if(y_offset < -180):
		self.position.y += 360
		
	if(y_offset > 180):
		self.position.y -= 360
		
	self.position.x
