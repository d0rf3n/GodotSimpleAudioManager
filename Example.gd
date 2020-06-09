extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set channelCount
	AudioManager.channelCount = 8
	# Load audio samples
	var effects = [
		"blip",
		"confirmation",
		"laser"
	]
	AudioManager.load_effects(effects)
	AudioManager.load_music(["bgm"])
	# OR
#	AudioManager.load_all_effects()
#	AudioManager.load_all_music()
	# OR
#	AudioManager.load_all()


func _on_Blip_pressed() -> void:
	AudioManager.play_effect("blip")


func _on_Laser_pressed() -> void:
	AudioManager.play_effect("laser")


func _on_Confirmation_pressed() -> void:
	AudioManager.play_effect("confirmation")


func _on_BGM_pressed() -> void:
	AudioManager.play_music("bgm")
