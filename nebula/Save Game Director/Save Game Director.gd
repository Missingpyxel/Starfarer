extends Node

var target_save = null
var target_act = null
var target_time = null

var firstboot = false

var difficulty = "starfarer"

var save = {
	"day" : 0,
	"characters" : [],
	"decision_modifiers" : {}
}

onready var ald = Nebula.get_node("Area Loading Director")
onready var cld = Nebula.get_node("Character Loading Director")
onready var zd = Nebula.get_node("Zone Director")

export(Array) var necessary_directories = ["saves","mods","screenshots","persistent"]

func save_exists(chapter):
	var file = Directory.new()
	return file.dir_exists("user://saves/" + str(target_save) + "/acts/" + str(target_act) + "/")

func list_files_in_dir(directory : String):
	var array = []
	var dir = Directory.new()
	dir.open(directory)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			array.append(file)
			
	return array
	
# actual functions

func initialize_slot(difficulty : String):
	var dir = Directory.new()
	var saves = list_files_in_dir("user://saves/")
	var maxn = 0
	
	for save in saves:
		maxn = max(maxn, int(save))
	maxn += 1
	
	dir.make_dir("user://saves/" + str(maxn) + "/")
	dir.make_dir("user://saves/" + str(maxn) + "/acts/")
	
	var slot_data = {"difficulty" : difficulty}
	
	var file = File.new()
	file.open("user://saves/" + str(maxn) + "/save.json",File.WRITE)
	file.store_string(JSON.print(slot_data))
	file.close()
	
	target_save = str(maxn)
	print(target_save)

func initialize_save(bypass = false):
	var file = File.new()
	
	print(target_save + " II")
	
	if(bypass or !save_exists(target_act)):
		var dir = Directory.new()
		dir.make_dir("user://saves/" + str(target_save) + "/acts/" + str(target_act) + "/")
		
		var act_obj = Nebula.get_node("Registry Director").chapter_registry[target_act]
		
		var area_data = {}
		area_data["area"] = act_obj.starting_area
		area_data["modifier"] = act_obj.starting_modifier
		area_data["position"] = Vector2.ZERO
		
		file.open("user://saves/" + str(target_save) + "/acts/" + str(target_act) + "/area.json",File.WRITE)
		file.store_string(JSON.print(area_data))
		file.close()

func save_chapter():
	pass

func save_area(pos = false):
	if(target_save and target_act):
		# act-level
		var area_data = {}
		
		save["area"] = ald.current_area
		save["modifier"] = ald.current_modifier
		
		if(pos):
			save["position"] = cld.current_character.position
		elif(zd.last_completed_zone):
			save["position"] = zd.last_completed_zone.get_node("CollisionShape2D").position
		else:
			save["position"] = Vector2.ZERO
			
		save["completed_zones"] = zd.completed_zones
		
		var act_file = File.new()
		act_file.open("user://saves/" + str(target_save) + "/acts/" + str(target_act) + "/area.json", File.WRITE)
		act_file.store_string(JSON.print(save, "\t"))
		act_file.close()
	
func load_game():
	var area_file = File.new()
	area_file.open("user://saves/" + str(target_save) + "/acts/" + str(target_act) + "/area.json", File.READ)
	
	var area_data = JSON.parse(area_file.get_as_text()).get_result()
	
	Nebula.load_area(area_data["area"], area_data["modifier"])
	ald.character_pos = parse_json(area_data["position"])
	
func get_dead_chars(time = false):
	var deaths = []
	
	var file = File.new()
	
	if(file.file_exists("user://saves/" + str(target_save) + "/deaths.json")):
		file.open("user://saves/" + str(target_save) + "/deaths.json",File.READ)
		deaths = JSON.parse(file.get_as_text())
		file.close()
		
		if(!time):
			var real_deaths = []
			for death in deaths.get_result():
				real_deaths.append(death[0])
			
			return real_deaths
			
		return deaths.get_result()
	
	file.close()
	return deaths
	
func kill_character(char_name : String):
	var deaths = get_dead_chars(true)
	var to_remove = []
	var overwritten = false
	
	for chara in deaths:
		if(chara[0] == char_name):
			print("id")
			if(chara[1] >= target_time):
				to_remove.append(chara)
				print("removing")
			else:
				overwritten = true
				
	for death in to_remove:
		deaths.erase(death)
	
	if(!overwritten):
		deaths.append([char_name,target_time])
		
		var file = File.new()
		file.open("user://saves/" + str(target_save) + "/deaths.json",File.WRITE)
		file.store_string(JSON.print(deaths))
		file.close()
	
func grant_cheat_access():
	var file = File.new()
	file.open("user://persistent/cheat.access",File.WRITE)
	file.store_string("GG")
	file.close()
	
func get_cheat_status():
	var file = File.new()
	return file.file_exists("user://persistent/cheat.access")
	
func _ready():
	var dir = Directory.new()
	
	for folder in necessary_directories:
		if(!dir.dir_exists("user://" + folder + "/")): 
			dir.make_dir("user://" + folder + "/")
			
			print(folder)
			if(folder == "saves"):
				firstboot = true
