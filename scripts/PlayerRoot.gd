extends Node2D

var speed = 150
var verticalMovement=0
const MAX_VERTICAL_MOVEMENT = 200
var rocketObj = null
const RATE_OF_FIRE =3.0
var dying = false

onready var shotCoolDown = $Timer
onready var explode = preload("res://Explosion/Explosion.tscn").instance()

func _ready():
	rocketObj = load("res://Rocket/Rocket.tscn")
	shotCoolDown.wait_time = 1.0/RATE_OF_FIRE
	shotCoolDown.one_shot = true

func _process(delta):
	move_local_x(speed*delta)
	if (self.position.y > 1 && self.position.y <= get_viewport_rect().size.y):
		move_local_y(verticalMovement*delta)
	else:
		if(self.position.y < 1):
			move_local_y(10) #Bounce off top
			verticalMovement = 0
		if(self.position.y > get_viewport_rect().size.y):
			move_local_y(-10) #Bounce off bottom
			verticalMovement = 0
	if(dying ==true):
		if(shotCoolDown.time_left == 0):
			get_node("/root/GameSceneRoot").PlayerDied()
			queue_free()
			print ("DEAD")
			
func stop ():
	speed = 0
	
func explode():
	if (!explode == null):
		explode.set_position(self.get_position())
		get_parent().add_child(explode)
		globals.kills = globals.kills + 1
		shotCoolDown.wait_time = 2.5
		shotCoolDown.start()
		$PlayerSprite.visible = false
		dying = true
		
func dead():
	get_node("/root/GameSceneRoot").PlayerDied()
			
func _input(event):
	if(event.is_action("Player_up")):
		if(verticalMovement >= -MAX_VERTICAL_MOVEMENT):
			verticalMovement-=30
	if(event.is_action("Payer_down")):
		if(verticalMovement <= MAX_VERTICAL_MOVEMENT):
			verticalMovement+=30
	if(event.is_action("Player_shoot")):
		if(shotCoolDown.time_left == 0):
			var rocket = rocketObj.instance()
			rocket.position = self.get_position()
			rocket.position.y = rocket.position.y + 20
			get_node("/root/GameSceneRoot").add_child(rocket)
			shotCoolDown.start()
			
func _on_Area2D_area_entered(area):
	#Layer2 is another enemy
	if(area.get_collision_layer_bit(2)):
		explode()
	