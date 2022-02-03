extends Node

# preconditions:
# Camera Director

var dialogue_path = "res://origins/assets/dialogue/"
var portrait_path = "res://origins/assets/textures/portraits/"

onready var border = get_node("Dialogue Border")
onready var name_box = get_node("Dialogue Border/Name")
onready var text_box = get_node("Dialogue Border/Label")
onready var arrow = get_node("Dialogue Border/Arrow")

onready var animator = get_node("Dialogue Box Animator")
onready var arrow_animator = get_node("Arrow Animator")

var default_file = File.new()
var default_dialogue_dictionary = {}

var phase = "none"

var current_dialogue = []
var current_index = [0,0]
var block_switching = false
var secondary_emotion = false

var finished = false

func _ready():
	# setup
	default_file.open(dialogue_path + "default.tres", File.READ)
	default_dialogue_dictionary = parse_json(default_file.get_as_text())
	default_file.close()
	
	border.rect_position.y = 190
	border.modulate = Color.transparent
	get_node("SpeakerRight").modulate = Color.transparent
	arrow.visible = false
	
	#yield(get_tree().create_timer(1.5),"timeout")
	#start_dialogue("test")

# default-ifys the dialogue object
func construct_dialogue_object(passed : Array):
	var final_list = []
	
	for dialogue_info in passed:
		var new_entry = default_dialogue_dictionary.duplicate()
		var default_line = new_entry["lines"][0].duplicate()
		
		# copy all of the keys to the default object
		for key in dialogue_info:
			new_entry[key] = dialogue_info[key]
			
		new_entry["lines"] = []
		
		for line in dialogue_info["lines"]:
			var new_line = default_line.duplicate()
			
			for key in line:
				new_line[key] = line[key]
				
			new_entry["lines"].append(new_line)
		final_list.append(new_entry)
		
	return final_list

func start_dialogue(path : String):
	var finished = false
	var total_path = dialogue_path + path + ".tres"
	
	var target_file = File.new()
	target_file.open(total_path,File.READ)
	
	var objects_list = parse_json(target_file.get_as_text())
	target_file.close()
	
	current_dialogue = construct_dialogue_object(objects_list)
	current_index = [0,0]
	secondary_emotion = false
	Nebula.emit_signal("save_subject")
		
	animator.queue("Pop In")
	name_box.text = current_dialogue[current_index[0]]["speaker"]
	yield(get_tree().create_timer(0.3), "timeout")
	advance_dialogue()
				
func advance_dialogue():
	var current_block = current_dialogue[current_index[0]]
	var current_line = current_block["lines"][current_index[1]]
	
	arrow_animator.stop()
	arrow.visible = false
	
	text_box.visible_characters = 0
	text_box.bbcode_text = current_line["text"]
	
	if(current_line["expression"] != null):
		get_node("SpeakerRight").texture = load('res://origins/assets/portraits/' + current_block["speaker"].to_lower() + '/'+ current_line["expression"].to_lower() + '.png')
	
		if(secondary_emotion):
			get_node("Speaker Animator").play("Emotion Change")
	
		secondary_emotion = true
	
	if(current_line["sound"]):
		Nebula.emit_signal("play_sound",current_line["sound"])
			
	phase = "scrolling"
	for i in range(0,len(current_line["text"])):
		text_box.visible_characters += 1
		
		if(phase == "skipping"):
			text_box.visible_characters = -1
			break
		
		if(text_box.bbcode_text[text_box.visible_characters-1] != " "):
			get_node("Blooper").play()
			
		yield(get_tree().create_timer(current_line["speed"]), "timeout")
	phase = "stopped"
	
	arrow.visible = true
	arrow_animator.play("Arrow Bounce")
	
	if(current_index[1] < len(current_block["lines"])-1):
		current_index[1] += 1
	else:
		if(current_index[0] < len(current_dialogue)-1):
			current_index[0] += 1
			current_index[1] = 0
			block_switching = true
		else:
			current_index[0] = -1
	
func stop_dialogue():
	Nebula.emit_signal("load_subject")
	animator.play_backwards("Pop In")
				
func _process(delta):
	if(Input.is_action_just_pressed("main") and !finished):
		match(phase):
			"stopped":
				if(current_index[0] != -1):
					if(!block_switching):
						advance_dialogue()
					else:
						var next_block = current_dialogue[current_index[0]]
						var next_line = next_block["lines"][0]
						
						if(next_block["wait"] > 0):
							animator.play_backwards("Pop In")
							yield(get_tree().create_timer(0.2 + next_block["wait"]), "timeout")
						else:
							animator.play("Character Swap")
							yield(get_tree().create_timer(0.2), "timeout")
						
						if(next_block["new_camera_subject"]):
							var new_subject = get_parent().get_node(next_block["new_camera_subject"])
							Nebula.emit_signal("change_camera_subject",new_subject)
						
						name_box.text = next_block["speaker"]
						text_box.visible_characters = 0
						
						secondary_emotion = false
						if(next_line["expression"] != null):
							get_node("SpeakerRight").texture = load('res://origins/assets/portraits/' + next_block["speaker"].to_lower() + '/'+ next_line["expression"].to_lower() + '.png')
						
						if(next_block["wait"] > 0):
							animator.play("Pop In")

						yield(get_tree().create_timer(0.3), "timeout")
							
						block_switching = false
						advance_dialogue()
				else:
					finished = true
					stop_dialogue()
			"scrolling":
				phase = "skipping"
