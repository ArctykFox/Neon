extends Node2D

onready var gun_shot_sound = $GunShotSound
onready var gun_reload_sound = $GunReloadSound
onready var gun_switch_sound = $GunSwitchSound

export (int) var inventory_capacity = 30	
export (int) var inventory_ammo = self.inventory_capacity
export (int) var bullet_speed = 2000
export (int) var damage = 25
export (int) var rate_of_fire = 600
export (int) var mag_capacity = 15
var mag_ammo = self.mag_capacity
var type = "gun"
var gun_name = "rifle"

var idle_animation = "idle_rifle"
var move_animation = "move_rifle"
var shoot_animation = "shoot_rifle"
var reload_animation = "reload_rifle"


func _ready():
	self.inventory_ammo -= self.mag_capacity


func play_shoot_sound():
	self.gun_shot_sound.play()
	
func play_reload_sound():
	self.gun_reload_sound.play()

func play_switch_sound():
	self.gun_switch_sound.play()
