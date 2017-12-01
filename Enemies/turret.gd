extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export var hp = 10
export(String,FILE) var bullet = "res://Projectiles/turret_pistol.tscn"
var loadedbullet


var collider


func _ready():
	loadedbullet = load(bullet)
	add_to_group("Enemy")
	get_node("ShotTimer").connect("timeout",self,"shoot")
	get_node("ShotTimer").set_active(false)
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	look_at(get_node("../Player").get_pos())
	if (get_node("RayCast2D").is_colliding()):
		collider = get_node("RayCast2D").get_collider()
		if (collider!=null and collider.is_in_group("Player")):
			if (!get_node("ShotTimer").is_active()):
				get_node("ShotTimer").start()
				get_node("ShotTimer").set_active(true)
				pass
		else:
			if (get_node("ShotTimer").is_active()):
				get_node("ShotTimer").stop()
				get_node("ShotTimer").set_active(false)
				pass

func shoot():
	var bulleti = loadedbullet.instance()
	bulleti.set_global_pos(get_node("ShotPos").get_global_pos())
	bulleti.set_global_rot(get_global_rot())
	get_parent().add_child(bulleti)
	get_node("AnimationPlayer").play("Shoot")
	pass



func dmg(dmg):
	hp-=dmg
	if (hp<1):
		die()

func die():
	queue_free()

