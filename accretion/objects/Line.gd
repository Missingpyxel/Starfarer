extends ColorRect

var type = "line"

var pt1 = Vector2(400,500)
var pt2 = Vector2(700,300)

var obj1 : Control = null
var obj2 : Control = null

var tracking = true

func render():
	self.rect_position = pt1
	self.rect_rotation = rad2deg(atan2(pt2.y-pt1.y,pt2.x-pt1.x))
	
	self.rect_size.x = pt1.distance_to(pt2)
	
func render_object():
	pt1 = Vector2(obj1.rect_position.x + obj1.rect_size.x,obj1.rect_position.y + obj1.rect_size.y/2)
	pt2 = Vector2(obj2.rect_position.x,obj2.rect_position.y + obj2.rect_size.y/2)
	render()
	
func render_mouse():
	pt1 = Vector2(obj1.rect_position.x + obj1.rect_size.x,obj1.rect_position.y + obj1.rect_size.y/2)
	pt2 = (get_global_mouse_position() - get_parent().rect_position) * 1/get_parent().rect_scale.x
	render()
	
func _input(event):
	if(tracking):
		render_mouse()
		
		if(Input.is_action_just_released("rightclick")):
			
			var found = false
			
			for object in get_parent().get_children():
				if(object.type == "dialogue"):
					if(object.mouse_inside == true and object != obj1):
						obj2 = object
						obj1.connection = obj2
						
						tracking = false
						
						render_object()
						found = true
						
			if(!found):
				get_parent().remove_child(self)
				self.queue_free()
