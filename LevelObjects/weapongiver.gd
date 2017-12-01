extends Area2D

# class member variables go here, for example:
# var a = 2
export var weapon = 0
export(Array) var text

func _ready():
	if (Globals.get("Weapons")!=null):
		if (!Globals.get("Weapons").empty() and Globals.get("Weapons")[weapon]):
			hide()
			queue_free()
		else:
			show()
			connect("body_enter",self,"body_enter")
		pass

func body_enter(body):
	if (body.is_in_group("Player")):
		body.get("weapon")[weapon]["obtained"] = true
		if (Globals.get("Weapons")!=null and !Globals.get("Weapons").empty()):
			Globals.get("Weapons")[weapon] = true
		else:
			var n = 0
			Globals.set("Weapons",[])
			for i in body.get("weapon"):
				Globals.get("Weapons").push_back(i["obtained"])
				n+=1
		if (text!=null):
			body.freeze()
			for i in text:
				GAME.display_text(i)
			yield(GAME,"text_finished")
			body.unfreeze()
		queue_free()

