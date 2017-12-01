extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	get_node("Button").connect("pressed",self,"end")
	pass

func end():
	get_tree().change_scene("res://title.tscn")

