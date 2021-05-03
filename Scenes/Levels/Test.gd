extends Node2D

onready var nav_2d = $Navigation2D
onready var player = $Player
var enemies

func _ready():
	enemies = get_tree().get_nodes_in_group("Enemy")

func _physics_process(delta):
	if player != null:
		for enemy in enemies:
			if enemies != null:
				enemy.path = nav_2d.get_simple_path(enemy.global_position, player.global_position)
