extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
var hp = 500

func _ready():
	add_to_group("Enemy")
	pass

func dmg(dmg):
	hp-=dmg
	if (hp<1):
		die()
	get_node("Health").set_text(str(hp))

func die():
	get_tree().change_scene("res://ending.tscn")
	pass
