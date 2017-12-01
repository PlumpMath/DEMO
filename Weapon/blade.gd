extends Node2D

# class member variables go here, for example:
# var a = 2
var blade = preload("res://Projectiles/sawblade.tscn")

func _ready():
	set_process_input(true)
	pass

func _input(event):
	if (event.is_action_pressed("fire") and !get_parent().get_parent().get("frozen")):
		var bladei = blade.instance()
		bladei.set("direction",get_parent().get_parent().get("direction"))
		if (Input.is_action_pressed("ui_up")):
			bladei.set("motion",Vector2(0,-bladei.get("speed")))
		bladei.set_global_pos(get_node("ShootPos").get_global_pos())
		get_parent().get_parent().get_parent().add_child(bladei)

