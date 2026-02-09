extends Window

@onready var ResCt = $ResContainer/ResContainer

func _init() -> void:
	ScenesVariables.AlbumDetail = self

func _ready() -> void:
	title = TranslationServer.translate(title)

func show_album(aalbum:StandardMSRAlbum):
	size = PlayerUtil.custom_window_size()
	self.popup_centered()
	PlayerUtil.reset_res_container(ResCt)
	var album = await aalbum.get_full_data()
	ResCt.add_child(await PlayerUtil.create_album_detail_label(album,false))
	for i in album.songs:
		ResCt.add_child(await PlayerUtil.create_song_detail_label(i))

func _process(_delta: float) -> void:
	$ResContainer.size = size
	$ResContainer/ResContainer.custom_minimum_size = size


func _on_close_requested() -> void:
	self.hide()
