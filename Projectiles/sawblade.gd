extends KinematicBody2D

#TODO, make the blade go through enemies but not walls
#(Or maybe  it slicing along the path of an enemy is ok???)
#maybe I should put it on a separate collision layer that the walls are also set to collide with


# class member variables go here, for example:
# var a = 2
export(int,"Right","Left") var direction = 0
var RIGHT = 0
var LEFT = 1

export var damage = 20
export(String) var grouptarget
export(String) var groupignore


var speed = 250
var gravity = 9.8

var motion = Vector2(0,0)
var deltamotion = Vector2(0,0)
var wallmotion = Vector2(0,0)
var slidmotion = Vector2(0,0)
var normal


func _ready():
	add_to_group("Projectile")
	get_node("Hitbox").connect("body_enter",self,"body_enter_hitbox")
	get_node("Decay").connect("timeout",self,"decay")
	get_node("VisibilityNotifier2D").connect("exit_screen",self,"exit_screen")
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	motion.x = 0
	deltamotion = Vector2(0,0)
	slidmotion = Vector2(0,0)
	if (direction == RIGHT):
		motion.x = speed
	if (direction == LEFT):
		motion.x = -speed
	motion.y += gravity
	#are we colliding?
	if (!is_colliding()):
		#If not, move through the air normally
		deltamotion = motion*delta
		move(deltamotion)
	else:
		#If so, reset gravity and move against the wall!
		motion.y=0
		normal = get_collision_normal()
		#print(str(get_collision_normal()))
		if (direction==RIGHT):
			wallmotion = Vector2(-speed,0).rotated(Vector2(0,1).angle_to(normal))*delta
		else:
			wallmotion = Vector2(speed,0).rotated(Vector2(0,1).angle_to(normal))*delta
		move(wallmotion)
		#unsure if I should keep this in...
		#slidmotion = normal.slide(wallmotion)
		#move(slidmotion)
		#I don't think I should.. Now the speed is uniform on both ground and air without it
		#
	
	pass

func body_enter_hitbox(body):
	#Check body is targetable
	if (grouptarget!=null and body.is_in_group(grouptarget)):
		#Check for the method, just in case
		if (body.has_method("dmg")):
			body.dmg(damage)
			queue_free()
	#If it isn't to be ignored...
	if (groupignore!=null and !body.is_in_group(groupignore)):
		queue_free()
		pass
	pass

func decay():
	queue_free()
	pass


func exit_screen():
	queue_free()
	pass


