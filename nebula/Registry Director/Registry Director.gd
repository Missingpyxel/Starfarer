extends Node

var directories = ["res://content/core/","res://content/origins/","res://content/story/"]

var character_registry = {}
var area_registry = {}
var modifier_registry = {}
var chapter_registry = {}

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

func _ready():
	
	Nebula.log("REGISTRY","Initializing core directories...")
	
	# Mod Loading
	for mod in list_files_in_dir("user://mods/"):
		directories.append("user://mods/" + mod + "/")
		Nebula.log("REGISTRY","Found mod: " + mod)
	
	# Phase 1
	for directory in directories:
		Nebula.log("REGISTRY","Loading directory: " + directory)
		
		# Character Registry
		var chars = list_files_in_dir(directory + "/Characters/")
		for chara in chars:
			character_registry[chara] = load(directory + "/Characters/" + chara + "/Character.tscn/")

		# Area / Modifier Registry
		var planets = list_files_in_dir(directory + "/Planets/")
		var dir = Directory.new()
				
		for planet in planets:
			var areas = list_files_in_dir(directory + "/Planets/" + planet + "/")
			
			for area in areas:
				
				if !(area in modifier_registry.keys()):
					modifier_registry[area] = []
				
				var mod_path = directory + "Planets/" + planet + "/" + area + "/Modifiers/"
				
				if(dir.dir_exists(mod_path)):
					var modifiers = list_files_in_dir(mod_path)
					
					for modifier in modifiers:
						modifier_registry[area].append(mod_path + modifier)
						
				var area_path = directory + "Planets/" + planet + "/" + area + "/Area.tscn"
				
				if(dir.file_exists(area_path)):
					area_registry[area] = {
						"Path" : area_path,
						"Planet" : planet,
					}
				
		# Chapter Registry
		if(dir.dir_exists(directory + "Chapters/")):
			var chapters = list_files_in_dir(directory + "Chapters/")
			
			for chapter in chapters:
				chapter_registry[chapter] = load(directory + "Chapters/" + chapter + "/Chapter.tscn/").instance()
			
