extends Node2D


onready var gun_shot_sound = $GunShotSound
onready var gun_switch_sound = $GunSwitchSound
onready var gun_stab_sound = $GunStabSound

export (int) var damage = 25
export (int) var rate_of_fire = 100

var idle_animation = "idle_knife"
var move_animation = "move_knife"
var shoot_animation = "shoot_knife"
var reload_animation = "reload_knife"

var type = "melee"
var gun_name = "knife"

func play_shoot_sound():
	self.gun_shot_sound.play()

	
func play_reload_sound():
	pass


func play_switch_sound():
	self.gun_switch_sound.play()

func _on_Knife_body_entered(body):
	if body.is_in_group("Enemy"):
		self.gun_stab_sound.play()
		body.enemy_handle_hit(self)
