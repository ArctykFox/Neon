extends Area2D

export (int) var health_ammount = 50
onready var pickup_sound = $PickUpSound
onready var animation_player = $AnimationPlayer

func _process(_delta):
	if !animation_player.is_playing():
		animation_player.play("heart_pulse")


func _on_HealthCrate_body_entered(body):
	if body.is_in_group("Player"):
		if body.health < body.max_health:
			self.hide()
			pickup_sound.play()
			body.pickup_health(self.health_ammount)
		

func _on_PickUpSound_finished():
	self.queue_free()
