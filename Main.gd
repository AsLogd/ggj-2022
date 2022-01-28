extends Node

export (PackedScene) var mob_scene


func _ready():
	randomize()

func _on_MobTimer_timeout():
	# Create a Mob instance and add it to the scene.
	var mob = mob_scene.instance()
	var out_coords = get_node("Player").get_outside_coords()
	var player_position = $Player.transform.origin
	add_child(mob)
	mob.initialize(out_coords, $Player)
