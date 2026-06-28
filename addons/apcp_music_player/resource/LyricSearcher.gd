extends RefCounted

class_name LyricSearcher

var res : LyricResource

func _init(v_res:LyricResource) -> void:
	res = v_res

func has_lyrics()->bool:
	return not res.lyrics.is_empty()

func clamp_lyric_key_index(index:int)->int:
	return clampi(index,0,res.lyrics.size()-1)

func get_lyric_key_at(index:int)->float:
	if res.lyrics.is_empty():
		return 1.0
	return res.lyrics.keys()[clamp_lyric_key_index(index)]

func clamp_lyric_index(index:float)->float:
	var keyref = res.lyrics.keys()
	return clampf(index,keyref.front(),keyref.back())

func get_lyric_at(index:float)->String:
	if res.lyrics.is_empty():
		return "No Lyrics"
	return res.lyrics[clamp_lyric_index(index)]

## No protections
func find_lyric_key_index(pos:float)->int:
	var keyref = res.lyrics.keys()
	var index = keyref.bsearch(pos,false)-1
	return index

func find_lyric(pos:float,offset:int=0)->float:
	return get_lyric_key_at(find_lyric_key_index(pos)+offset)

func get_lyric(pos:float,offset:int=0)->String:
	if res.lyrics.is_empty() and offset == 0:
		return "No Lyrics"
	var index = find_lyric_key_index(pos)+offset
	var max_i = res.lyrics.size()
	if index < 0 or index >= max_i:
		return ""
	return get_lyric_at(get_lyric_key_at(index))
	

func get_previous_lyric(pos:float,offset:int=1)->String:
	return get_lyric(pos,-offset)

func get_next_lyric(pos:float,offset:int=1)->String:
	return get_lyric(pos,offset)
