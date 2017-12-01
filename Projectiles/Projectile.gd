extends Area2D

# class member variables go here, for example:
# var a = 2
export var speed = 100
export var damage = 10
export(String) var grouptarget
export(String) var groupignore

var motion


func _ready():
	add_to_group("Projectile")
	connect("body_enter",self,"body_enter")
	if(has_node("VisibilityNotifier2D")):
		get_node("VisibilityNotifier2D").connect("exit_screen",self,"exit_screen")
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	motion=Vector2(0,1).rotated(get_rot())*speed*delta
	translate(motion)
	pass

func body_enter(body):
	#Check body is targetable
	if (grouptarget!=null and body.is_in_group(grouptarget)):
		#Check for the method, just in case
		if (body.has_method("dmg")):
			body.dmg(damage)
	#If it isn't to be ignored...
	if (groupignore!=null and !body.is_in_group(groupignore)):
		queue_free()
	pass

func exit_screen():
	queue_free()



