extends StaticBody2D

@export var hp := 20.0
@export var max_hp := 100.0
@export var radius := 100.0

var mushrooms_in_area := 0

const sprite_variants_number := 3

func get_mushrooms_in_area():
	mushrooms_in_area = 0
	var areas = get_node("NeighborRange").get_overlapping_areas()
	for a in areas:
		var obj = a.get_parent()
		if obj is Mushroom:
			mushrooms_in_area += 1
	
func _ready() -> void:
	var sprite_variant := randi_range(0,sprite_variants_number - 1)
	var sprite = get_node("Sprite") as Sprite2D
	sprite.frame = sprite_variant
	var flip = randi_range(0,1)
	if flip == 1:
		sprite.flip_h = true

#func _process(_delta: float):
#	modulate.r = hp/max_hp
#	modulate.g = hp/max_hp
#	modulate.b = hp/max_hp

	if Input.is_action_just_pressed("debug"):
		get_mushrooms_in_area()

func _draw():
	var rad = get_node("NeighborRange/CollisionShape2D").shape.radius
	draw_circle(Vector2(0,0), rad, Color.GREEN, false, 2, true)
