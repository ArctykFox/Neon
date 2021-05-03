extends AnimatedSprite


func _ready():
	self.play("BloodHit_1")
	


func _on_BloodHit_animation_finished():
	self.queue_free()
