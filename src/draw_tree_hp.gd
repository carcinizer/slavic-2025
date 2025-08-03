extends CollisionShape2D

var arc_width = 20

func _draw():

	var rad = shape.radius
	var color = Color(0.6, 0.1, 0.2, 0.5)
	var hp = get_parent().get_parent().hp
	var max_hp = get_parent().get_parent().max_hp
	draw_arc(Vector2(0,0), rad - arc_width, 0, TAU * hp / max_hp, 40, color, arc_width, true )

	var mushrooms_in_area = get_parent().get_parent().mushrooms_in_area
	var min_connected_mushrooms = get_parent().get_parent().min_connected_mushrooms
	var max_connected_mushrooms = get_parent().get_parent().max_connected_mushrooms
	if mushrooms_in_area >= max_connected_mushrooms:
		color = Color(0.6, 0.1, 0.2, 0.5)
	elif mushrooms_in_area > min_connected_mushrooms:
		color = Color(0.8, 0.8, 0.8, 0.5)
	else:
		color =  Color(0.1, 0.8, 0.2, 0.5)
	# color = Color(0.1, 0.8, 0.2, 0.5) if mushrooms_in_area < min_connected_mushrooms else Color(0.8, 0.8, 0.8, 0.5)
	draw_arc(Vector2(0,0), rad, 0, TAU * mushrooms_in_area / max_connected_mushrooms, 40, color, arc_width, true )
	# if mushrooms_in_area > min_connected_mushrooms:
	# 	color = Color(0.8, 0.8, 0.8, 0.5)
	# 	draw_arc(Vector2(0,0),rad + arc_width, 0, TAU * (mushrooms_in_area - min_connected_mushrooms) / (max_connected_mushrooms - min_connected_mushrooms), 40, color, arc_width, true )
