extends Node2D

# class member variables go here, for example:
# var a = 2
var pistolbullet = preload("res://Projectiles/pistol.tscn")

func _ready():
	set_process_input(true)
	pass

func _input(event):
	if (event.is_action_pressed("fire") and !get_parent().get_parent().get("frozen")):
		var pistoli = pistolbullet.instance()
		pistoli.set_global_rot(get_global_rot())
		pistoli.set_global_pos(get_node("ShootPos").get_global_pos())
		get_parent().get_parent().get_parent().add_child(pistoli)

