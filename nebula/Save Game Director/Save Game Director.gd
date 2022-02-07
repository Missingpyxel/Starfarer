extends Node

var target_save = null
var target_chapter = null
var target_time = null

var firstboot = false

# Persistent
var default_settings = "res://nebula/Save Game Director/default_settings.json"
var settings = {
	
}
var cheat_access = false

# Universal
var difficulty = "starfarer"

# Chapter
var global_achievements = {
	"debug" : [
		"test"
	]
}

var global_values = {
	"debug" : {
		"test" : 0
	}
}

func is_achievement_completed(key : String, achievement: String):
	return (achievement in global_achievements.get(key, []))
	
func add_achievement(key : String, achievement: String):
	if(key in global_achievements.keys()):
		if !(achievement in global_achievements[key]):
			global_achievements[key].append(achievement)
	else:
		global_achievements[key] = [achievement]
		
func get_value(key : String, value : String):
	return global_values.get(key,{}).get(value,null)

func change_value(key : String, value : String, new_value):
	if(key in global_values.keys()):
		global_values[key][value] = new_value
	else:
		global_values[key] = {value: new_value}

var day = 0

onready var ald = Nebula.get_node("Area Loading Director")
onready var cld = Nebula.get_node("Character Loading Director")
onready var zd = Nebula.get_node("Zone Director")

export(Array) var necessary_directories = ["saves","mods","screenshots","persistent"]

func save_exists(chapter):
	var file = Directory.new()
	return file.dir_exists("user://saves/" + str(target_save) + "/chapters/" + str(target_chapter) + "/")

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

# On slot created
func initialize_slot(diff : String):
	var dir = Directory.new()
	var saves = list_files_in_dir("user://saves/")
	var maxn = 0
	
	for save in saves:
		maxn = max(maxn, int(save))
	maxn += 1
	
	dir.make_dir("user://saves/" + str(maxn) + "/")
	dir.make_dir("user://saves/" + str(maxn) + "/chapters/")
	
	difficulty = diff
	target_save = str(maxn)
	
	save_universal()

# If a save doesn't already exist for chapter...
func initialize_save(bypass = false):
	
	if(bypass or !save_exists(target_chapter)):
		
		var dir = Directory.new()
		dir.make_dir("user://saves/" + str(target_save) + "/chapters/" + str(target_chapter) + "/")
		
		var chapter_obj = Nebula.get_node("Registry Director").chapter_registry[target_chapter]
		save(chapter_obj)

# Settings and stuff
func load_persistent():
	var file = File.new()
	
	if(file.file_exists("user://settings.json")):
		file.open("user://settings.json", File.READ)
		var persistent_data = JSON.parse(file.get_as_text()).get_result()
		
		settings = persistent_data["settings"]
		cheat_access = persistent_data["cheat_access"]
		
	else:
		file.open(default_settings, File.READ)
		
		var default = JSON.parse(file.get_as_text()).get_result()
		file.close()
		
		settings = default
		
		save_persistent()
		load_persistent()

func save_persistent():
	var persistent_data = {}
	persistent_data["settings"] = settings
	persistent_data["cheat_access"] = cheat_access
	
	var persistent_file = File.new()
	persistent_file.open("user://settings.json", File.WRITE)
	persistent_file.store_string(JSON.print(persistent_data, "\t"))
	persistent_file.close()

# All stuff that transfers across the whole slot. Difficulty, character unlocks and deaths
func save_universal():
	if(target_save):
		var universal_data = {}
		
		universal_data["difficulty"] = difficulty
		
		var universal_file = File.new()
		universal_file.open("user://saves/" + str(target_save) + "/slot.json", File.WRITE)
		universal_file.store_string(JSON.print(universal_data, "\t"))
		universal_file.close()

# All chapter- and area-related stuff goes here
func save(chapter_obj = null):
	if(target_save and target_chapter):
		var chapter_data = {}
		
		chapter_data["difficulty"] = difficulty
		chapter_data["day"] = day
		chapter_data["global_achievements"] = global_achievements
		chapter_data["global_values"] = global_values
		
		if(chapter_obj != null):
			chapter_data["area"] = {}
			
			chapter_data["area"]["area"] = chapter_obj.starting_area
			chapter_data["area"]["position"] = Vector2.ZERO
			chapter_data["area"]["completed_zones"] = []
				
		else:
			chapter_data["area"] = get_area_object(true)
		
		var chapter_file = File.new()
		chapter_file.open("user://saves/" + str(target_save) + "/chapters/" + str(target_chapter) + "/save.json", File.WRITE)
		chapter_file.store_string(JSON.print(chapter_data, "\t"))
		chapter_file.close()
		
func get_area_object(pos = false):
	if(target_save and target_chapter):
		var area_data = {}
		
		area_data["area"] = ald.current_area
		area_data["position"] = cld.current_character.position
		area_data["completed_zones"] = zd.completed_zones
		
		return area_data
	
func load_game():
	var file = File.new()
	
	file.open("user://saves/" + str(target_save) + "/chapters/" + str(target_chapter) + "/save.json", File.READ)
	var chapter_data = JSON.parse(file.get_as_text()).get_result()
	
	difficulty = chapter_data["difficulty"]
	day = chapter_data["day"]
	global_achievements = chapter_data["global_achievements"]
	global_values = chapter_data["global_values"]
	
	Nebula.load_area(chapter_data["area"]["area"])
	ald.character_pos = parse_json(chapter_data["area"]["position"])
	
	file.close()
	
func _ready():
	var dir = Directory.new()
	
	Nebula.log("SAVEGAME", "Checking necessary user directories...")
	
	for folder in necessary_directories:
		if(!dir.dir_exists("user://" + folder + "/")): 
			
			Nebula.log("SAVEGAME", "Creating new directory " + folder)
			
			dir.make_dir("user://" + folder + "/")
			
			if(folder == "saves"):
				
				Nebula.log("SAVEGAME", "Assuming first boot due to absence of saves")
				firstboot = true
