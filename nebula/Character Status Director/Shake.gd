extends TextureRect

var shake_amount = 3
onready var pos = self.rect_position
onready var timer = get_node("Timer")

func shake():
	timer.start()

func set_shake():
	shake_amount = pow(timer.time_left* 2.5,2.0)
	self.rect_position = pos + Vector2(rand_range(-1.0,1.0) * shake_amount,rand_range(-1.0,1.0) * shake_amount)

func _process(delta):
	set_shake()
