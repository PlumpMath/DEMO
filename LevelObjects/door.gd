extends Area2D

export(String,FILE) var destination
export(String) var entrance
export(int,"Right","Left") var direction = 0

var player
var playertouching = false
var transitioning = false

func _ready():
	connect("body_enter",self,"on_body_enter")
	connect("body_exit",self,"on_body_exit")
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	#is the player touching? are we already transitioning? Has a destination been set?
	if (Input.is_action_pressed("ui_up") and playertouching and not transitioning and destination!=null and entrance!=null):
		transitioning=true
		player.freeze()
		Globals.set("Direction",direction)
		GAME.fade_to(destination,entrance)
		pass

func on_body_enter(body):
	#if player enters, let me know!
	if (body.is_in_group("Player")):
		playertouching = true
		player=body
	

func on_body_exit(body):
	#if player leaves, let me know!
	if (body.is_in_group("Player")):
		playertouching = false