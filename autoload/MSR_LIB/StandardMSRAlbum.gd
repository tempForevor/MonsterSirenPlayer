extends Resource

class_name StandardMSRAlbum

## test{
##	"cid":"8924",
##	"name":"镜中集OST",
##	"intro":"终有一日，当强烈的意念落于实处，新的缘分会不会如期而至？",
##	"belong":"arknights",
##	"coverUrl":"https://web.hycdn.cn/siren/pic/20250709/b03624911f37f76a7fcd577033dd2db6.jpg",
##	"coverDeUrl":"https://web.hycdn.cn/siren/pic/20250709/89287558d3e4ffe103200c9b4f67ca29.jpg",
##	"songs":[
## 		{"cid":"232233","name":"秉心","artistes":["塞壬唱片-MSR"]}
##	]
## }

var cid : String = "8924"
var name : String = ""
var intro : String = ""
var belong : String = "arknights"
var coverUrl : String = ""
var coverDeUrl : String = ""
var songs : Array[StandardMSRSong] = []
var artists : Array = []
var isAlbum : bool = false

func set_data(data:Dictionary)->StandardMSRAlbum:
	if data.has("cid"):
		cid = str(data["cid"])
	if data.has("name"):
		name = str(data["name"])
	if data.has("intro"):
		intro = str(data["intro"])
	if data.has("belong"):
		belong = str(data["belong"])
	if data.has("coverUrl"):
		coverUrl = str(data["coverUrl"])
	if data.has("coverDeUrl"):
		coverDeUrl = str(data["coverDeUrl"])
	if data.has("artistes"):
		artists = (data["artistes"] as Array).duplicate(false)
	else:
		artists = []
	if data.has("songs"):
		songs = []
		var t = data["songs"]
		for i in t:
			songs.append(StandardMSRSong.new().set_data(i))
	return self
func set_data_from_obj(aobj:StandardMSRAlbum)->StandardMSRAlbum:
	cid = aobj.cid
	name = aobj.name
	intro = aobj.intro
	belong = aobj.belong
	coverUrl = aobj.coverUrl
	coverDeUrl = aobj.coverDeUrl
	songs = aobj.songs.duplicate(false)
	artists = aobj.artists.duplicate(false)
	isAlbum = aobj.isAlbum
	return self
func tag_album():
	isAlbum = true
	return self
func get_full_data()->StandardMSRAlbum:
	return set_data_from_obj(await MsrApi.get_album(cid))

func get_item_name(de:bool=false) -> String:
	if de:
		return name + "De"
	return name

func get_cover(de:bool=false):
	var req_url = ""
	if de:
		req_url = coverDeUrl
	else:
		req_url = coverUrl
	if req_url == "":
		req_url = coverUrl
	if req_url == "":
		req_url = coverDeUrl
	var t := await MsrApi.cache_manager.load_cache(CacheInfo.new(
		get_item_name(de),MsrApi.cache_type["image"],[req_url,self]
	))
	return t.resource
