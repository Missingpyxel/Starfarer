extends TextureRect

func play():
	self.get_node("AnimationPlayer").play("Burst")
	yield(get_tree().create_timer(2), "timeout")
	self.queue_free()

func _process(delta):
	get_node("Inner Burst").speed_scale = Nebula.uts + 0.2
	get_node("Outer Burst").speed_scale = Nebula.uts + 0.2
