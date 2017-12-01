extends Node2D

# class member variables go here, for example:
export(String,FILE) var destination
export(String) var entrance
export(int,"Right","Left") var direction = 0

func _ready():
	get_node("Area2D").connect("body_enter",self,"body_enter")
	pass

func body_enter(body):
	if (body.is_in_group("Player")):
		body.freeze()
		Globals.set("Direction",direction)
		GAME.fade_to(destination,entrance)

