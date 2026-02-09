extends RefCounted

class_name StandardMSRSong

## test {
## "cid":"125042",
## "name":"Sanctuary Inside",
## "albumCid":"5194",
## "sourceUrl":"https://res01.hycdn.cn/bd9758ede478237fad4ca5b1ba769806/687FA89D/siren/audio/20250430/61d007fbdd059d6c77d24359aa85c1f4.wav",
## "lyricUrl":"https://web.hycdn.cn/siren/lyric/20250430/19f12a6e5b193f4010f91e1bd82518ba.lrc",
## "mvUrl":null,
## "mvCoverUrl":null,
## "artists":["塞壬唱片-MSR"]
## }

var cid : String = "125042"
var name : String = ""
var albumCid : String = ""
var sourceUrl : String = ""
var lyricUrl : String = ""
var mvUrl : String = "<null>"
var mvCoverUrl : String = "<null>"
var artists : Array = []
var isAlbum : bool = false

func set_data(data:Dictionary)->StandardMSRSong:
	if data.has("cid"):
		cid = str(data["cid"])
	if data.has("name"):
		name = str(data["name"])
	if data.has("albumCid"):
		albumCid = str(data["albumCid"])
	if data.has("sourceUrl"):
		sourceUrl = str(data["sourceUrl"])
	if data.has("lyricUrl"):
		lyricUrl = str(data["lyricUrl"])
	if data.has("mvUrl"):
		mvUrl = str(data["mvUrl"])
	if data.has("mvCoverUrl"):
		mvCoverUrl = str(data["mvCoverUrl"])
	if data.has("artists"):
		artists = data["artists"].duplicate(false)
	return self
func set_data_from_obj(aobj:StandardMSRSong)->StandardMSRSong:
	cid = aobj.cid
	name = aobj.name
	albumCid = aobj.albumCid
	sourceUrl = aobj.sourceUrl
	lyricUrl = aobj.lyricUrl
	mvUrl = aobj.mvUrl
	mvCoverUrl = aobj.mvCoverUrl
	artists = aobj.artists.duplicate(false)
	isAlbum = aobj.isAlbum
	return self
func tag_album():
	isAlbum = true
	return self
func get_full_data()->StandardMSRSong:
	return set_data_from_obj(await MsrApi.get_song(cid))
