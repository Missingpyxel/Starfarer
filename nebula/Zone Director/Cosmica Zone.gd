extends Area2D

onready var zd = Nebula.get_node("Zone Director")

func _on_Zone_body_entered(body):
	Nebula.get_node("Zone Director").current_zone = self
	
	Nebula.get_node("Camera Director").set_constraints()
	
	if(len(self.get_overlapping_bodies()) == 1):
		zd.last_completed_zone = self 
