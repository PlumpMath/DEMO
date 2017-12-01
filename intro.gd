extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	intro()
	pass

#If you want to use yield(), you CANNOT do it in _ready().
#It acts as if it had been called again after the node has been loaded (and thus crashes)

func intro():
	GAME.display_text("IN YEAR [color=yellow]201X[/color]...\nA SOLDIER RAN AWAY FROM HIS PLATOON")
	yield(GAME,"text_finished")
	get_node("Graphic").set_region_rect(Rect2(0,92,224,92))
	GAME.display_text("TO STOP HIS [color=red]3 GENERALS[/color]\nFROM BUILDING A WEAPON THAT THREATENED THE WORLD")
	yield(GAME,"text_finished")
	get_node("Graphic").set_region_rect(Rect2(0,184,224,92))
	GAME.display_text("MAKING HIS WAY TO A SECRET BASE IN THE ARCTIC\nHIS MISSION IS CLEAR")
	yield(GAME,"text_finished")
	get_node("Graphic").set_region_rect(Rect2(0,276,224,92))
	GAME.display_text("CANCEL THE NEXT DEMO!!!")
	yield(GAME,"text_finished")
	GAME.fade_to("res://Levels/Start.tscn","Start")
	pass

