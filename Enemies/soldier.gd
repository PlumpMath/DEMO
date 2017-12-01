extends KinematicBody2D

#Oh bugger it, i',m sure nobody will notice the bugs (unless you read the source)
#It's a feature!

#Pain below, plus innocent comments before I realised it was f---ed

#DISREGARD THE BELOW: IT WORKS NOW... AFTER AGES OF PAIN AND ENGINE BUGS....

#yeah, it still gets stuck after 1.5 secs (3 shots)

#ITS THE GRAV CALCULATION THAT F---S IT UP
#SIGH... So that's why all these physics glitches are happening
#Total rework needed...


#it sometimes gets stuck... when you hit the tip of the raycast...
#entering, leaving and letting it catch up with you does it
#I think that's it fixed now... GOOD RIDDANCE


#DON'T USE THIS: I had to make enemies much simpler due to stupid engine glitches


#I HAD TO DO THIS THE NOOB WAY BECAUSE:
#THE CURRENT VERSION OF GODOT HAS TROUBLE GETTING THE COLLISION NORMALS AT 90 DEGREES!!!
#REEEEEEEEEEEEEEEEE

#They fixed the bumping along tile seams glitch but is seems we're not out of the woods yet...
#bloody regressions... I HATE EM'

#When trying to detect the player with raycast2d, it messes up and the wall checking areas call their connected functions
#Or maybe the raycasts call the functions? It's stupid anyway...
#Godot always throws engine glitches when making a game. always

#I'm going to have to make this enemy much simpler now..



const RIGHT = 0
const LEFT = 1
export(int,"Right","Left") var direction = 0
export var speed = 100
var gravity = 9.8
const turndegree = 20
var collider
export var hp = 20
export(String,FILE) var bullet = "res://Projectiles/turret_pistol.tscn"



var motion = Vector2(0,0)
var movedmotion
var slidemotion
var cnormal
var collidingwithwall
var moving = true
var shooting = false

var loadedbullet

func _ready():
	loadedbullet = load(bullet)
	add_to_group("Enemy")
	get_node("RWallCheck").connect("body_enter",self,"hit_right_wall")
	get_node("LWallCheck").connect("body_enter",self,"hit_left_wall")
	get_node("ShotTimer").connect("timeout",self,"shoot")
	get_node("ShotTimer").set_active(false)
	get_node("AnimationPlayer").connect("finished",self,"animation_finished")
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	#Checks if the player can be seen... Pain...
	moving=true
	if (get_node("RRaycast").is_colliding() and direction==RIGHT):
		collider = get_node("RRaycast").get_collider()
		if (collider != null and collider.is_in_group("Player")):
			moving=false
			#print("playerColliding")
		else:
			moving=true
	elif (!get_node("RRaycast").is_colliding() and direction==RIGHT):
		moving=true
	
	
	if (get_node("LRaycast").is_colliding() and direction==LEFT):
		collider = get_node("LRaycast").get_collider()
		if (collider != null and collider.is_in_group("Player")):
			moving=false
			#print("playerColliding")
		else:
			moving=true
	elif (!get_node("LRaycast").is_colliding() and direction==LEFT):
		moving=true
	
	#sets up the shooting variable
	#not really for most situations, but avoids any possible wierdness 
	#from setting moving to true by default before any checks....
	#USE SHOOTING FOR ALL INSTANCES OF CHECKING IF THE ENEMY IS SHOOTING
	if (!moving):
		shooting=true
	else:
		shooting=false
	
	if (shooting and !get_node("ShotTimer").is_active()):
		get_node("ShotTimer").set_active(true)
		get_node("ShotTimer").start()
	elif (!shooting and get_node("ShotTimer").is_active()):
		get_node("ShotTimer").stop()
		get_node("ShotTimer").set_active(false)
	
	#Motion calculations
	motion.x=0
	if (!is_colliding()):
		motion.y+=gravity
	if (direction==RIGHT):
		motion.x = 1
		pass
	if (direction==LEFT):
		motion.x = -1
		pass
	if (moving):
		if (!get_node("AnimationPlayer").is_playing()):
			get_node("AnimationPlayer").play("Walk")
		movedmotion = motion*speed*delta
		move(movedmotion)
	if (is_colliding()):
		cnormal=get_collision_normal()
		if (moving):
			slidemotion=cnormal.slide(movedmotion)
			move(slidemotion)
		if (cnormal==Vector2(0,-1)):
			motion.y=0
	if (direction==LEFT):
		get_node("Legs").set_flip_h(true)
		get_node("Torso").set_flip_h(true)
		get_node("Arm").set_rotd(-90)
	if (direction==RIGHT):
		get_node("Legs").set_flip_h(false)
		get_node("Torso").set_flip_h(false)
		get_node("Arm").set_rotd(90)
	pass

func animation_finished():
	if (moving):
		get_node("AnimationPlayer").play("Walk")
		pass


func hit_right_wall(wall):
	if (moving and !wall.is_in_group("Projectile")):
		direction=LEFT

func hit_left_wall(wall):
	if (moving and !wall.is_in_group("Projectile")):
		direction=RIGHT

func shoot():
	var bulleti = loadedbullet.instance()
	bulleti.set_global_pos(get_node("Arm/ShotPos").get_global_pos())
	bulleti.set_global_rot(get_node("Arm/ShotPos").get_global_rot())
	get_parent().add_child(bulleti)
	pass

func dmg(dmg):
	hp-=dmg
	if (hp<1):
		die()

func die():
	queue_free()

