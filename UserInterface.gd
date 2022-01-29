extends Control

var ratio = 1.0
var dash_ratio = 1.0
export var max_width = 300.0
export var max_height = 20.0
export var hp_color = Color(0, 1, 0, 1)
export var damage_color = Color(1, 0, 0, 1)
export var dash_color = Color(0, 0, 1, 1)
export var dash_r_color = Color(0,0,0.5,1)

# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_node("/root/Main/Player")
	player.connect("update_health_and_damage", self, "_on_update_health_and_damage")
	player.connect("update_dash_cd", self, "_on_update_dash_cd")
	
func _draw():
	var vp_rect = get_viewport_rect().size
	var hp_width = max_width * ratio
	var damage_width = max_width * (1.0 - ratio)
	
	draw_rect(Rect2(0, 0, hp_width, max_height), hp_color)
	draw_rect(Rect2(hp_width, 0, damage_width, max_height), damage_color)
	
	var dash_y = - 5 - max_height
	var dash_width = (max_width - 200) * dash_ratio
	var dash_r_width = (max_width - 200) * (1.0 - dash_ratio)

	draw_rect(Rect2(100, dash_y, dash_width, max_height), dash_color)
	draw_rect(Rect2(dash_width + 100, dash_y, dash_r_width, max_height), dash_r_color)

func _on_update_health_and_damage(new_ratio):
	ratio = new_ratio
	update()	

func _on_update_dash_cd(new_dash_ratio):
	dash_ratio = new_dash_ratio
	update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
#	for enemy in get_node("/root/").get_tree().get_nodes_in_group("ENEMIES"):
#		print(get_global_transform_with_canvas())
