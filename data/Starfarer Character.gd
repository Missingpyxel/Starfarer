extends KinematicBody2D

export(int) var base_max_hp = 4
var max_hp = base_max_hp + 2
var hp = max_hp

export(float) var normal_speed = 1
export(float) var sprint_speed = 1.3

export(float) var dash_cooldown = 1

export(float) var primary_cooldown = 1
export(float) var secondary_cooldown = 2
export(float) var utility_cooldown = 3
export(float) var ultimate_cooldown = 5

export(Color) var color = Color(255,0,0,1)

export(Resource) var primary_image = preload("res://nebula/Character Status Director/Unknown Ability.png")
export(Resource) var secondary_image = preload("res://nebula/Character Status Director/Unknown Ability.png")
export(Resource) var utility_image = preload("res://nebula/Character Status Director/Unknown Ability.png")
export(Resource) var ultimate_image = preload("res://nebula/Character Status Director/Unknown Ultimate.png")

export var cause_of_death = "Default"

var movement_jammed = false
var ability_jammed = false

onready var core = get_node("Abilities Core")

func _ready():
	Nebula.connect("ability_approve",self,"pass_ability")

func _process(delta):
	
	if(!ability_jammed):
		if(Input.is_action_just_pressed("main")):
			core.basic()
		
		if(Input.is_action_just_pressed("dash")):
			Nebula.emit_signal("ability_request","dash")
		if(Input.is_action_just_pressed("primary")):
			Nebula.emit_signal("ability_request","primary")
		if(Input.is_action_just_pressed("secondary")):
			Nebula.emit_signal("ability_request","secondary")
		if(Input.is_action_just_pressed("utility")):
			Nebula.emit_signal("ability_request","utility")
		if(Input.is_action_just_pressed("ultimate")):
			Nebula.emit_signal("ability_request","ultimate")
			
		if(Input.is_action_just_pressed("die")):
			hp -= 1;
			Nebula.get_node("Character Status Director").update_hp()
			
	if(!movement_jammed):
		var move_vector = Vector2(
			int(Input.is_action_pressed("move_right"))
		  - int(Input.is_action_pressed("move_left")), 
			int(Input.is_action_pressed("move_down")) 
		  - int(Input.is_action_pressed("move_up")))
			
		move_and_slide_with_snap(move_vector.normalized() * 100 * Nebula.uts, Vector2.ZERO)
	
func pass_ability(type):
	match(type):
		"dash":
			core.dash()
		"primary":
			core.primary()
		"secondary":
			core.secondary()
		"utility":
			core.utility()
		"ultimate":
			core.ultimate()
