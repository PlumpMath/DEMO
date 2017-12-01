extends Area2D

# class member variables go here, for example:
# var a = 2
export(Array) var text

var playertouching = false
var readingtext = false
var player

func _ready():
	connect("body_enter",self,"body_enter")
	connect("body_exit",self,"body_exit")
	set_process_input(true)
	pass

func _input(event):
	if (event.is_action_pressed("fire") and playertouching and !readingtext):
		player.freeze()
		readingtext=true
		for i in text:
			GAME.display_text(i)
		yield(GAME,"text_finished")
		player.unfreeze()
		readingtext=false



func body_enter(body):
	if (body.is_in_group("Player")):
		player = body
		playertouching = true
	pass

func body_exit(body):
	if (body.is_in_group("Player")):
		playertouching = false



