extends Control

class_name MusicController

var control_scene = preload("res://addons/apcp_music_player/music_player/style1.tscn")
var control : MusicPlayer = null

var _stream : AudioStream
var stream:
	set(v):
		_stream = v
		update()
	get:
		return _stream
var _lyric : LyricResource = LyricResource.new()
var lyric:
	set(v):
		_lyric = v
		update()
	get:
		return _lyric

func update():
	control.set_stream(_stream,_lyric)

func _ready() -> void:
	control = control_scene.instantiate()
	add_child(control)

func _process(delta: float) -> void:
	#control.custom_minimum_size = self.size
	control.position = Vector2(0.0,0.0)
