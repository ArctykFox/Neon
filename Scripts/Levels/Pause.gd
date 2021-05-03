extends Control


func _input(event):
	if event.is_action_pressed("pause"):
		self.toggle_pause_game()
		
		
func toggle_pause_game():
	if !get_tree().paused:
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true
			self.visible = get_tree().paused
	else:
		get_tree().paused = false
		#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		self.visible = get_tree().paused


func _on_Resume_pressed():
	self.toggle_pause_game()


func _on_QuitToMainMenu_pressed():
	self.toggle_pause_game()
	get_tree().change_scene("res://Scenes/UI/TitleScreen.tscn")


func _on_QuitGame_pressed():
	get_tree().quit()
