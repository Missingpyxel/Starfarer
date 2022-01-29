extends Node

var swapping = false

var current_team = []
var il = [0, 1, 2]
var indices = null
var current_character = null
var old_character = null
onready var character_null = Nebula.get_character("Null")
onready var cooldown = get_node("Character Swap Cooldown")
onready var ald = Nebula.get_node("Area Loading Director")

var let_dim = false

var jammed_open = false
var jammed_shut = false
var gray_coefficient = 0.0

onready var slot_1 = get_node("CanvasLayer/Slot 1 Area/Slot 1")
onready var slot_2 = get_node("CanvasLayer/Slot 2")
onready var slot_3 = get_node("CanvasLayer/Slot 3 Area/Slot 3")

onready var swap_anim = get_node("CanvasLayer/Swap")

func _ready():
	current_team = [character_null.instance(),character_null.instance()]
	Nebula.connect("spawn_starter_character",self,"spawn_starter_character")

func spawn_starter_character():
	spawn_character(current_team[0])

func set_grayscale():
	Nebula.get_node("VFX Director/Screen Space Shaders/Grayscale/Shader").material.set_shader_param("scale",1-gray_coefficient)
	Nebula.get_node("Camera Director").zoom = Vector2(1 - gray_coefficient/5, 1 - gray_coefficient/5)
	Nebula.get_node("Camera Director").interp_amount = (gray_coefficient*15) + 1
	Nebula.get_node("Character Status Director").offset.y = gray_coefficient * 35
	Nebula.uts = (1.0 - gray_coefficient)
	
	if(!jammed_open):
		slot_1.rect_position.x = 0 + gray_coefficient*20
		slot_3.rect_position.x = 40 - gray_coefficient*20
	
	if(!jammed_shut and !let_dim):
		slot_1.modulate.a = gray_coefficient
		slot_3.modulate.a = gray_coefficient

func _process(delta):
	if(len(current_team) > 1 and ald.current_scene_type == "combat"):
		if(Input.is_action_just_pressed("swap") and cooldown.time_left == 0):
			swapping = true
			Nebula.get_node("Character Status Director/Status Panel/Swap Bar Animator").play("Empty")
			
			# set textures and available characters
			var index = current_team.find(current_character)
			
			slot_1.rect_position = Vector2(20,20)
			slot_2.modulate.a = 0
			slot_2.rect_position = Vector2(150,80)
			slot_3.rect_position = Vector2(20,20)
			
			if(len(current_team) == 3):
				indices = il.duplicate()
				indices.remove(index)
				
				print(indices)
				
				slot_3.self_modulate.a = 1
				
			elif(len(current_team) == 2 and !jammed_shut):
				jammed_open = true
				indices = 1 - index
				slot_3.self_modulate.a = 0
				
				yield(get_tree().create_timer(0.3),"timeout")
				Nebula.get_root().remove_child(current_character)
				swap_anim.play("Swap Left")
				let_dim = true
				
				yield(get_tree().create_timer(0.3), "timeout")
				swapout(current_team[indices])
				
				jammed_open = false
				jammed_shut = true
				yield(get_tree().create_timer(0.2), "timeout")
				jammed_shut = false
				let_dim = false
				
			cooldown.start()
			swapping = false
		
		if((Input.is_action_pressed("swap") and !jammed_shut and cooldown.time_left == 0) or jammed_open):
			gray_coefficient = lerp(gray_coefficient, 1, 4 * delta)
			set_grayscale()
			
		elif(gray_coefficient > 0):
			
			if(!jammed_open):
				gray_coefficient -= 10 * delta
				
				if(gray_coefficient < 0): 
					gray_coefficient = 0
			
			set_grayscale()
	

func swapout(character: Node):
	spawn_character(character)
	current_character.position = Nebula.get_node("Camera Director").position
	Nebula.get_node("Camera Director").change_subject(current_character)
			
func spawn_character(character: Node):
	var root_node = Nebula.get_root()
	
	root_node.add_child(character)
	current_character = character
	
	current_character.ability_jammed = false
	current_character.movement_jammed = false
	
	var hue = current_character.color.h
	var abilities_panel = Nebula.get_node("Character Status Director/Abilities Panel")
	abilities_panel.material.set_shader_param("hueshift",hue)
	abilities_panel.get_node("Primary").texture = current_character.primary_image
	abilities_panel.get_node("Secondary").texture = current_character.secondary_image
	abilities_panel.get_node("Utility").texture = current_character.utility_image
	abilities_panel.get_node("Ultimate").texture = current_character.ultimate_image
	
	Nebula.emit_signal("character_loaded")

func _on_Slot_1_Area_pressed():
	play_swap_anim("Left")

func _on_Slot_3_Area_pressed():
	play_swap_anim("Right")

func play_swap_anim(side:String):
	if(Input.is_action_pressed("swap") and len(current_team) == 3):
		jammed_open = true
		let_dim = true
		swap_anim.play("Swap " + side)
		Nebula.get_root().remove_child(current_character)
		
		yield(get_tree().create_timer(0.3), "timeout")
		
		if(side == "Left"):
			swapout(current_team[indices[0]])
		elif(side == "Right"):
			swapout(current_team[indices[1]])
		
		jammed_open = false
		jammed_shut = true
		yield(get_tree().create_timer(0.2), "timeout")
		jammed_shut = false
		let_dim = false
