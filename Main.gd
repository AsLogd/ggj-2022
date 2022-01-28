extends Node

export (PackedScene) var mob_scene

func _process(delta):
	var enemy_count = get_tree().get_nodes_in_group("ENEMIES").size()
	var bullet_count = get_tree().get_nodes_in_group("BULLETS").size()
	get_node("EnemyLabel").text = "Enemies: " + str(enemy_count)
	get_node("BulletLabel").text = "Bullets: " + str(bullet_count)

func _ready():
	get_node("EnemyLabel").add_color_override("font_color", Color(0,0,0,1))
	get_node("BulletLabel").add_color_override("font_color", Color(0,0,0,1))
	randomize()

func _on_MobTimer_timeout():
	# Create a Mob instance and add it to the scene.
	var mob = mob_scene.instance()
	var out_coords = get_node("Player").get_outside_coords()
	var player_position = $Player.transform.origin
	add_child(mob)
	mob.initialize(out_coords, $Player)
