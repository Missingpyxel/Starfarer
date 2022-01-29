extends CanvasLayer

onready var character = get_node("Character")
onready var char_shake = get_node("Char Shake")
onready var dtimer = get_node("Death Timer")

var dying = false

export var shake_mod = 5
export var death_particles_mod = 1.0

onready var abberation = Nebula.get_node("VFX Director/Screen Space Shaders/Abberation/Shader")
onready var grayscale = Nebula.get_node("VFX Director/Screen Space Shaders/Grayscale/Shader")
onready var heartbeat = Nebula.get_node("VFX Director/Screen Space Shaders/Heartbeat/Shader")

func kill():
	dying = true
	get_node("Death Timer").start()
	get_node("Death").play("Death")

func start_fda():
	get_node("Death Types").play(Nebula.get_node("Character Loading Director").current_character.cause_of_death)

func clear():
	for cut in get_node("Cuts").get_children():
		cut.queue_free()
		
	for particles in get_node("Character").get_children():
		particles.queue_free()
	
	get_node("Character").visible = false
	get_node("Flash/Death Final Particles").emitting = true
	get_node("Flash/Death Color Particles").emitting = true
	get_node("Flash/Death Color Particles").process_material.color = Nebula.get_node("Character Loading Director").current_character.color

func spawn_cut():
	var rad = 190
	var angle = rand_range(0,2*PI)
	var modifier = Vector2(rand_range(-10,10),rand_range(-10,10))
	var point = Vector2(rad*cos(angle)+160+modifier.x,rad*sin(angle)+90+modifier.y)
	
	var cut = load("res://nebula/Character Death Director/Line.tscn").instance()
	cut.rect_position = point
	cut.rect_rotation = angle*(180/PI)+180
	get_node("Cuts").add_child(cut)
	cut.get_node("Cut").play("Cut")
	
	
	var particles = load("res://nebula/Character Death Director/Death Animation Particles.tscn").instance()
	get_node("Cuts").add_child(particles)
	
	particles.scale = Vector2(0.08 + death_particles_mod/60.0,0.08 +  death_particles_mod/60.0)
	
	var ccolor = Nebula.get_node("Character Loading Director").current_character.color
	ccolor.s += 0.2
	ccolor.v += 0.2
	
	if(ccolor.s > 1.0):
		ccolor.s = 1.0
	
	if(ccolor.v > 1.0):
		ccolor.v = 1.0
	
	particles.process_material.color_ramp.gradient.set_color(1,ccolor)
	particles.process_material.color_ramp.gradient.set_color(2,(ccolor + ccolor + Color.white)/3.0)
	particles.emitting = true

func _process(delta):
	
	if(dying):
		var dcoeff = dtimer.time_left/dtimer.wait_time
		Nebula.uts = dcoeff
		grayscale.material.set_shader_param("scale",dcoeff)
		Nebula.get_node("Camera Director").interp_amount = 1/((dcoeff/2)+0.001)
		heartbeat.material.set_shader_param("coeff",dcoeff)
		heartbeat.material.set_shader_param("gray_coeff",dcoeff)
	
	if(char_shake.time_left > 0):
		character.rect_position = Vector2(150,80) + Vector2(rand_range(-1.0,1.0)*shake_mod,rand_range(-1.0,1.0)*shake_mod) * (char_shake.time_left/char_shake.wait_time)
