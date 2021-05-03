extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_PlayButton_pressed():
	get_tree().change_scene("res://Scenes/Levels/Level1/Level1.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()
