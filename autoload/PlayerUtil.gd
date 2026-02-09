extends Node

var album_container = preload("res://containers/album_container.tscn")
var song_container = preload("res://containers/song_container.tscn")

func create_song_detail_label(s:StandardMSRSong,simple:bool=true):
	var p := song_container.instantiate()
	p.set_data(s,simple)
	p.choose_this_song.connect(func():
		ScenesVariables.SongDetail.show_song(s)
	)
	return p

func create_album_detail_label(s:StandardMSRAlbum,simple:bool=true):
	var p = album_container.instantiate()
	p.set_data(s,simple)
	p.choose_this_album.connect(func():
		ScenesVariables.AlbumDetail.show_album(s)
	)
	return p

func reset_res_container(ref:Control):
	if ref.get_child_count() > 0:
		for i in ref.get_children():
			i.queue_free()

func custom_window_size():
	return DisplayServer.window_get_size() * 0.9
