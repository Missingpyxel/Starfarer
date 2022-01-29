extends Node

onready var character_loading_director = Nebula.get_node("Character Loading Director")
onready var dash = get_node("Dash Cooldown")
onready var swap = Nebula.get_node("Character Loading Director/Character Swap Cooldown")
onready var primary = get_node("Primary Cooldown")
onready var secondary = get_node("Secondary Cooldown")
onready var utility = get_node("Utility Cooldown")
onready var ultimate = get_node("Ultimate Cooldown")

onready var panel = get_node("Abilities Panel")
onready var status = get_node("Status Panel")

onready var primary_cooldown = get_node("Abilities Panel/Primary/Cooldown")
onready var secondary_cooldown = get_node("Abilities Panel/Secondary/Cooldown")
onready var utility_cooldown = get_node("Abilities Panel/Utility/Cooldown")
onready var ultimate_cooldown = get_node("Abilities Panel/Ultimate/Cooldown")

onready var camera = Nebula.get_node("Camera Director")

onready var sss = Nebula.get_node("VFX Director/Screen Space Shaders")

onready var abberation = Nebula.get_node("VFX Director/Screen Space Shaders/Abberation/Shader")
onready var grayscale = Nebula.get_node("VFX Director/Screen Space Shaders/Grayscale/Shader")
onready var heartbeat = Nebula.get_node("VFX Director/Screen Space Shaders/Heartbeat/Shader")

export var period = 2;
export var pulse_gain = 15;
export var pulse_floor = 20;
var pulse_timer = -1.0

var dying = false

var current_character = null

var max_health = 0
var old_hp = 0

func _ready():
	Nebula.connect("character_loaded",self,"set_status")
	Nebula.connect("ability_request",self,"ability")
	
	primary.connect("timeout",self,"primary_timeout")
	secondary.connect("timeout",self,"secondary_timeout")
	utility.connect("timeout",self,"utility_timeout")
	ultimate.connect("timeout",self,"ultimate_timeout")
	
func primary_timeout():
	panel.get_node("Primary/Animator").queue("Available")
	
func secondary_timeout():
	panel.get_node("Secondary/Animator").queue("Available")
	
func utility_timeout():
	panel.get_node("Utility/Animator").queue("Available")
	
func ultimate_timeout():
	panel.get_node("Ultimate/Animator").queue("Available")
	
func _process(delta):

	# Gray cooldown rects size
	primary_cooldown.rect_size.y = 12*primary.time_left * 1/primary.wait_time
	primary_cooldown.rect_position.y = 12 - primary_cooldown.rect_size.y
	
	secondary_cooldown.rect_size.y = 12*secondary.time_left * 1/secondary.wait_time
	secondary_cooldown.rect_position.y = 12 - secondary_cooldown.rect_size.y
	
	utility_cooldown.rect_size.y = 12 * utility.time_left * 1/utility.wait_time
	utility_cooldown.rect_position.y = 12 - utility_cooldown.rect_size.y
	
	ultimate_cooldown.rect_size.y = 16*ultimate.time_left * 1/ultimate.wait_time
	ultimate_cooldown.rect_position.y = 16 - ultimate_cooldown.rect_size.y
	
	status.get_node("Dash Bar").rect_size.x = 32 * (1 - dash.time_left/dash.wait_time)
	
	if(!character_loading_director.swapping):
		status.get_node("Swap Bar").rect_size.x = 18 * (1 - swap.time_left/swap.wait_time)
	
	if(pulse_timer >= 0):
		# Health pulsing effect
		
		var pulse_coeff = (pulse_timer/(pulse_timer+pulse_gain)) * pow(sin(period*pulse_timer),2.0) + (pulse_timer/(pulse_timer+pulse_floor)) 
		var gray_coeff = (pulse_timer/(pulse_timer+pulse_gain)) * pow(sin(period*pulse_timer),2.0)/3.0 + (pulse_timer/(pulse_timer+pulse_floor-10)) 
		
		var pip = Nebula.get_node("Character Status Director/Status Panel/Red HP")
		
		pip.rect_scale.x = 1 + 0.11 * sin(2*period*pulse_timer + PI/2.0)
		pip.rect_scale.y = 1 + 0.11 * sin(2*period*pulse_timer + PI/2.0)
		
		heartbeat.material.set_shader_param("coeff",pulse_coeff)
		heartbeat.material.set_shader_param("gray_coeff",gray_coeff)
		pulse_timer += delta
		pulse_timer += delta
		
func update_hp():
	# Updates the health bar and notifies everything
	
	var current_hp = current_character.hp
	var current_base_hp = current_character.hp
	var current_extra_hp = 0
	
	if(current_hp < old_hp and current_hp >= 0):
		get_node("Status Panel").shake()
		
		for i in range(0,old_hp-current_hp):
			get_node("Burst Anchor").burst(old_hp - i)
		
		var angle = rand_range(0,PI*2)
		Nebula.get_node("Camera Director").hit_offset = Vector2(cos(angle),sin(angle))
		Nebula.get_node("Camera Director").hit_force = 6 + (15 * (1 - (float(current_hp)/current_character.max_hp)))
		sss.get_node("Hit").play("Hit")
				
	# ON DEATH
	if(current_hp <= 0):
		pulse_timer = -1
		Nebula.get_node("Character Death Director").kill()
				
	if(current_base_hp > current_character.base_max_hp):
		current_base_hp = current_character.base_max_hp
		current_extra_hp = current_hp - current_character.base_max_hp
		
	max_health = current_character.max_hp
	
	get_node("Status Panel/Red HP").value = current_base_hp
	get_node("Status Panel/Yellow HP").value = current_extra_hp
	
	old_hp = current_character.hp
	
	if(current_hp == 1):
		get_node("Status Panel/Pulse Cooldown").start()
	else:
		get_node("Status Panel/Red HP").rect_scale = Vector2(1,1)
		pulse_timer = -1
		heartbeat.material.set_shader_param("coeff",0)
		heartbeat.material.set_shader_param("gray_coeff",0)
		
func set_status():
	current_character = character_loading_director.current_character
	
	dash.wait_time = current_character.dash_cooldown
	primary.wait_time = current_character.primary_cooldown
	secondary.wait_time = current_character.secondary_cooldown
	utility.wait_time = current_character.utility_cooldown
	ultimate.wait_time = current_character.ultimate_cooldown
	
	dash.start()
	primary.start()
	secondary.start()
	utility.start()
	ultimate.start()
	
	panel.get_node("Primary/Animator").queue("Used")
	panel.get_node("Secondary/Animator").queue("Used")
	panel.get_node("Utility/Animator").queue("Used")
	panel.get_node("Ultimate/Animator").queue("Used")
	
	var length = status.rect_size.x
	var segment = load("res://nebula/Character Status Director/Status Segment.tscn")
	
	update_hp()
	
	for i in range(0,max_health-3):
		var new_segment = segment.instance()
		status.get_node("Segments").add_child(new_segment)
		new_segment.rect_position.x = length
		length += new_segment.rect_size.x
		
		if(i == (max_health - 3) - (max_health - current_character.base_max_hp)):
			get_node("Status Panel/Yellow HP").rect_position.x = new_segment.rect_position.x - 3
		
	var endcap = load("res://nebula/Character Status Director/Status Endcap.tscn")
	var final_cap = endcap.instance()
	status.get_node("Segments").add_child(final_cap)
	final_cap.rect_position.x = length - 3
	
func ability(type):
	match(type):
		"dash":
			if(dash.time_left <= 0):
				Nebula.emit_signal("ability_approve",type)
				dash.start()
		"primary":
			if(primary.time_left <= 0):
				Nebula.emit_signal("ability_approve",type)
				primary.start()
				panel.get_node("Primary/Animator").queue("Used")
		"secondary":
			if(secondary.time_left <= 0):
				Nebula.emit_signal("ability_approve",type)
				secondary.start()
				panel.get_node("Secondary/Animator").queue("Used")
		"utility":
			if(utility.time_left <= 0):
				Nebula.emit_signal("ability_approve",type)
				utility.start()
				panel.get_node("Utility/Animator").queue("Used")
		"ultimate":
			if(ultimate.time_left <= 0):
				Nebula.emit_signal("ability_approve",type)
				ultimate.start()
				panel.get_node("Ultimate/Animator").queue("Used")

func _on_Pulse_Cooldown_timeout():
	pulse_timer = 0
