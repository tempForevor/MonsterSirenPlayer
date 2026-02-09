extends Resource

class_name MusicPlayerStatus

@export var playback_pos : int = 0

func set_data(seek:int=0):
	playback_pos=seek
	return self

func from_obj(obj:MusicPlayerStatus):
	return set_data(obj.playback_pos)

func save_data(player:AudioStreamPlayer):
	playback_pos = player.get_playback_position()

func recover(player:AudioStreamPlayer):
	player.play(playback_pos)
