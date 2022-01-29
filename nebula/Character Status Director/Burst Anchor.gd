extends Control

func burst(idx: int, type = "red"):
	var new_burst = load("res://nebula/Character Status Director/Status Bar Scenes/Burst.tscn").instance()
	new_burst.rect_position.y = 4
	new_burst.rect_position.x = 4 + 13 * (idx - 1)
	self.add_child(new_burst)
	new_burst.play()
