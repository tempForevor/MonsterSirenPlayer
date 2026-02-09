extends Window

@onready var ResCt = $ResContainer/ResContainer

func _init() -> void:
	ScenesVariables.SongDetail = self

func _ready() -> void:
	title = TranslationServer.translate(title)

func show_song(asong:StandardMSRSong):
	size = PlayerUtil.custom_window_size()
	self.popup_centered()
	PlayerUtil.reset_res_container(ResCt)
	var song = await asong.get_full_data()
	var dl = await PlayerUtil.create_song_detail_label(song,false)
	ResCt.add_child(dl)
	var placeholder = Control.new()
	placeholder.custom_minimum_size.y = 1000
	ResCt.add_child(placeholder)
	#dl.Playercom.Root.control.Player = $AudioStreamPlayer

func _process(_delta: float) -> void:
	$ResContainer.size = size
	$ResContainer/ResContainer.custom_minimum_size = size


func _on_close_requested() -> void:
	self.hide()
