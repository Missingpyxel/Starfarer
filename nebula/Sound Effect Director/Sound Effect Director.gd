extends Node

func play_effect(effect_name):
	var effect = load("res://origins/assets/sound_effects/" + effect_name + ".ogg")
	var sound_object = AudioStreamPlayer.new()
	
	sound_object.stream = effect
	sound_object.name = effect_name
	
	self.add_child(sound_object)
	sound_object.play()
	
func _process(delta):
	for child in get_children():
		if(!child.playing):
			print(child)
			child.queue_free()
	
func _ready():
	#XDC CONNECTIONS
	Nebula.connect("play_sound",self,"play_effect")
