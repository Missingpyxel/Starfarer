extends Node

#Self-Referential
var nebula = self
var randomizer = RandomNumberGenerator.new()
export var uts = 1.0
signal uts_changed

# Camera Director
signal change_camera_coordinates
signal change_camera_subject

signal save_subject
signal load_subject

signal camera_delta

# Area Loading Director
signal area_loaded
signal spawn_starter_character

# Character Loading Director
signal character_loaded

# Character Ability Director
signal ability_request
signal ability_approve

# Sound Effect Director
signal play_sound

# Logging

var phase = "LOADING"

func get_time():
	var time = OS.get_time()
	return str(time["hour"]) + ":" + str(time["minute"]) + ":" + str(time["second"])

func log(branch : String, to_log : String):
	print("[" + get_time() + " / " + phase + "] [" +  branch + "] " + to_log)

func get_character(name : String):
	return get_node("Registry Director").character_registry[name]

func load_area(name : String, modifier = "None"):
	get_node("Area Loading Director").load_area(name,get_node("Registry Director").area_registry[name]["Path"])

func get_root():
	return get_tree().root.get_child(1)

func _ready():
	Nebula.log("NEBULA","Loading complete!")
	phase = "GAMEPLAY"
	load_area("Title Screen")
