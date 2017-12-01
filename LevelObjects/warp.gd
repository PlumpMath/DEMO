extends Area2D

# class member variables go here, for example:
var playertouching = false
var warpto = 0
onready var level = get_tree().get_current_scene().get_filename()
onready var path = get_path()
export(String) var name = "Undefined"
export(String) var entrance
var active = false
var thiswarp
var transitioning = false
var activewarps

func _ready():
	activewarps = Globals.get("ActiveWarps")
	thiswarp = {"name":name,"level":level,"entrance":entrance}
	#Is this warp in the current pool of active warps?
	#ps. SIMPLY USING has() DOES NOT WORK FOR SOME REASON
	#NOR DOES COMPARING TO DICTIONARIES WITH ==
	#EVEN THIS DOESN'T WORK AFTER A GAME RELOAD
	#FIX PLOX
	var n = 0
	for i in activewarps:
		if (i.hash() == thiswarp.hash()):
			active=true
			break
		else:
			n+=1
	#If it's active we don't need the red effect
	if (active):
		get_node("BigPortal").set_modulate(Color(1,1,1))
		get_node("MiniPortals/MiniPortal").set_modulate(Color(1,1,1))
		get_node("MiniPortals/MiniPortal1").set_modulate(Color(1,1,1))
		get_node("MiniPortals/MiniPortal2").set_modulate(Color(1,1,1))
		get_node("MiniPortals/MiniPortal3").set_modulate(Color(1,1,1))
	get_node("WarpTo").set_text(name)
	warpto = n
	connect("body_enter",self,"body_enter")
	connect("body_exit",self,"body_exit")
	set_process_input(true)
	pass

func body_enter(body):
	#Did the player just enter?
	if (body.is_in_group("Player")):
		playertouching = true
		#Refill the player's health!
		body.set("hp",100)
		Globals.set("HP",100)
		GAME.update_hp(100)
		#Save the game!!
		GAME.savegame(level,entrance)
		#if this warp isn't active, activate it!
		if (!active):
			activewarps.push_front(thiswarp)
			Globals.set("ActiveWarps", activewarps)
			warpto = 0
			active=true
			get_node("BigPortal").set_modulate(Color(1,1,1))
			get_node("MiniPortals/MiniPortal").set_modulate(Color(1,1,1))
			get_node("MiniPortals/MiniPortal1").set_modulate(Color(1,1,1))
			get_node("MiniPortals/MiniPortal2").set_modulate(Color(1,1,1))
			get_node("MiniPortals/MiniPortal3").set_modulate(Color(1,1,1))
		get_node("BigPortal").set_region_rect(Rect2(24,0,16,16))
		get_node("MiniPortals/MiniPortal").set_region_rect(Rect2(0,8,8,8))
		get_node("MiniPortals/MiniPortal1").set_region_rect(Rect2(0,8,8,8))
		get_node("MiniPortals/MiniPortal2").set_region_rect(Rect2(0,8,8,8))
		get_node("MiniPortals/MiniPortal3").set_region_rect(Rect2(0,8,8,8))
		get_node("WarpTo").show()
	

func body_exit(body):
	#Did the player just leave?
	if (body.is_in_group("Player")):
		playertouching = false
		get_node("BigPortal").set_region_rect(Rect2(8,0,16,16))
		get_node("MiniPortals/MiniPortal").set_region_rect(Rect2(0,0,8,8))
		get_node("MiniPortals/MiniPortal1").set_region_rect(Rect2(0,0,8,8))
		get_node("MiniPortals/MiniPortal2").set_region_rect(Rect2(0,0,8,8))
		get_node("MiniPortals/MiniPortal3").set_region_rect(Rect2(0,0,8,8))
		get_node("WarpTo").hide()
	

func _input(event):
	if (playertouching and event.is_action_pressed("nweapon")):
		warpto+=1
		if (warpto>activewarps.size()-1):
			warpto=0
		get_node("WarpTo").set_text(activewarps[warpto]["name"])
		pass
	if (playertouching and event.is_action_pressed("pweapon")):
		warpto-=1
		if (warpto<0):
			warpto=activewarps.size()-1
		get_node("WarpTo").set_text(activewarps[warpto]["name"])
		pass
	if (playertouching and event.is_action_pressed("fire") and !event.is_echo() and !transitioning):
		transitioning = true
		GAME.fade_to(activewarps[warpto]["level"],activewarps[warpto]["entrance"])
		pass

