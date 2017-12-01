extends CanvasLayer

# class member variables go here, for example:
# var a = 2
var textqueue = []

func _ready():
	#The text box can hold 3 lines at a time!
	add_user_signal("text_finished")
	get_node("TextBox/TextDelay").connect("timeout",self,"next_letter")
	get_node("TextBox/Text").set_scroll_active(false)
	set_process_input(true)
	Globals.set("ActiveWarps",[])
	Globals.set("Stats",{})
	Globals.get("Stats")["Time"] = 55
	Globals.get("Stats")["EnemiesKilled"] = 55
	pass


func display_text(text):
	textqueue.push_back(text)
	if (textqueue.size()==1):
		get_node("TextBox/Text").set_visible_characters(0)
		get_node("TextBox/Text").set_bbcode(textqueue[0])
		get_node("TextBox").show()
		get_node("TextBox/TextDelay").start()
	pass

func next_letter():
	if (!get_node("TextBox/Text").get_visible_characters() >= textqueue[0].length()):
		get_node("TextBox/Text").set_visible_characters(get_node("TextBox/Text").get_visible_characters()+1)
	else:
		get_node("TextBox/TextDelay").stop()
	pass

func next_text():
	get_node("TextBox/Text").set_visible_characters(0)
	textqueue.pop_front()
	if (textqueue.empty()):
		#WARNING, ensure the signal is emmited AFTER THE BOX IS HIDDEN
		#OR ELSE IF YOU USE A YIELD WAITING FOR text_finished to go directly onto more text...
		#IT WON'T WORK!!!
		get_node("TextBox").hide()
		emit_signal("text_finished")
	else:
		get_node("TextBox/Text").set_bbcode(textqueue[0])
		get_node("TextBox/TextDelay").start()
	pass

func set_text_delay(delay):
	get_node("TextBox/TextDelay").set_wait_time(delay)

#Level changing script!
func fade_to(level, entrance):
	get_node("Fader/FaderAnim").play("FadeIn")
	Globals.set("MapEntrance",entrance)
	get_tree().change_scene(level)
	get_node("Fader/FaderAnim").play("FadeOut")
	

func _input(event):
	if (event.is_action_pressed("fire") and !event.is_echo()):
		if(!textqueue.empty()):
			if (get_node("TextBox/Text").get_visible_characters() >= textqueue[0].length()):
				next_text()
			else:
				get_node("TextBox/Text").set_visible_characters(textqueue[0].length())
			pass

func show_hp(show):
	if (show):
		get_node("HP").show()
	else:
		get_node("HP").hide()



func update_hp(hp):
	get_node("HP").set_text(str(hp))

func savegame(level,entrance):
	var file = File.new()
	file.open("user://savegame.sav", File.WRITE)
	var data = {
	"Weapons":Globals.get("Weapons"),
	"ActiveWarps":Globals.get("ActiveWarps"),
	"LoadLevel":level,
	"LoadEntrance":entrance
	}
	file.store_var(data)
	file.close()
	pass

func loadgame():
	var file = File.new()
	if (file.file_exists("user://savegame.sav")):
		file.open("user://savegame.sav", File.READ)
		var data = file.get_var()
		Globals.set("Weapons",data["Weapons"])
		Globals.set("ActiveWarps",data["ActiveWarps"])
		print(str(data["ActiveWarps"]))
		fade_to(data["LoadLevel"],data["LoadEntrance"])
	pass

func game_over():
	get_tree().change_scene("res://title.tscn")
	pass



