extends Control

var current_image_index = 0
var images = [
	"res://Background/uMhbnzr (2).png",
]

func _ready():
	display_current_image()

func display_current_image():
	if current_image_index < images.size():
		var image_texture = load(images[current_image_index])
		$ImageTexture.texture = image_texture
	else:
		# Display the last image or perform any other action before transitioning to the game scene
		pass

func _on_ImageTexture_pressed():
	current_image_index += 1
	display_current_image()

func _on_play_pressed():
	# Load the next scene
	get_tree().change_scene_to_file("res://node_2d.tscn")

func _on_quit_pressed():
	# Quit the game
	get_tree().quit()

func _on_bit_cpmc_finished():
	var audio_player = $AudioStreamPlayer2D
	if audio_player:
		audio_player.play()
	else:
		print("AudioStreamPlayer2D node not found")
