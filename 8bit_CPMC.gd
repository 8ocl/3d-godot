extends AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the 'finished' signal to the '_on_audio_finished' method
	connect("finished", self, "_on_audio_finished")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Function to handle the 'finished' signal
func _on_audio_finished():
	# Restart the audio stream from the beginning
	play()
