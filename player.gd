extends KinematicBody2D

# class member variables go here, for example:
# var a = 2

var sawblade = preload("res://Projectiles/sawblade.tscn")
var pistolbullet = preload("res://Projectiles/pistol.tscn")
var flame = preload("res://Projectiles/flame.tscn")

#movement variables
var airjumps = 0

#movement engine stuff
#DO NOT CHANGE
var RIGHT = 0
var LEFT = 1

var ajumpsleft

#controls n shit
var holdingjump = false
var holdingleft = false
var holdingright = false

#weapon data

var pistol = preload("res://Weapon/pistol.tscn")
var nailgun = preload("res://Weapon/nailgun.tscn")
var flamethrower = preload("res://Weapon/flamethrower.tscn")
var blade = preload("res://Weapon/blade.tscn")

var weapon = [
{"name":"pistol", "node":pistol, "obtained":true},
{"name":"nailgun", "node":nailgun, "obtained":false},
{"name":"flamethrower", "node":flamethrower, "obtained":false},
{"name":"blade", "node":blade, "obtained":false}
]

var wepselected = 0
var weaponi

#player variables
var hp = 100
export var invincible = false
export var frozen = false
#(should not be exported but a companion to above)
#ensures that you don't jump when leaving dialogue
var prevfrozen = false
var weaponswitchdisabled = false
export(int,"Right","Left") var direction = 0



# Member variables
const GRAVITY = 500.0 # Pixels/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 46
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 100
const STOP_FORCE = 1300
const JUMP_SPEED = 200
const JUMP_MAX_AIRBORNE_TIME = 0.1

const SLIDE_STOP_VELOCITY = 1.0 # One pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # One pixel

var velocity = Vector2()
var on_air_time = 100
var jumping = false

var prev_jump_pressed = false

func _ready():
	if (Globals.get("HP")!=null):
		hp = Globals.get("HP")
	else:
		hp = 100
	GAME.update_hp(hp)
	GAME.show_hp(true)
	var n = 0
	if (Globals.get("Weapons")!=null and !Globals.get("Weapons").empty()):
		for i in weapon:
			i["obtained"]=Globals.get("Weapons")[n]
			n+=1
	else:
		Globals.set("Weapons",[])
		for i in Globals.get("Weapons"):
			i.push_back(weapon[n]["obtained"])
			n+=1
	
	if (Globals.get("SelectedWeapon")!=null):
		wepselected = Globals.get("SelectedWeapon")
		set_weapon()
	
	if (Globals.get("Direction")!=null):
		direction = Globals.get("Direction")
	add_to_group("Player")
	set_process_input(true)
	set_fixed_process(true)
	get_node("AnimationPlayer").connect("finished",self,"animation_finished")
	pass

func _fixed_process(delta):
	#(This is mostly stolen from the kinematic_char godot demo lol.)
	#(Big ups to juan or ariel or whoever else wrote this!)
	#ps, cool trivia... in early versions the platformer (not the one this was stolen from) demo, 
	#there was commented out code from running nose. It was for facebook integration.
	#Godot: the game engine from the ghetto!
	#(But in all seriousness, I love this engine with all my heart and would like to thank everyone who contributed)
	#This engine p much saved my butt and really got me started w/ game making.
	
	# Create forces
	var force = Vector2(0, GRAVITY)
	
	var walk_left = Input.is_action_pressed("ui_left")
	var walk_right = Input.is_action_pressed("ui_right")
	var jump = Input.is_action_pressed("jump")
	
	var stop = true
	
	if (walk_left and !frozen):
		if (velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED):
			force.x -= WALK_FORCE
			stop = false
			direction = 1
	elif (walk_right and !frozen):
		if (velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED):
			force.x += WALK_FORCE
			stop = false
			direction = 0
	
	if (stop):
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		vlen -= STOP_FORCE*delta
		if (vlen < 0):
			vlen = 0
		
		velocity.x = vlen*vsign
	
	# Integrate forces to velocity
	velocity += force*delta
	
	# Integrate velocity into motion and move
	var motion = velocity*delta
	
	# Move and consume motion
	motion = move(motion)
	
	var floor_velocity = Vector2()
	
	if (is_colliding()):
		# You can check which tile was collision against with this
		# print(get_collider_metadata())
		
		# Ran against something, is it the floor? Get normal
		var n = get_collision_normal()
		
		if (rad2deg(acos(n.dot(Vector2(0, -1)))) < FLOOR_ANGLE_TOLERANCE):
			# If angle to the "up" vectors is < angle tolerance
			# char is on floor
			on_air_time = 0
			floor_velocity = get_collider_velocity()
		
		if (on_air_time == 0 and force.x == 0 and get_travel().length() < SLIDE_STOP_MIN_TRAVEL and abs(velocity.x) < SLIDE_STOP_VELOCITY and get_collider_velocity() == Vector2()):
			# Since this formula will always slide the character around, 
			# a special case must be considered to to stop it from moving 
			# if standing on an inclined floor. Conditions are:
			# 1) Standing on floor (on_air_time == 0)
			# 2) Did not move more than one pixel (get_travel().length() < SLIDE_STOP_MIN_TRAVEL)
			# 3) Not moving horizontally (abs(velocity.x) < SLIDE_STOP_VELOCITY)
			# 4) Collider is not moving
			
			revert_motion()
			velocity.y = 0.0
		else:
			# For every other case of motion, our motion was interrupted.
			# Try to complete the motion by "sliding" by the normal
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			# Then move again
			move(motion)
	
	if (floor_velocity != Vector2()):
		# If floor moves, move with floor
		move(floor_velocity*delta)
	
	if (jumping and velocity.y > 0):
		# If falling, no longer jumping
		jumping = false
	
	if (on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping and !frozen and !prevfrozen):
		# Jump must also be allowed to happen if the character left the floor a little bit ago.
		# Makes controls more snappy.
		get_node("SE").play("Jump")
		velocity.y = -JUMP_SPEED
		jumping = true
	
	
	#Variable jump height shit... (BY ME, ELF_EARS!!!!!!)
	
	if (jumping and not jump):
		if (velocity.y < -JUMP_SPEED/10):
			velocity.y = -JUMP_SPEED/10
		else:
			velocity.y = 0
		jumping = false
	
	on_air_time += delta
	prev_jump_pressed = jump
	
	#ensures you don't jump when leaving dialogue
	if (!Input.is_action_pressed("jump") and !frozen and prevfrozen):
		prevfrozen=false
	
	if (direction==0):
		get_node("Legs").set_flip_h(false)
		get_node("Torso").set_flip_h(false)
		get_node("Arm").set_scale(Vector2(1,1))
	if (direction==1):
		get_node("Legs").set_flip_h(true)
		get_node("Torso").set_flip_h(true)
		get_node("Arm").set_scale(Vector2(1,-1))
	
	if (Input.is_action_pressed("ui_up")):
		if (direction==0):
			get_node("Arm").set_rotd(180)
		else:
			get_node("Arm").set_rotd(0)
	else:
		get_node("Arm").set_rotd(90)
	
	#walks if on ground
	if ((Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")) and !get_node("AnimationPlayer").is_playing() and on_air_time < JUMP_MAX_AIRBORNE_TIME):
		get_node("AnimationPlayer").play("Walk")
	
	#if in air, jumping pose, if not, set pose to ground pose
	if (on_air_time > JUMP_MAX_AIRBORNE_TIME):
		get_node("AnimationPlayer").stop()
		get_node("Legs").set_region_rect(Rect2(64,32,32,16))
	elif (!get_node("AnimationPlayer").is_playing()):
		get_node("Legs").set_region_rect(Rect2(0,32,32,16))
	

func _input(event):
	if (Input.is_action_pressed("nweapon") and !event.is_echo() and !frozen):
		wepselected+=1
		if (wepselected>weapon.size()-1):
				wepselected=0
		while (!weapon[wepselected]["obtained"]):
			wepselected+=1
			if (wepselected>weapon.size()-1):
				wepselected=0
		if (wepselected>weapon.size()-1):
			wepselected=0
		set_weapon()
		pass
	
	if (Input.is_action_pressed("pweapon") and !event.is_echo() and !frozen):
		wepselected-=1
		if (wepselected<0):
			wepselected=weapon.size()-1
		while (!weapon[wepselected]["obtained"]):
			wepselected-=1
			if (wepselected<0):
				wepselected=weapon.size()-1
		if (wepselected<0):
			wepselected=weapon.size()-1
		set_weapon()
		pass
	
	pass

func animation_finished():
	#if the player is still walking, loop the animation
	#I don't use the animation loop flag in this case aas it offers me more control and looks nicer in this instance
	#(I would have to either pause or stop the animation, thus it looking a bit ugly)
	if ((Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")) and on_air_time < JUMP_MAX_AIRBORNE_TIME):
		get_node("AnimationPlayer").play("Walk")

func set_weapon():
	Globals.set("SelectedWeapon",wepselected)
	for i in get_node("Arm").get_children():
		if (i.get_name()!="WeaponPosition"):
			i.queue_free()
	if (weaponi!=null):
		weaponi.queue_free()
	weaponi = weapon[wepselected]["node"].instance()
	weaponi.set_pos(get_node("Arm/WeaponPosition").get_pos())
	get_node("Arm").add_child(weaponi)


func freeze():
	frozen=true
	pass

func unfreeze():
	prevfrozen=true
	frozen=false
	pass

func dmg(dmg):
	get_node("SE").play("Hurt")
	hp-=dmg
	Globals.set("HP",hp)
	GAME.update_hp(hp)
	if (hp<1):
		die()

func die():
	GAME.game_over()


