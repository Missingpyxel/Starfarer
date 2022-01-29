extends Node

var directories = ["res://origins/"]

var character_registry = {}
var area_registry = {}
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
	
	# Phase 1
	for directory in directories:
		# Character Registry
		var chars = list_files_in_dir(directory + "/Characters/")
		print(chars)
		for chara in chars:
			character_registry[chara] = load(directory + "/Characters/" + chara + "/Character.tscn/")

		# Area Registry
		var planets = list_files_in_dir(directory + "/Planets/")
				
		for planet in planets:
			var areas = list_files_in_dir(directory + "/Planets/" + planet + "/")
			
			for area in areas:
				area_registry[area] = {
					"Path" : directory + "/Planets/" + planet + "/" + area + "/Area.tscn/",
					"Planet" : planet
				}
				
		# Chapter Registry
		var chapters = list_files_in_dir(directory + "/Chapters/")
		
		for chapter in chapters:
			chapter_registry[chapter] = load(directory + "/Chapters/" + chapter + "/Chapter.tscn/").instance()
				
		print(character_registry)
		print(area_registry)
		print(chapter_registry)
