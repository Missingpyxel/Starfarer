extends Node
# cosmica area

# Can be menu, story, or combat
export var scene_type = "menu"
# Can be inherit, characterless, predetermined, or team
export var character_scene_type = "characterless"
# Team to set
export(Array) var set_team = null

# Dialogue to start?
export(Resource) var dialogue_to_start = null
# Camera on character?
export(bool) var camera_on_character = true

func _ready():
	Nebula.emit_signal("area_loaded")
