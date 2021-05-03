extends RigidBody2D
class_name Bullet


export (int) var bullet_speed = 2000
export (int) var damage

var projectile_type = "bullet"


func _on_Bullet_body_entered(body):
	self.queue_free()
	if body.is_in_group("Enemy"):
		body.enemy_handle_hit(self)
	elif body.is_in_group("Player"):
		body.player_handle_hit(self.damage)
		


func _on_Timer_timeout():
	self.queue_free()
