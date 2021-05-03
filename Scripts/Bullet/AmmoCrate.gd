extends Area2D

export (int) var ammo_ammount = 50
onready var pickup_sound = $PickUpSound


func _on_AmmoCrate_body_entered(body):
	if body.is_in_group("Player"):
		if body.current_weapon.type == "gun" && body.current_weapon.inventory_ammo < body.current_weapon.inventory_capacity :
			self.hide()
			pickup_sound.play()
			body.pickup_ammo(self.ammo_ammount)
		

func _on_PickUpSound_finished():
	self.queue_free()
