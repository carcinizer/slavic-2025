extends StaticBody2D

@export var hp := 20.0
@export var max_hp := 100.0
@export var radius := 100.0

var checked_mushrooms: Array[Mushroom] = []

const sprite_variants_number := 3

func check_area(areas: Array[Area2D]):
	for a in areas:
		var obj = a.get_parent()
		if obj is Mushroom and !(obj in checked_mushrooms):
			obj.connected_to_a_tree = true
			obj.queue_redraw()
			checked_mushrooms.push_back(obj)
			var othersareas = a.get_overlapping_areas()
			print(obj.name)
			check_area(othersareas)

func check_for_connections():
	var areas = get_node("NeighborRange").get_overlapping_areas()
	checked_mushrooms = []
	check_area(areas)
	
func _ready() -> void:
	var sprite_variant := randi_range(0,sprite_variants_number - 1)
	var sprite = get_node("Sprite") as Sprite2D
	sprite.frame = sprite_variant
	var flip = randi_range(0,1)
	if flip == 1:
		sprite.flip_h = true

func _process(_delta: float):
	modulate.r = hp/max_hp
	modulate.g = hp/max_hp
	modulate.b = hp/max_hp

	if Input.is_action_just_pressed("debug"):
		check_for_connections()

func _draw():
	var rad = get_node("NeighborRange/CollisionShape2D").shape.radius
	draw_circle(Vector2(0,0), rad, Color.GREEN, false, 2, true)
