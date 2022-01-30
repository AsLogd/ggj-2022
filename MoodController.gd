extends Node

var bgm_player

var health_pc = 100
var last_health_pct = -1

export var bgm_mood = {
	100 : "res://sound/bgm_happy.wav",
	75  : "res://sound/bgm_uneasy.wav",
	50  : "res://sound/bgm_tense.wav",
	25  : "res://sound/bgm_fuck.wav",
}


# Called when the node enters the scene tree for the first time.
func _ready():

	bgm_player = get_node("BGM_player_1")
	set_mood()

	var player = get_node("/root/Main/Player")
	player.connect("update_health_and_damage", self, "_on_update_health_and_damage")
	player.connect("dies", self, "_on_dies")

func _on_update_health_and_damage(new_ratio):
	health_pc = new_ratio * 100
	set_mood()

func set_mood():
	# Sets bgm
	var pct_i
	for pct in bgm_mood:
		if (health_pc <= pct):
			pct_i = pct

	if last_health_pct != pct_i:
		last_health_pct = pct_i
		var audioRes = load(bgm_mood[pct_i])
		bgm_player.set_stream(audioRes)
		bgm_player.play()

func _on_dies():
	bgm_player.stop()
	
