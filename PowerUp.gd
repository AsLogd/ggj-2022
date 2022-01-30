extends Spatial


export var heal_quantity = 20

signal pickup

func _ready():
	connect("pickup", get_node("/root/Main/Player"), "_on_HealthPowerUp_pickup")
	
	
func _on_Area_body_entered(body):
	if body.name == "Player":
		emit_signal("pickup", heal_quantity)
