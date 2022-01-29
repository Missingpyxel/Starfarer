extends Sprite

onready var comet = get_node("Sprite")
export(float) var shake = 1.0

func _process(delta):
	comet.position = Vector2(randf() * shake, randf() * shake)
