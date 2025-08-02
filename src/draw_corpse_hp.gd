extends CollisionShape2D

var arc_width = 20

func _draw():
	var rad = shape.radius
	var color = Color(0.6, 0.1, 0.2, 0.5)
	var hp = get_parent().get_parent().hp
	var max_hp = get_parent().get_parent().max_hp
	draw_arc(Vector2(0,0), rad, 0, TAU * hp / max_hp, 40, color, arc_width, true )

