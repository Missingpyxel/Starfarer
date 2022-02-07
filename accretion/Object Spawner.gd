extends Control

var dialogue_node = preload("res://objects/Dialogue Node.tscn")
var value_node = preload("res://objects/Value Node.tscn")

func create_object(resource):
	var node = resource.instance()
	
	node.placing = true
	node.obj = get_parent().get_node("Objects")
	node.mouse_inside = true
	node.rect_position = get_global_mouse_position() - Vector2(20,20)
	
	get_parent().get_node("Objects").add_child(node)
	
	node.get_node("Title Bar/TextEdit").text = node.name

func _on_Dialogue_Node_button_down():
	create_object(dialogue_node)

func _on_Value_Node_button_down():
	create_object(value_node)
