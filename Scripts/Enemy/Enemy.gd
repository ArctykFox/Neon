extends KinematicBody2D


export (int) var health = 100
export (int) var speed = 300
export (int) var damage = 20
onready var animated_sprite = $AnimatedSprite
onready var attacked_sound = $AttackedSound
onready var attack_sound = $AttackSound
onready var dead_sound = $DeathSound
onready var hitbox = $HitArea/Hitbox
onready var healthbar = $Healthbar
onready var idle_sound = $IdleSound
onready var move_sound = $MoveSound
onready var collision_shape = $CollisionShape2D
onready var attack_area = $AttackArea/CollisionShape2D
var BloodSplash = preload("res://Scenes/Blood/BloodSplash.tscn")
var BloodHit = preload("res://Scenes/Blood/BloodHit.tscn")
var BloodDrop = preload("res://Scenes/Blood/BloodDrop.tscn")
var is_idle = false
var is_moving = false
var is_attacking = false
var can_attack = true
var has_rotated = false
var idle_animation = "idle"
var move_animation = "move"
var attack_animation = "attack"
var player: Player = null
var player_position = Vector2.ZERO
var path
var can_see = false
var starting_position


func _ready():
	starting_position = self.get_global_position()
	self.is_idle = true
	self.healthbar.max_value = self.health
	

func _process(_delta):
	if is_idle:
		self.animated_sprite.play(self.idle_animation)
		if !self.idle_sound.is_playing():
			self.move_sound.stop()
			self.idle_sound.play()

	elif is_attacking:
		self.animated_sprite.play(self.attack_animation)

	elif is_moving:
		self.animated_sprite.play(self.move_animation)
		if !self.move_sound.is_playing():
			self.idle_sound.stop()
			self.move_sound.play()

	self.healthbar.value = self.health


func _physics_process(delta):
	if player != null:
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(self.position, player.position, [self])
		if result:
			if result.collider.name == "Player":
				can_see = true
				self.is_idle = false
				self.is_moving = true

			else:
				self.is_idle = true
				self.is_moving = false
				can_see = false


	if can_attack:
		if self.is_moving || self.is_attacking:
			player_position = Vector2.ZERO
	
			if self.player != null:
				move_along_path(self.path, delta)
			
		if self.is_attacking:
			if self.animated_sprite.frame == 7:
				self.hitbox.set_disabled(false)
			else:
				self.hitbox.set_disabled(true)


func enemy_handle_hit(projectile):
	self.can_attack = false
	var blood_hit_instance = BloodHit.instance()
	blood_hit_instance.position = projectile.get_global_position()
	get_tree().get_root().add_child(blood_hit_instance)

	self.health -= projectile.damage

	var blood_drop_instance = BloodDrop.instance()
	blood_drop_instance.position = projectile.get_global_position()
	blood_drop_instance.rotation_degrees = self.rotation_degrees
	get_tree().get_root().add_child(blood_drop_instance)
	self.can_attack = true

	if self.health <= 0:
		hitbox.set_disabled(true)
		self.can_attack = false
		self.set_collision_layer_bit(0, false)
		self.set_collision_mask_bit(0, false)
		var blood_splash_instance = BloodSplash.instance()
		blood_splash_instance.position = self.get_global_position()
		blood_splash_instance.rotation_degrees = self.rotation_degrees
		get_tree().get_root().add_child(blood_splash_instance)
		idle_sound.stop()
		dead_sound.play()
		self.hide()
	else:
		idle_sound.stop()
		attacked_sound.play()


func move_along_path(path, delta):
	if path != null:
		for i in path:
			player_position = position.direction_to(i) * self.speed * delta
			player_position = player_position.normalized()
			move_and_collide(self.player_position)
			look_at(player.position)
			#self.rotation = lerp(self.rotation, player_position.angle(), 0.1)


func get_new_path(new_path):
	self.path = new_path


func _on_DetectionArea_body_entered(body):
	if body.is_in_group("Player"):
		self.is_idle = false
		self.is_moving = true
		player = body


func _on_DetectionArea_body_exited(body):
	if body.is_in_group("Player"):
		self.is_idle = true
		self.is_moving = false
		player = null


func _on_AttackArea_body_entered(body):
	if body.is_in_group("Player"):
		is_attacking = true


func _on_AttackArea_body_exited(body):
	if body.is_in_group("Player"):
		is_attacking = false


func _on_HitArea_body_entered(body):
	if body.is_in_group("Player"):
		self.attack_sound.play()
		body.player_handle_hit(hitbox, self.damage)


func _on_DeathSound_finished():
	self.queue_free()
