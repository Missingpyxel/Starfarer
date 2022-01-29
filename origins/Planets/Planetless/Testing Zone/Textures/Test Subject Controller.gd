extends KinematicBody2D

export(float) var normal_speed = 1
export(float) var sprint_speed = 1.3

export(float) var dash_cooldown = 1

export(float) var primary_cooldown = 1
export(float) var secondary_cooldown = 2
export(float) var utility_cooldown = 3
export(float) var ultimate_cooldown = 5

signal ability

func _ready():
	Nebula.connect("ability",)

func _process(delta):
	
	var move_vector = Vector2(
		int(Input.is_action_pressed("move_right"))
	  - int(Input.is_action_pressed("move_left")), 
		int(Input.is_action_pressed("move_down")) 
	  - int(Input.is_action_pressed("move_up")))
	
	move_and_slide_with_snap(move_vector.normalized() * 100, Vector2.ZERO)
	
