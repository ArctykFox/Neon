extends Node2D

onready var heli_sound = $HeliSoundArea/HeliSound
onready var noise_1_sound = $Noise_1_area/Noise_1_sound

func _on_HelicopterSoundArea_body_entered(body):
	if body.is_in_group("Player"):
		if !self.heli_sound.is_playing():
			self.heli_sound.play()

func _on_Noise1_body_entered(body):
	if body.is_in_group("Player"):
		if !self.noise_1_sound.is_playing():
			self.noise_1_sound.play()
