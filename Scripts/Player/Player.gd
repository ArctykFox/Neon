extends KinematicBody2D
class_name Player


#member variables
export (int) var max_health = 200
export (int) var speed = 300
export (int) var bullet_casing_exhaust_speed = 50
var health = max_health

onready var rifle = $Rifle
onready var shotgun = $Shotgun
onready var handgun = $Handgun
onready var knife = $Knife
onready var knife_collision_shape = $Knife/CollisionShape2D
onready var end_of_gun = $EndOfGun
onready var muzzle_flash_animation = $EndOfGun/MuzzleFlash/AnimationPlayer
onready var bullet_exhaust = $BulletExhaust
onready var rate_of_fire = get_node("RateOfFire")
onready var animated_sprite = $AnimatedSprite
onready var foot_steps_sound = $FootStepsSound
onready var out_of_ammo_sound = $OutOfAmmoSound
onready var breathing_sound = $BreathingSound
onready var attacked_sound = $AttackedSound
onready var death_sound = $DeathSound

var Bullet = preload("res://Scenes/Bullet/Bullet.tscn")
var BulletCasing = preload("res://Scenes/Bullet/BulletCasing.tscn")
var BloodHit = preload("res://Scenes/Blood/BloodHit.tscn")
var BloodDrop = preload("res://Scenes/Blood/BloodDrop.tscn")

var is_idle = false
var is_moving = false
var is_shooting = false
var is_reloading = false

var current_weapon
const rate_of_fire_const = 60.0


#Signals
#BULLET FIRED SIGNAL
################################################################################
#the bullet fired signal will serve as an event which will
#get called whenever the player shoots a bullet,
#this will then be connected by the scene level main script to the bulletManager
#which will then add the bullet instance as a child of that bulletmanager which
#itself is a child of the level scene
################################################################################


func _ready():
	is_idle = true
	self.current_weapon = self.rifle
	rate_of_fire.set_wait_time(rate_of_fire_const / current_weapon.rate_of_fire)

func _process(_delta):

	if is_shooting:
		animated_sprite.play(self.current_weapon.shoot_animation)

	elif is_reloading:
		animated_sprite.play(self.current_weapon.reload_animation)

	elif is_moving:
		animated_sprite.play(self.current_weapon.move_animation)
		if !self.foot_steps_sound.is_playing():
			self.foot_steps_sound.play()
			self.breathing_sound.stop()

	elif is_idle:
		animated_sprite.play(self.current_weapon.idle_animation)
		if self.foot_steps_sound.is_playing():
			self.foot_steps_sound.stop()
			self.breathing_sound.play()


	#player aim follows the mouse cursor position
	look_at(get_global_mouse_position())


#this is called every physics frame, not every render frame
#this is to keep everything that depends on the physics simulation smooth and const ex: movement
func _physics_process(delta):
	var direction_vector = Vector2()
	#overshadows the variable with the returned vector of the process_input function
	direction_vector =  process_input(direction_vector).normalized()

	if self.current_weapon.type == "melee" && is_shooting:
		if self.animated_sprite.frame == 7:
			self.knife_collision_shape.set_disabled(false)
		else:
			self.knife_collision_shape.set_disabled(true)

	if direction_vector != Vector2.ZERO:
		self.is_idle = false
		self.is_moving = true

	else:
		self.is_moving = false
		self.is_idle = true

	#moves the player and stops him on the event of a collision
	move_and_collide(direction_vector * speed * delta)
	
	
#Functions
#move function
func process_input(direction_vector : Vector2):

	if Input.is_action_pressed("move_left"):
		direction_vector += Vector2(-1, 0)
		
		
	if Input.is_action_pressed("move_right"):
		direction_vector += Vector2(+1, 0)
		
		
	if Input.is_action_pressed("move_up"):
		direction_vector += Vector2(0, -1)
		
		
	if Input.is_action_pressed("move_down"):
		direction_vector += Vector2(0, +1)		
		
	if Input.is_action_just_released("reload"):
		reload()
		
	
	if Input.is_action_pressed("shoot"):
		shoot()
	
	switch_weapon()
		
	return direction_vector


#shoot function
func shoot():
	if !is_reloading:
		if rate_of_fire.is_stopped():
			if self.current_weapon.type == "gun":
				if self.current_weapon.mag_ammo > 0:
					is_shooting = true
					muzzle_flash_animation.play("muzzle_flash_appear")
					var bullet_instance= Bullet.instance()
					var bullet_speed = bullet_instance.bullet_speed
					bullet_instance.position = end_of_gun.get_global_position()
					bullet_instance.rotation_degrees = self.rotation_degrees
					bullet_instance.apply_impulse(Vector2(), Vector2(self.current_weapon.bullet_speed, 0).rotated(self.rotation))
					bullet_instance.damage = self.current_weapon.damage
					var bullet_casing_instance = BulletCasing.instance()
					bullet_casing_instance.position = bullet_exhaust.get_global_position()
					bullet_casing_instance.rotation_degrees = self.rotation_degrees
					bullet_casing_instance.apply_impulse(Vector2(), Vector2(0, self.bullet_casing_exhaust_speed).rotated(self.rotation))
					
					get_tree().get_root().add_child(bullet_instance)
					get_tree().get_root().add_child(bullet_casing_instance)
					current_weapon.mag_ammo -= 1
					self.current_weapon.play_shoot_sound()

				else:
					#set rate of fire to be slow to avoid rapidly repeated out of ammo sound
					rate_of_fire.set_wait_time(0.3)
					self.out_of_ammo_sound.play()

			else:
				is_shooting = true
				self.current_weapon.play_shoot_sound()
				
			rate_of_fire.start()


#reload func
func reload():
	if self.current_weapon.type == "gun":
		if !is_shooting && self.current_weapon.inventory_ammo > 0 && self.current_weapon.mag_ammo != self.current_weapon.mag_capacity:
			is_reloading = true
			rate_of_fire.set_wait_time(rate_of_fire_const / self.current_weapon.rate_of_fire)
			var bullets_shot = (current_weapon.mag_capacity - current_weapon.mag_ammo)
			if current_weapon.inventory_ammo > bullets_shot:
				current_weapon.inventory_ammo -= bullets_shot
				current_weapon.mag_ammo += bullets_shot
			else:
				current_weapon.mag_ammo += current_weapon.inventory_ammo
				current_weapon.inventory_ammo = 0
			self.current_weapon.play_reload_sound()


func _on_AnimatedSprite_animation_finished():
	animated_sprite.stop()
	is_shooting = false
	is_reloading = false
	
	
func player_handle_hit(hitbox, damage):
	var blood_hit_instance = BloodHit.instance()
	blood_hit_instance.position = hitbox.get_global_position()
	get_tree().get_root().add_child(blood_hit_instance)

	var blood_drop_instance = BloodDrop.instance()
	blood_drop_instance.position = hitbox.get_global_position()
	blood_drop_instance.rotation_degrees = self.rotation_degrees
	get_tree().get_root().add_child(blood_drop_instance)

	self.health -= damage
	self.attacked_sound.play()

	if self.health <= 0:
		get_tree().reload_current_scene()
	

func pickup_ammo(ammount):
	if self.current_weapon.type == "gun":
		if self.current_weapon.inventory_ammo < self.current_weapon.inventory_capacity:
			self.current_weapon.inventory_ammo += ammount
			if self.current_weapon.inventory_ammo > self.current_weapon.inventory_capacity:
				current_weapon.inventory_ammo = self.current_weapon.inventory_capacity


func pickup_health(ammount):
	self.health = self.max_health


func switch_weapon():
	if Input.is_action_just_released("weapon_1"):
		if !self.current_weapon == self.rifle:
			self.current_weapon = self.rifle
			rate_of_fire.set_wait_time(rate_of_fire_const / current_weapon.rate_of_fire)
			self.end_of_gun.position = Vector2(28.864, 0.001)
			self.bullet_exhaust.position = Vector2(5.167, 0.805)
			self.current_weapon.play_switch_sound()
	
	if Input.is_action_just_released("weapon_2"):
		if !self.current_weapon == self.handgun:
			self.current_weapon = self.handgun
			rate_of_fire.set_wait_time(rate_of_fire_const / current_weapon.rate_of_fire)
			self.end_of_gun.position = Vector2(19.621, 2.202)
			self.bullet_exhaust.position = Vector2(12.167, 2.805)
			self.current_weapon.play_switch_sound()

	if Input.is_action_just_released("weapon_3"):
		if !self.current_weapon == self.shotgun:
			self.current_weapon = self.shotgun
			rate_of_fire.set_wait_time(rate_of_fire_const / current_weapon.rate_of_fire)
			self.end_of_gun.position = Vector2(28.864, 0.001)
			self.bullet_exhaust.position = Vector2(5.167, 0.805)
			self.current_weapon.play_switch_sound()

	if Input.is_action_just_released("weapon_4"):
		if !self.current_weapon == self.knife:
			self.current_weapon = self.knife
			rate_of_fire.set_wait_time(rate_of_fire_const / current_weapon.rate_of_fire)
			self.current_weapon.play_switch_sound()

