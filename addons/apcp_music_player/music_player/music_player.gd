extends PanelContainer

class_name MusicPlayer

@export_category("External")
@export_group("Playback Position")
enum Flag {
	Player = 1,
	Script = 2,
	Progress = 4,
	Editer = 8
}
@export_flags("Progress Bar:4","Editer:8") var pos_flag
@export var PosBar : Slider
@export var PosEditer : LineEdit
@export var PosLimiter : Label
@export_group("Volume")
@export_flags("Progress Bar:4","Editer:8") var volume_flag
@export var VolumeBar : Slider
@export var VolumeRange : Vector2 = Vector2(0.0,3.0)
@export var VolumeStep : float = 0.1
@export var VolumeEditer : LineEdit
@export var VolumeFormatter : String = "volume"
@export var VolumeCalculater : String = "v_v.to_float()"
@export_group("Lyric")
@export_range(3,7,2) var LyricDisplayCounts : int = 3
@export var LyricContainer : Container
@export_group("QOL")
@export var PlayButton : BaseButton

@export_category("Player Properties")
@export var BackWhenStop : bool = true
@export var Recycle : bool = true

signal stream_ended

var now_lyric_theme = preload("res://addons/apcp_music_player/music_player/assets/lyric/now_lyric_theme.tres")
var now_lyric_material : ShaderMaterial = preload("res://addons/apcp_music_player/music_player/assets/lyric/now_lyric_shader_material.tres")
var other_lyric_theme = preload("res://addons/apcp_music_player/music_player/assets/lyric/other_lyric_theme.tres")
var other_lyric_count = 1

var prev_lyrics : Array[Label] = []
var next_lyrics : Array[Label] = []
var now_lyric : Label = null

var player : AudioStreamPlayer = null
var lyric : LyricSearcher = LyricSearcher.new(LyricResource.new())
var stream : AudioStream = null

var volume_formatter : Expression
var volume_calculater : Expression
var is_ready := false
var pos_bar_draging := false
#region Position
var playback_pos : float = 0.0
func get_pos():
	return playback_pos
func set_pos(v_pp:float,source:Flag=Flag.Script):
	playback_pos = v_pp
	if not source & Flag.Player:
		print("[MusicPlayer]Seek to ",v_pp)
		print("[MusicPlayer]Source ",source)
		player.seek(playback_pos)
	if pos_flag & Flag.Progress and not source & Flag.Progress:
		if not pos_bar_draging:
			PosBar.value = playback_pos
	if pos_flag & Flag.Editer and not source & Flag.Editer:
		if not PosEditer.is_editing():
			PosEditer.text = Time.get_time_string_from_unix_time(int(playback_pos))
func set_pos_from_text(v_pp:String):
	set_pos(float(Time.get_unix_time_from_datetime_string(v_pp)),Flag.Editer)
#endregion
#region Volume
var volume : float = 10
func get_volume():
	return volume
func set_volume(v_v:float,source:Flag=Flag.Script):
	volume = v_v
	volume = clampf(volume,VolumeRange.x,VolumeRange.y)
	player.volume_linear = volume
	if volume_flag & Flag.Progress and not source & Flag.Progress:
		VolumeBar.value = volume
	if volume_flag & Flag.Editer and not source & Flag.Editer:
		VolumeEditer.unedit()
		VolumeEditer.text = str(volume_formatter.execute([],self))
func set_volume_from_text(v_v:String):
	set_volume(volume_calculater.execute([v_v],self),Flag.Editer)
#endregion

func bind_reacters():
	# Volume
	if volume_flag & Flag.Progress:
		VolumeBar.drag_ended.connect(func(changed:bool):
			print("[MusicPlayer]Volume Bar Draged with value ",VolumeBar.value)
			set_volume(VolumeBar.value,Flag.Progress)
		)
	if volume_flag & Flag.Editer:
		VolumeEditer.text_submitted.connect(set_volume_from_text)
	# Position
	if pos_flag & Flag.Progress:
		PosBar.drag_ended.connect(func(changed:bool):
			set_pos(PosBar.value,Flag.Progress)
			)
		PosBar.drag_ended.connect(func(changed:bool):
			pos_bar_draging = false
			)
		PosBar.drag_started.connect(func():
			pos_bar_draging = true
			)
	if pos_flag & Flag.Editer:
		PosEditer.text_submitted.connect(set_pos_from_text)
	if PlayButton != null:
		PlayButton.toggled.connect(toggle)
		stream_ended.connect(func():
			PlayButton.set_pressed_no_signal(false)
			)
	
	volume_formatter = Expression.new()
	volume_calculater = Expression.new()
	volume_formatter.parse(VolumeFormatter,[])
	volume_calculater.parse(VolumeCalculater,["v_v"])
	
	
func init_player():
	player = AudioStreamPlayer.new()
	add_child(player)
	set_pos(0.0)
	set_volume(1.0)
	player.finished.connect(func():
		stream_ended.emit()
		if BackWhenStop or Recycle:
			seek(0.0)
		if Recycle:
			play()
		)
func init_lyrics():
	now_lyric = Label.new()
	now_lyric.theme = now_lyric_theme
	now_lyric.material = now_lyric_material
	
	other_lyric_count = (LyricDisplayCounts - 1)/2
	
	for i in range(other_lyric_count):
		prev_lyrics.append(Label.new())
		prev_lyrics.back().theme = other_lyric_theme
		LyricContainer.add_child(prev_lyrics.back())
	
	LyricContainer.add_child(now_lyric)
	
	for i in range(other_lyric_count):
		next_lyrics.append(Label.new())
		next_lyrics.back().theme = other_lyric_theme
		LyricContainer.add_child(next_lyrics.back())

func reupdate_ui():
	if volume_flag & Flag.Progress:
		VolumeBar.min_value = VolumeRange.x
		VolumeBar.max_value = VolumeRange.y
		VolumeBar.step = VolumeStep
	if pos_flag & Flag.Progress:
		PosBar.min_value = 0.0
		if stream:
			PosBar.max_value = stream.get_length()
		else:
			PosBar.max_value = 0.0
	if pos_flag & Flag.Editer:
		if stream:
			PosLimiter.text = Time.get_time_string_from_unix_time(int(stream.get_length()))
		else:
			PosLimiter.text = Time.get_time_string_from_unix_time(0)
func update_lyrics():
	now_lyric.text = lyric.get_lyric(get_pos())
	if now_lyric.material is ShaderMaterial:
		var now_pos
		var next_pos
		var now_offset
		var now_length
		if lyric.has_lyrics():
			now_pos = lyric.find_lyric(playback_pos)
			next_pos = lyric.find_lyric(playback_pos,1)
			now_offset = playback_pos - now_pos
			now_length = next_pos-now_pos
		else:
			now_pos = 0.0
			next_pos = 1.0 if stream==null else stream.get_length()
			now_offset = playback_pos - now_pos
			now_length = next_pos-now_pos
		now_lyric.size = Vector2(0.0,0.0)
		now_lyric.material.set_shader_parameter("size",now_lyric.size)
		now_lyric.material.set_shader_parameter("now_value",now_offset)
		now_lyric.material.set_shader_parameter("max_value",now_length)
		
	for i in range(other_lyric_count):
		prev_lyrics[i].text = lyric.get_previous_lyric(get_pos(),other_lyric_count-i)
	for i in range(other_lyric_count):
		next_lyrics[i].text = lyric.get_next_lyric(get_pos(),i+1)
func update_playback_pos():
	if not player.playing:
		return
	set_pos(player.get_playback_position(),Flag.Player)

func _ready() -> void:
	bind_reacters()
	init_player()
	init_lyrics()
	
	is_ready=true
	
	reupdate_ui()

func _process(delta: float) -> void:
	update_lyrics()
	update_playback_pos()

func set_stream(v_stream:AudioStream,v_lyric:LyricResource):
	stream = v_stream
	lyric = LyricSearcher.new(v_lyric)
	set_pos(0.0)
	set_volume(1.0)
	player.stop()
	player.stream = stream
	reupdate_ui()

func seek(pos:float):
	set_pos(pos)
func play():
	seek(playback_pos)
	player.play(playback_pos)
func stop():
	player.stop()
func toggle(toggle_on:bool):
	if toggle_on:
		play()
	else:
		stop()
