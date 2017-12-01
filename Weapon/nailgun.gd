extends Node2D

# class member variables go here, for example:
# var a = 2
var nail = preload("res://Projectiles/nail.tscn")

func _ready():
	get_node("Timer").connect("timeout",self,"timeout")
	set_process_input(true)
	pass

func _input(event):
	if (event.is_action_pressed("fire") and !event.is_echo()):
		get_node("Timer").start()
	if (event.is_action_released("fire")):
		get_node("Timer").stop()



func timeout():
	if (!get_parent().get_parent().get("frozen")):
		var naili = nail.instance()
		naili.set_global_rot(get_global_rot())
		naili.set_global_pos(get_node("ShootPos").get_global_pos())
		get_parent().get_parent().get_parent().add_child(naili)
