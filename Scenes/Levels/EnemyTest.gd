extends KinematicBody2D

var path
var speed = 1000

		

func _physics_process(delta):
	for i in path:
		var direction_vector = position.direction_to(i) * self.speed * delta
		move_and_collide(direction_vector)
