extends CollisionShape2D

var arc_width = 20

func _draw():
	get_parent().get_parent().draw_hp()
	var mushrooms_in_area = get_parent().get_parent().mushrooms_in_area
	var min_connected_mushrooms = get_parent().get_parent().min_connected_mushrooms
	var max_connected_mushrooms = get_parent().get_parent().max_connected_mushrooms
	var rad = shape.radius
	draw_arc(Vector2(0,0), rad, 0, TAU * mushrooms_in_area / min_connected_mushrooms, 40, Color.GREEN, arc_width, true )
	if mushrooms_in_area > min_connected_mushrooms:
		draw_arc(Vector2(0,0),rad + arc_width, 0, TAU * (mushrooms_in_area - min_connected_mushrooms) / (max_connected_mushrooms - min_connected_mushrooms), 40, Color.GREEN, arc_width, true )