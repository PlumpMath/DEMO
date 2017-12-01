extends Node2D

# class member variables go here, for example:
# var a = 2
export var camfollowplayer = true
export(String,FILE) var bgm
export var autoplaybgm = true
var entrance

func _ready():
	entrance = Globals.get("MapEntrance")
	if (entrance!=null):
		get_node("Playfield/Player").set_global_pos(get_node("Entrances/"+entrance).get_global_pos())
	if (bgm!=null):
		var loadedbgm = load(bgm)
		if (Globals.get("BGM") == null or bgm != Globals.get("BGM")):
			BGM.set_stream(loadedbgm)
			if (autoplaybgm):
				BGM.play()
			Globals.set("BGM",bgm)
		pass
	
	set_process(true)
	pass

func _process(delta):
	if (camfollowplayer):
		get_node("Camera").set_global_pos(get_node("Playfield/Player").get_global_pos())
