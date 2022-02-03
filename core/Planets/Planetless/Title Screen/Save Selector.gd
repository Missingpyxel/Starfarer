extends TextureRect

var slot_prefab = preload("res://core/Planets/Planetless/Title Screen/Save Slot Stuff/Slot.tscn")
onready var scrollbar = get_node("VScrollBar")
onready var scroll_tween = scrollbar.get_node("Scroll Tween")
onready var slots = get_node("Slots")

var practical_scroll = 0.0

func create_slots():
	var dir = Directory.new()
	var saves = []
	
	dir.open("user://saves/")
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			saves.append(file)		
	
	for save in saves:
		var slot = slot_prefab.instance()
		var file = File.new()
		file.open("user://saves/" + str(save) + "/slot.json",File.READ)
		
		var slot_info = JSON.parse(file.get_as_text()).get_result()
		
		slot.get_node("Number Label").text = save
		slot.get_node("Mode Indicator").texture = load("res://core/Planets/Planetless/Title Screen/Save Slot Stuff/" + slot_info["difficulty"].capitalize() +"Mini.png")
		
		slots.add_child(slot)
		slots.move_child(slot,get_node("Slots/Button").get_index())
		
		slot.connect("pressed",self,"click",[save])

func set_scrollbar():
	var diff = 0
	
	for slot in slots.get_children():
		diff += slot.rect_size.y
	
	diff -= slots.rect_size.y
		
	if(diff > 0):
		scrollbar.max_value = diff
	else:
		scrollbar.max_value = 0

func click(save):
	Nebula.get_node("Save Game Director").target_save = save
	
	get_parent().get_node("Act Selector").construct_act_selector()
	get_parent().get_node("Save Slot Animation").play("Pop Out")
	get_parent().get_node("Act Selector Animation").play("Fade In")

func _ready():
	create_slots()
	set_scrollbar()
		
func _process(delta):
	for slot in slots.get_children():
		slot.rect_position.y = -scrollbar.value + slots.get_children().find(slot) * 30
		
func tween_scroll(val):
	practical_scroll += val
	
	if(practical_scroll > scrollbar.max_value):
		practical_scroll = scrollbar.max_value
	
	if(practical_scroll < scrollbar.min_value):
		practical_scroll = scrollbar.min_value
	
	scroll_tween.interpolate_property(scrollbar, "value", scrollbar.value, practical_scroll, 0.15, Tween.TRANS_QUAD, Tween.EASE_OUT)
	scroll_tween.start()
		
func _input(event):
	if(event is InputEventMouseButton):
		if(event.button_index == 4 and !Input.is_action_pressed("main")):
			tween_scroll(-5)
		elif(event.button_index == 5 and !Input.is_action_pressed("main")):
			tween_scroll(5)
		
		if(event.button_index == 1 and event.pressed == false):
			practical_scroll = scrollbar.value

func _on_Button_pressed():
	get_parent().get_node("Difficulty Selector Animation").play("Pop In")
	get_parent().get_node("Save Slot Animation").play("Pop Out")
