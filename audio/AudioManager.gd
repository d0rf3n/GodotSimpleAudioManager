extends Node

# number of audio channels (maximum simultaneous audio streams)
var channelCount = 16 # set (could be user configurable, ex. low[8]/medium[16]/high[32])

# pool of AudioStreamPlayer nodes
var _available_stream_players = []

# names of all audio files
var _effect_filenames = []
var _music_filenames = []

# loaded AudioStream resources with audio sample names as keys (file names without extension)
var _loaded_effect_streams = {}
var _loaded_music_streams = {}


func _ready() -> void:
	# Set audio bus layout
	AudioServer.set_bus_layout(load("res://audio/bus_layout.tres"))
	
	# Create the pool of AudioStreamPlayer nodes
	for i in channelCount:
		var stream_player = AudioStreamPlayer.new()
		add_child(stream_player)
		_available_stream_players.append(stream_player)
		stream_player.connect("finished", self, "_on_stream_finished", [stream_player])
	
	# Generates audio_filenames from files in music and effects directories
	_effect_filenames = _get_filenames("audio/effects")
	_music_filenames = _get_filenames("audio/music")


# Gives a list of all audio files (.wav/.ogg) in a folder
func _get_filenames(path):
	var files = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true) # skip_navigational=false (.., .), skip_hidden=false
		var filename = dir.get_next()
		while filename != "":
			if dir.current_is_dir():
				push_error("No directories in audio folder.")
			elif filename.ends_with(".wav") or filename.ends_with(".ogg"):
				files.append(filename)
			filename = dir.get_next()
		return files
	else:
		push_error("An error occurred when trying to access '" + path + "'.")


# Loads an array of effect audio resources from an array of audio_names
# 	containing file names without extensions (ex: [laser1, jump])
func load_effects(audio_names):
	_loaded_effect_streams = _load_from_files("effects", audio_names)


# Loads an array of music audio resources from an array of audio_names
# 	containing file names without extensions (ex: [bgm1, prelude])
func load_music(audio_names):
	_loaded_music_streams = _load_from_files("music", audio_names)


# Loads every music and effect audio sample
#	(same as calling load_all_effects() and load_all_music())
func load_all():
	load_all_effects()
	load_all_music()


# Loads every effect audio sample
func load_all_effects():
	load_effects(_remove_extensions(_effect_filenames))


# Loads every music audio sample
func load_all_music():
	load_music(_remove_extensions(_music_filenames))


# Deloads (removes references for GC) all loaded sample resources (streams)
func deload_all():
	deload_effects()
	deload_music()


# Deloads (removes references for GC) all effect streams
func deload_effects():
	_loaded_effect_streams = {}


# Deloads (removes references for GC) all music streams
func deload_music():
	_loaded_music_streams = {}


# Converts filenames into audio_names (removes file extensions from an array of filenames)
func _remove_extensions(filenames):
	var basenames = []
	for filename in filenames:
		basenames.append(filename.get_basename())
	return basenames


# Gives an array audiostreams of loaded resources
#	type is same as folder names
func _load_from_files(type, audio_names):
	var loaded = {}
	for audio_name in audio_names:
		var file = _get_filename(type, audio_name)
		loaded[audio_name] = load("res://audio/" + type + "/" + file)
	return loaded


# Gives the full filename from a audio_name (file name without extension)
func _get_filename(type, audio_name):
	var files = []
	match type:
		"music":
			files = _music_filenames
		"effects":
			files = _effect_filenames
	if files.size() == 0:
		push_error("No files in folder " + type)
	for file in files:
		if file.begins_with(audio_name):
			return file
	push_error("No file in folder audio/" + type + " corresponding to audio with name: " + audio_name)


# Play a sound effect using its audio_name (file name without extension)
func play_effect(audio_name):
	_play("effect", audio_name)


# Play music using its audio_name (file name without extension)
func play_music(audio_name):
	_play("music", audio_name)


func _play(type, audio_name):
	var stream_player = _available_stream_players.pop_front()
	if stream_player == null: # if no available players don't play anything
		return
	var stream
	match type:
		"music":
			stream_player.bus = "Music"
			if _loaded_music_streams.has(audio_name):
				stream = _loaded_music_streams[audio_name]
		"effect":
			stream_player.bus = "Effects"
			if _loaded_effect_streams.has(audio_name):
				stream = _loaded_effect_streams[audio_name]
	if stream == null:
		push_error("No audio stream resource loaded with name: " + audio_name
				+ ". Please look over your load_" + type + " call.")
	stream_player.stream = stream
	stream_player.play()


# Put AudioStreamPlayer node back in the available pool when done playing
func _on_stream_finished(stream_player):
	_available_stream_players.append(stream_player) 
