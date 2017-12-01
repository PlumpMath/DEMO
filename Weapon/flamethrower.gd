extends Node2D

# class member variables go here, for example:
# var a = 2
var flame = preload("res://Projectiles/flame.tscn")

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
		var flamei = flame.instance()
		flamei.set("direction",get_parent().get_parent().get("direction"))
		if (Input.is_action_pressed("ui_up")):
			flamei.set("motion",Vector2(0,-flamei.get("speed")))
		flamei.set_global_pos(get_node("ShootPos").get_global_pos())
		get_parent().get_parent().get_parent().add_child(flamei)
