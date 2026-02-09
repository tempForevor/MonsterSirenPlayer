extends Control

class_name MusicController

var control_scene = preload("res://addons/MusicPlayer/MusicCntroller.tscn")
var control = null

var stream : AudioStream:
	set(v):
		control.stream = v
	get:
		return control.stream

var lyric : LyricResource:
	set(v):
		control.lyric = v
	get:
		return control.lyric


func _ready() -> void:
	control = control_scene.instantiate()
	add_child(control)

func _process(delta: float) -> void:
	control.custom_minimum_size = self.size
