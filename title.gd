extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var cheatstring = ""
var cheat = "BUMBUMBUM"
var titlebgm = preload("res://Sound/Title.ogg")

func _ready():
	GAME.show_hp(false)
	BGM.stop()
	Globals.set("BGM",null)
	BGM.set_stream(titlebgm)
	BGM.play()
	Globals.set("HP",100)
	Globals.set("Direction",0)
	Globals.set("ActiveWarps",[])
	Globals.set("Weapons",[true,false,false,false])
	Globals.set("SelectedWeapon",0)
	set_process_input(true)
	get_node("Play").connect("pressed",self,"start")
	get_node("Load").connect("pressed",self,"continue_game")
	pass

func _input(event):
	#Cheat Check!
	if (event.type == InputEvent.KEY):
		if (event.pressed and !event.echo):
			cheatstring += OS.get_scancode_string(event.scancode)
			#removes all characters over 20
			while (cheatstring.length()>20):
				cheatstring = cheatstring.right(1)
			#checks if the player correctly entered a cheat
			if (cheatstring.find(cheat)!=-1):
				cheatstring = cheatstring.replace(cheat,"")
				get_tree().change_scene("res://ending.tscn")

func start():
	get_tree().change_scene("res://intro.tscn")

func continue_game():
	GAME.loadgame()

