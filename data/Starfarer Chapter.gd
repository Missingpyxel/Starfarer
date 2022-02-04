extends Node

export(String) var chapter_name = "Chapter"

export(String) var starting_area = "Testing Zone"
export(String) var starting_modifier = "None"
export(Array) var starting_characters = ["Null"]
export(int) var starting_day = 0

export(float) var time = -1.0

export(Array) var dependent_acts = []

func _ready():
	self.name = chapter_name
