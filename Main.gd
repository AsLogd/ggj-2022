extends Node

export (PackedScene) var mob_scene

var playing = false

var score = 0
var multi = 1

signal game_over
signal game_start

func _process(delta):
	var enemy_count = get_tree().get_nodes_in_group("ENEMIES").size()
	var bullet_count = get_tree().get_nodes_in_group("BULLETS").size()
	multi = get_node("Player").get_multi()
	get_node("ScoreLabel").text = str(score)
	get_node("MultiLabel").text = "x" + str(multi)
	get_node("EnemyLabel").text = "Enemies: " + str(enemy_count)
	get_node("BulletLabel").text = "Bullets: " + str(bullet_count)
	if(!playing):
		if Input.is_action_pressed("dash"):
			get_node("GameOverLabel").percent_visible = 0
			get_tree().reload_current_scene()
			emit_signal("game_start")

func _ready():
	emit_signal("game_start")
	playing = true
	get_node("EnemyLabel").add_color_override("font_color", Color(0,0,0,1))
	get_node("BulletLabel").add_color_override("font_color", Color(0,0,0,1))
	get_node("GameOverLabel").add_color_override("font_color", Color(0,0,0,1))
	get_node("ScoreLabel").add_color_override("font_color", Color(0,0,0,1))
	get_node("MultiLabel").add_color_override("font_color", Color(0,0,0,1))
	
	randomize()
	find_node("Spawner").spawn()


func add_score(s):
	score += s*multi

func _on_MobTimer_timeout():
	if(playing):
		find_node("Spawner").spawn()

func _on_Player_dies():
	emit_signal("game_over")
	score = 0
	multi = 1
	playing = false
	get_node("GameOverLabel").percent_visible = 1
