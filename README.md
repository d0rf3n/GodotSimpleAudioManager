# GodotSimpleAudioManager
A simple node audiomanager for the godot game engine (not a plugin)

It has a builtin loading mechanism to preload only the wanted audiofiles.

Takes care of these cons:
- loading audio files when needed can introduce stuttering
- loading every single audiosample at once is memory inefficient
- writing the resource load() calls for every single audio sample in your script can be annoying

This manager plays audio samples imported into Godot divided into two categories, Effects and Music. The reason is to make it clear when music/effects are being played, and the other is being able to control audio levels for SFX and Music separately.

Filenames are automatically polled and preloading is as easy as is playing audio files.
```
AudioManager.load_effects("laser_sound")
AudioManager.play_effect("laser_sound")
```

Simultaneous streams are handled up to a configurable `channelCount` in case you need to limit it for performance or clutter.

## Setup
1. Copy the audio folder to you project.
2. Set the AudioManager.gd script to AutoLoad in project settings.
3. Put your audio files in the music/effects folders.
4. Use the accompanied bus_layout.tres to set audio_volumes or add busses ("Effects" and "Music") to your default layout. (Or change to names in the code yourself)

Names are automatically loaded from filenames without extensions. (Like godot, both OGG and WAV works).

## Usage
On loading your scene:
1. Set the the number of audio channels (maximum simultaneous audio streams, (default 16))
```
AudioManager.channelCount = 8
```
2. Call any configuration of the load_...() functions to load only the needed audio samples.

```
var effects = [
  "blip",
  "confirmation",
  "laser"
]
AudioManager.load_effects(effects)
AudioManager.load_music(["bgm"])
```

OR
```
  AudioManager.load_all_effects()
  AudioManager.load_all_music()
```

OR
```
  AudioManager.load_all()
```
3. Play audio from anywhere in your project using the audio name (filename without extensions).
```
AudioManager.play_effect("blip")
AudioManager.play_music("bgm")
```
4. Deload resource references (for garbage collection) if needed (ex. switching scenes or whatnot).
```
AudioManager.deload_all()
```
OR
```
AudioManager.deload_all_effects()
AudioManager.deload_all_music()
```
OR (specific)
```
AudioManager.deload_effect("blip")
AudioManager.deload_music("bgm")
# Both gives a non-interrupting error if no such stream is loaded
```

## Examples
See the example scene. The AudioManager is part of this example godot project.
