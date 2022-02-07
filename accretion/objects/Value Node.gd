extends "res://objects/Node Object.gd"

func get_type():
	return "value"

func get_valuetype():
	valuetype_button.get_item_text(valuetype_button.get_index())

onready var valuetype_button = get_node("TypeSelector")
onready var operation_button = get_node("OperationSelector")
onready var key_box = get_node("Key")
onready var value_box = get_node("Value")

func _ready():
	valuetype_button.add_item("Value")
	valuetype_button.add_item("Achievement")
	valuetype_button.select(0)
	generate_options(0)

func _on_TypeSelector_item_selected(index):
	generate_options(index)
	
func generate_options(index):
	operation_button.clear()
	
	match(index):
		0:
			operation_button.add_item("Set")
			operation_button.add_item("Add")
			key_box.rect_size.x = 156
			value_box.visible = true
		1:
			operation_button.add_item("Add")
			operation_button.add_item("Remove")
			key_box.rect_size.x = 268
			value_box.visible = false
			value_box.text = ""
			
	operation_button.select(0)
