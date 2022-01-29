extends Node

var field = preload("res://nebula/VFX Director/Parallax Particle Field/Particle Field.tscn")
var offset_map = {
	0:Vector2(0,0),
	1:Vector2(320,0),
	2:Vector2(0,180),
	3:Vector2(320,180)
}

func _ready():
	pass
	#add_particle_field(load("res://nebula/persistent_nebula/VFX Director/Parallax Particle Field/Test Particles.tres"),0.1)
	#add_particle_field(load("res://nebula/persistent_nebula/VFX Director/Parallax Particle Field/Test Particles.tres"),0.2)
	#add_particle_field(load("res://nebula/persistent_nebula/VFX Director/Parallax Particle Field/Test Particles.tres"),0.4)
	#add_particle_field(load("res://nebula/persistent_nebula/VFX Director/Parallax Particle Field/Test Particles.tres"),0.8)
	
func add_particle_field(material:Resource, parallax_scale):
	for i in range(0,4):
		var new_field = field.instance()
		new_field.material = material
		new_field.parallax_scale = parallax_scale
		new_field.position += offset_map[i]
		
		self.add_child(new_field)
	
