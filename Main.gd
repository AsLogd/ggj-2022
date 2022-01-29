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
<<<<<<< HEAD
	# Create a Mob instance and add it to the scene.
	var mob = mob_scene.instance()
	var out_coords = get_node("Player").get_outside_coords()
	var player_position = $Player.transform.origin
	add_child(mob)
	mob.initialize(out_coords, $Player, 5)
=======
	get_node("Spawner").spawn()
>>>>>>> 287b5f5aed9d05f9ceed7006c0eec92db4703e4d
