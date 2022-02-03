tool
extends TextureProgress
export var quota = 20

var angle_progression = rand_range(0,2*PI-0.1)
export var angle_step = 5

func get_random_points(polygon: PoolVector2Array):
	var indices = range(1,len(polygon)+1)
	var p1_index = indices[randi()%(len(indices))]
	
	var adjacent_left = p1_index - 1
	if(adjacent_left == 0): adjacent_left = 4	
	var adjacent_right = (p1_index % 4) + 1
	
	indices.erase(p1_index)
	indices.erase(adjacent_left)
	indices.erase(adjacent_right)
	
	var p1 = polygon[p1_index-1]	
	var p2 = polygon[indices[randi()%(len(indices))] - 1]
	
	return [p1,p2]
		
func bisect(polygon : PoolVector2Array,p1 : Vector2, p2 : Vector2):
	var search_p = Array(polygon)
	
	var starting_index = 0
	var progression = 0
	
	var looped = false
	var has_jumped = false
	var until_jump = 0
	var target_vector = null
	
	var poly_1 = PoolVector2Array()
	var poly_2 = PoolVector2Array()
	
	# arrange vectors
	if(search_p.find(p2) < search_p.find(p1)):
		var temp = p1
		p1 = p2
		p2 = temp
	
	while(!looped):
		target_vector = polygon[progression]
		
		if(search_p.find(target_vector) == starting_index and has_jumped):
			looped = true
			break
		
		poly_1.append(target_vector)
		
		if(target_vector == p1):
			progression = search_p.find(p2)
			has_jumped = true
			
		else:
			progression += 1 
			
			if(progression >= len(search_p)):
				progression = 0
			
			if(!has_jumped):
				until_jump += 1
				
	looped = false
	has_jumped = false
	starting_index = until_jump
	
	progression = starting_index
	
	while(!looped):
		target_vector = polygon[progression]
		
		if(search_p.find(target_vector) == starting_index and has_jumped):
			looped = true
			break
		
		poly_2.append(target_vector)
		
		if(target_vector == p2):
			progression = search_p.find(p1)
			has_jumped = true
			
		else:
			progression += 1 
			
			if(progression >= len(search_p)):
				progression = 0
			
			if(!has_jumped):
				until_jump += 1
				
	return [poly_1,poly_2]

func split_into_tris(polygon: PoolVector2Array):
	
	var polygons = []
	
	if(len(polygon) > 3):
		
		var p1
		var p2
		var polygon_1 = PoolVector2Array()
		var polygon_2 = PoolVector2Array()
		var count = 0
		
		var points = get_random_points(polygon)
		p1 = points[0]
		p2 = points[1]
		
		polygons.append_array(bisect(polygon, p1, p2))
	
	else:
		polygons.append(polygon)
		
	var tris = []
	var nontris = []
	
	for poly in polygons:
		if len(poly) > 3:
			nontris.append(poly)
		else:
			tris.append(poly)
			
	if(len(nontris) != 0):
		for nontri in nontris:
			tris.append_array(split_into_tris(nontri))
		
	return tris

func bisect_poly_by_line(poly: PoolVector2Array, point: Vector2, slope: float):
	
	var new_poly = Array(poly)
	var to_add = []
	
	for pt in new_poly:
		var pt_adj = new_poly[(new_poly.find(pt)+1) % len(new_poly)]
		
		var point_2 = pt
		
		var intersect_x = 1.0
		var slope_2 = 0
		
		if(pt_adj.x-pt.x != 0):
			slope_2 = ((pt_adj.y-pt.y)/(pt_adj.x-pt.x))
		
			intersect_x = ((slope_2*point_2.x) - (slope * point.x) + (point.y - point_2.y))/(slope_2 - slope)
		else:
			print("what")
			intersect_x = 100
	
		if((intersect_x >= pt.x and intersect_x <= pt_adj.x) or (intersect_x <= pt.x and intersect_x >= pt_adj.x)):
			var point_to_add = Vector2(intersect_x, slope_2 * (intersect_x - point_2.x) + point_2.y)
			to_add.append([point_to_add,pt])	
	
	for group in to_add:
		new_poly.insert(new_poly.find(group[1]) + 1, group[0])
		
	if(len(to_add) == 2):

		var p1 = to_add[0][0]
		var p2 = to_add[1][0]
		
		if(p1 != p2):
			return bisect(PoolVector2Array(new_poly),p1,p2)
		
		else:
			return [PoolVector2Array(new_poly)]
	elif(len(to_add) == 1):
		return [PoolVector2Array(new_poly)]
		
	else:
		return [PoolVector2Array(new_poly)]

	

func bisect_polys_by_line(polygons : Array, rang: Vector2, type : String):
	var new_polygons = []
	
	var midpoint = Vector2(rang.x/2,rang.y/2)
	var point = Vector2.ZERO
	var slope = 0
	var rad = 3
	
	if(type == "random"):
		point = Vector2(rand_range((3),(rang.x-3)),rand_range((3),(rang.y-3)))
		slope = tan(rand_range(-1.4,1.4))
	elif(type == "middle"):
		point = midpoint
		slope = tan(angle_progression)
		angle_progression += rand_range(0,PI*2-0.1)/angle_step
	elif(type == "circum"):
		rad = rand_range(1.5,3)
		point = Vector2(rad*cos(angle_progression) + midpoint.x, rad*sin(angle_progression) + midpoint.y)
		slope = (-1*(midpoint.x-point.x))/(midpoint.y-point.y)
		angle_progression += rand_range(0,PI*2-0.1)/angle_step
	
	for poly in polygons:
		new_polygons.append_array(bisect_poly_by_line(poly,point,slope))
		
	return new_polygons
		

func shatter(rect_size: Vector2):
	var polygons = []
	var starting_polygon = PoolVector2Array()
	
	starting_polygon.append(Vector2(1,0))
	starting_polygon.append(Vector2(rect_size.x+1,0))
	starting_polygon.append(Vector2(rect_size.x,rect_size.y))
	starting_polygon.append(Vector2(0,rect_size.y))
	
	polygons.append(starting_polygon)
	var new_polys = []
	
	polygons = bisect_polys_by_line(polygons,rect_size,"middle")
	polygons = bisect_polys_by_line(polygons,rect_size,"middle")
	polygons = bisect_polys_by_line(polygons,rect_size,"middle")
	
	polygons = bisect_polys_by_line(polygons,rect_size,"circum")
	polygons = bisect_polys_by_line(polygons,rect_size,"circum")
	
	
	for polygon in polygons:
		var p = Polygon2D.new()
		p.polygon = polygon
		p.color = Color(rand_range(0,1),rand_range(0,1),rand_range(0,1),rand_range(0.5,1))
		self.add_child(p)
		p.set_owner(get_tree().edited_scene_root)

func _process(delta):
	if(self.visible == false):
		
		for child in self.get_children():
			child.queue_free()
		
		shatter(Vector2(10,5))
		self.visible = true
