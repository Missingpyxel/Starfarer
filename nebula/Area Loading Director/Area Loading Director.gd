extends Node

var current_area = null
var current_path = null
var current_scene_type = null

var character_pos = null

onready var registry = Nebula.get_node("Registry Director")

func _ready():
	Nebula.connect("area_loaded",self,"load_area_after")

func load_area(area:String,path):
	
	current_area = area
	current_path = path
	
	get_tree().change_scene_to(load(path))

func load_area_after():
	var root =  Nebula.get_root()
	
	# Try modifiers
	for mod in registry.modifier_registry[current_area]:
		var inst = load(mod).instance()
		
		if(inst.load_if()):
			root.add_child(inst)
		else:
			inst.queue_free()
	
	# Character spawning doo doo
	var st = root.scene_type
	var cst = root.character_scene_type
	
	# if inherited, inherit previous
	if(cst == "predetermined"):
		Nebula.get_node("Character Loading Director").current_team = root.set_team
	
	elif(cst == "team"):
		Nebula.emit_signal("spawn_starter_character")

	# gui removal or not
	current_scene_type = st
	
	if(st == "menu" or st == "story"):
		Nebula.get_node("Character Status Director/Abilities Panel").modulate.a = 0
		Nebula.get_node("Character Status Director/Status Panel").modulate.a = 0
	
	else:
		Nebula.get_node("Character Status Director/Abilities Panel").modulate.a = 1
		Nebula.get_node("Character Status Director/Status Panel").modulate.a = 1
		
	if(root.camera_on_character and !(st == "menu")):
		var camera = Nebula.get_node("Camera Director")
		var character_director = Nebula.get_node("Character Loading Director")
		
		camera.change_subject(character_director.current_character)
	
	if(st != "menu"):
		
		if(character_pos):
			Nebula.get_node("Character Loading Director").current_character.position = character_pos		
