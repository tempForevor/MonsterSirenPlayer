extends Control

class_name INNER_MUSIC_CONTROLLER_PLAYER_COM

@onready var Background : ColorRect = $Panel
@onready var Player : AudioStreamPlayer = $AudioPlayer
@onready var PlayButton : TextureButton = $HBoxContainer/PlayButton
@onready var Progress : HSlider = $HBoxContainer/ProgressBar
@onready var TimeEdit : LineEdit = $HBoxContainer/TimeEdit
@onready var TimeLabel : Label = $HBoxContainer/Time
@onready var Volume : HSlider = $HBoxContainer/Volume
@onready var LyricScroll : ScrollContainer = $LyricScrollPanel
@onready var Lyric : VBoxContainer = $LyricScrollPanel/ScrollContainer
var LyricLabels : Array[Label] = []
var last_play : MusicPlayerStatus = MusicPlayerStatus.new().set_data(0.0)

var play_button_size : Vector2i = Vector2i(32,40)
var progress_size : Vector2i = Vector2i(128,40)
var volume_size : Vector2i = Vector2i(128,40)
var time_size : Vector2i = Vector2i(64,40)
var lyric_size : Vector2i = Vector2i(1000,120)
var playing = false
var time_playing = false
var progress_playing = false

var dynamic_change_progress_size : bool = true
var dynamic_radio : float = 0.9
var dynamic_change_lyric_size : bool = true
var dynamic_lyric_single_height : int = 100

var process_input = false
var SHORTCUT = {
	play = "MusicController_Player_Play",
	forward = "MusicController_Player_Forward",
	backward = "MusicController_Player_Backward"
}
var key_map : Dictionary[String,int] = {
	"MusicController_Player_Play" : KEY_SPACE,
	"MusicController_Player_Forward" : KEY_RIGHT,
	"MusicController_Player_Backward" : KEY_LEFT
}

var stream : AudioStream:
	set(v):
		Player.stream = v
	get:
		return Player.stream

var lyric : LyricResource = LyricResource.INDENTY
var lyric_showed_cnt : int = 3:
	set(v):
		lyric_showed_cnt = v
		lyric_init()
var now_lyric_theme : Theme = preload("res://addons/MusicPlayer/now_lyric_theme.tres")
var other_lyric_theme : Theme = preload("res://addons/MusicPlayer/other_lyric_theme.tres")


func _init() -> void:
	pass

func _ready() -> void:
	Background = $Panel
	Player = $AudioPlayer
	PlayButton = $HBoxContainer/PlayButton
	Progress= $HBoxContainer/ProgressBar
	TimeEdit = $HBoxContainer/TimeEdit
	TimeLabel = $HBoxContainer/Time
	last_play = MusicPlayerStatus.new().set_data(0)
	
	for i in key_map.keys():
		if InputMap.has_action(i):
			InputMap.erase_action(i)
		InputMap.add_action(i)
		var e = InputEventKey.new()
		e.keycode = key_map[i]
		e.pressed = true
		InputMap.action_add_event(i,e)
	gui_reset()
	lyric_init()

func gui_reset():
	if dynamic_change_progress_size:
		progress_size.x = int((size.x - play_button_size.x - (time_size.x  * 2) - volume_size.x) * dynamic_radio)
	if dynamic_change_lyric_size:
		lyric_size.y = get_lyric_cnt() * dynamic_lyric_single_height
		lyric_size.x = size.x
	
	PlayButton.custom_minimum_size = play_button_size
	Progress.custom_minimum_size = progress_size
	Volume.custom_minimum_size = volume_size
	TimeEdit.custom_minimum_size = time_size
	TimeLabel.custom_minimum_size = time_size
	Background.size=$HBoxContainer.size
	LyricScroll.custom_minimum_size = lyric_size
	for i in LyricLabels:
		i.custom_minimum_size.x = lyric_size.x

func _process(delta: float) -> void:
	gui_reset()
	
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"),Volume.value/Volume.max_value)
	
	if stream != null:
		TimeLabel.text = str(Time.get_time_string_from_unix_time( stream.get_length() ))
		Progress.max_value = stream.get_length()
		if time_playing:
			TimeEdit.text = str(Time.get_time_string_from_unix_time( Player.get_playback_position() ) )
		if progress_playing:
			Progress.value = Player.get_playback_position()
	
	process_input = is_visible_in_tree()
	
	if process_input:
		if Input.is_action_just_pressed(SHORTCUT.play,true):
			change(not playing)
			PlayButton.grab_focus()
		if Input.is_action_pressed(SHORTCUT.forward,true) or Input.is_action_pressed(SHORTCUT.backward,true):
			if Progress.has_focus() and Volume.has_focus():
				Progress.grab_focus()
	
	set_lyrics()

func get_lyric_cnt()->int:
	return abs(lyric_showed_cnt)+1 if lyric_showed_cnt%2==0 else abs(lyric_showed_cnt)

func get_half_lyric_cnt()->int:
	return get_lyric_cnt()>>1

func lyric_init():
	LyricScroll.position.y = $HBoxContainer.size.y
	if Lyric.get_child_count()>0:
		for i in Lyric.get_children():
			i.queue_free()
	LyricLabels = []
	var c = get_lyric_cnt()
	var h = get_half_lyric_cnt()
	for i in range(0,c):
		var l : Label = Label.new()
		l.custom_minimum_size.x = LyricScroll.custom_minimum_size.x
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if i == h:
			l.theme = now_lyric_theme
		else:
			l.theme = other_lyric_theme
		Lyric.add_child(l)
		LyricLabels.append(l)

func set_lyrics():
	if LyricLabels.is_empty():
		return
	var p = (Player.get_playback_position()) if playing else last_play.playback_pos
	var h = get_half_lyric_cnt()
	for i in range(0,h):
		LyricLabels[i].text = lyric.get_previous_lyric(p,h-i)
	LyricLabels[h].text = lyric.get_lyric(p)
	for i in range(1,h+1):
		LyricLabels[h+i].text = lyric.get_next_lyric(p,i)


func stop()->void:
	last_play.save_data(Player)
	Player.stop()
	PlayButton.set_pressed_no_signal(false)
	playing = false
	time_playing = false
	progress_playing = false
func play()->void:
	last_play.recover(Player)
	PlayButton.set_pressed_no_signal(true)
	playing = true
	time_playing = true
	progress_playing = true
func seek(pos:int)->void:
	last_play.set_data(pos)
	Player.seek(pos)
	##IDK why it does not work...
	stop()
	play()
	##

func change(tg:bool)->void:
	if tg:
		play()
	else:
		stop()

func _on_play_button_toggled(toggled_on: bool) -> void:
	change(toggled_on)


func _on_progress_bar_drag_started() -> void:
	progress_playing = false

func _on_progress_bar_drag_ended(value_changed: bool) -> void:
	seek(Progress.value)
	progress_playing = playing

func _on_time_edit_editing_toggled(toggled_on: bool) -> void:
	if toggled_on:
		time_playing = false
		return
	seek(Time.get_unix_time_from_datetime_string(TimeEdit.text))
	time_playing = playing
