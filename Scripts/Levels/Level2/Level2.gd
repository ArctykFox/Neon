extends Node2D

onready var ammo_label = $UI/MagAmmoLabel
onready var player_healthbar = $UI/PlayerHealthbar
onready var ammo_inventory_label = $UI/AmmoInventory
onready var rifle_sprite = $UI/Rifle
onready var handgun_sprite = $UI/Handgun
onready var shotgun_sprite = $UI/Shotgun
onready var knife_sprite = $UI/Knife
onready var nav_2d = $Level2_Map/Navigation2D
onready var player = $Player
var enemies


func _ready():
	enemies = get_tree().get_nodes_in_group("Enemy")
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if self.player != null:
		self.player_healthbar.max_value = self.player.health


func _process(_delta):

	if self.player != null:
		self.player_healthbar.value = self.player.health
		if self.player.current_weapon.type == "gun":
			self.ammo_inventory_label.set_text(str(self.player.current_weapon.mag_ammo) + "/" + str(self.player.current_weapon.inventory_ammo))
		
		if self.player.current_weapon.gun_name == "rifle":
			handgun_sprite.visible = false
			knife_sprite.visible = false
			shotgun_sprite.visible = false
			rifle_sprite.visible = true
			

		if self.player.current_weapon.gun_name == "handgun":
			rifle_sprite.visible = false
			knife_sprite.visible = false
			shotgun_sprite.visible = false
			handgun_sprite.visible = true

		if self.player.current_weapon.gun_name == "shotgun":
			rifle_sprite.visible = false
			knife_sprite.visible = false
			handgun_sprite.visible = false
			shotgun_sprite.visible = true


		if self.player.current_weapon.gun_name == "knife":
			rifle_sprite.visible = false
			handgun_sprite.visible = false
			shotgun_sprite.visible = false
			knife_sprite.visible = true

	else:
		self.player_healthbar.value = 0


func _physics_process(delta):
	if player && enemies != null:
		for enemy in enemies:
			if enemy != null:
				if enemy.can_see:
					enemy.get_new_path(nav_2d.get_simple_path(enemy.global_position, player.global_position, false))
