extends KinematicBody2D



# class member variables go here, for example:
# var a = 2
export(int,"Right","Left") var direction = 0
var RIGHT = 0
var LEFT = 1

var speed = 200
var gravity = 9.8
var damage = 15

#IF SHOOTING UP, ONLY USE speed NOT speed*2

var motion = Vector2(0,0)
var deltamotion = Vector2(0,0)
var wallmotion = Vector2(0,0)
var slidmotion = Vector2(0,0)
var normal

var collider
var cnormal
var moving = true



func _ready():
	add_to_group("Projectile")
	get_node("Decay").connect("timeout",self,"decay")
	get_node("VisibilityNotifier2D").connect("exit_screen",self,"exit_screen")
	get_node("Hitbox").connect("body_enter",self,"body_enter_hitbox")
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	if (moving):
		motion.x = 0
		deltamotion = Vector2(0,0)
		slidmotion = Vector2(0,0)
		if (direction == RIGHT):
			motion.x = speed
		if (direction == LEFT):
			motion.x = -speed
		motion.y += gravity
		deltamotion = motion*delta
		move(deltamotion)
	#If you are colliding with the floor...
	if (is_colliding()):
		collider = get_collider()
		cnormal = get_collision_normal()
		if (cnormal == Vector2(0,-1) and !collider.is_in_group("Projectile")):
			motion.y = 0
			moving = false
		if (moving):
			slidmotion = cnormal.slide(deltamotion)
			move(slidmotion)
	
	
	
	
	
	pass

func body_enter_hitbox(body):
	#DAMAGE CODE!!!
	#MAKE IT ABLE TO DAMAGE PLAYER ;)
	if (body.has_method("dmg")):
		body.dmg(damage)
		queue_free()
	#Melts ice!
	if (body.is_in_group("Ice")):
		body.queue_free()
		queue_free()
	pass


func exit_screen():
	queue_free()

func decay():
	queue_free()

