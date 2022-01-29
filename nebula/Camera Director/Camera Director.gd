extends Camera2D

var subject_location = Vector2(0,0)
var subject : Node2D = null
export var hit_offset = Vector2.ZERO
export(float) var hit_strength = 1.0
export var hit_force = 10

var subject_reference : Node2D = null

var interp_amount = 1

var interp_pos = self.position
var inside_area = true

var horizontal_bounds = Vector2(-1000000,1000000)
var vertical_bounds = Vector2(-1000000,1000000)

onready var zone_director = Nebula.get_node("Zone Director")

func _ready():
	# NEBULA CONNECTIONS
	Nebula.connect("change_camera_subject",self,"change_subject")
	Nebula.connect("change_camera_coordinates",self,"change_location")
	
	Nebula.connect("save_subject",self,"save_subject")
	Nebula.connect("load_subject",self,"load_subject")

func _process(delta):
	if(subject):
		subject_location = subject.position
		
		if(subject_location.x < horizontal_bounds.x):
			subject_location.x = horizontal_bounds.x
		elif(subject_location.x > horizontal_bounds.y):
			subject_location.x = horizontal_bounds.y
			
		if(subject_location.y < vertical_bounds.x):
			subject_location.y = vertical_bounds.x
		elif(subject_location.y > vertical_bounds.y):
			subject_location.y = vertical_bounds.y
		
	var old_position = self.position
		
	interp_pos = smooth_interp(interp_pos,subject_location,8,delta)
	
	self.position = interp_pos + hit_offset*hit_force*hit_strength
	
	Nebula.emit_signal("camera_delta",self.position-old_position)

func smooth_interp(to_interp : Vector2, final, base_speed, delta):
	var min_dist = base_speed * 0.03
	var move = base_speed * delta
	
	var interpolated = to_interp.linear_interpolate(subject_location,move * interp_amount)
	
	if(to_interp.distance_to(interpolated) < min_dist * move):
		interpolated = to_interp.move_toward(final,min_dist * move)
		
	return interpolated

func change_location_direct(new_pos : Vector2):
	self.position = new_pos
	change_location(new_pos)

func change_location(new_pos : Vector2):
	subject_location = new_pos
	subject = null
	
func change_subject(new_subject : Node2D):
	subject = new_subject
	
func save_subject():
	subject_reference = subject

func load_subject():
	subject = subject_reference
	
func set_constraints():
	var shape = zone_director.current_zone.get_node("CollisionShape2D")
	var rect = shape.get_shape()
	horizontal_bounds = Vector2(shape.position.x - rect.get_extents().x + 160, shape.position.x + rect.get_extents().x - 160)
	vertical_bounds = Vector2(shape.position.y - rect.get_extents().y + 90, shape.position.y + rect.get_extents().y - 90)
