extends Control

var dialogue_node = preload("res://objects/Dialogue Node.tscn")

func _on_Dialogue_Node_pressed():
	pass

func _on_Dialogue_Node_button_down():
	var node = dialogue_node.instance()
	
	node.placing = true
	node.obj = get_parent().get_node("Objects")
	node.mouse_inside = true
	node.rect_position = get_global_mouse_position() - Vector2(20,20)
	
	get_parent().get_node("Objects").add_child(node)
	
	node.get_node("Titlebar/TextEdit").text = node.name
