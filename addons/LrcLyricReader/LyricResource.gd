extends Resource

class_name LyricResource

@export var lyric_time_table : Dictionary[float,String] = {}
var origin_time_table : Dictionary[String,String] = {}

static var INDENTY = LyricResource.indenty()

func get_lyrics()->Dictionary:
	if lyric_time_table.is_empty():
		lyric_time_table[0]=TranslationServer.translate("LyricResource.nolyric")
	return lyric_time_table

# 1 2 3 4 5
# 2.5
# 0 5 2 3
# 0 2 1 2
# 0
# 0
static func bsearch(list:Array,value:int):
	var l = 0
	var r = list.size()
	var mid = l + (r-l)>>1
	while l < r:
		if list[mid]>value:
			r=mid
		if list[mid]<value:
			l=mid
	return l

func get_lyric_pos(playback_pos:float,post_process:Callable=func(v):return v)->float:
	var list = lyric_time_table.keys()
	var r = list.bsearch(playback_pos,true)
	r = r - 1 #Idk why I needs it... It's unbelieveable
	return list[clampi(post_process.call(r),0,list.size()-1)]

func get_lyric(playback_pos:float)->String:
	return lyric_time_table[get_lyric_pos(playback_pos)]

func get_previous_lyric(playback_pos:float,previous:int=1)->String:
	return lyric_time_table[get_lyric_pos(playback_pos,(func(v,p):return v-p).bind(previous))]

func get_next_lyric(playback_pos:float,next:int=1)->String:
	return lyric_time_table[get_lyric_pos(playback_pos,(func(v,p):return v+p).bind(next))]

# 1 s 2 m 3 h 4 d
static var time_trans_map : Dictionary[int,float] = {
	1:1.0,
	2:60.0,
	3:60.0*60.0,
	4:60.0*60.0*24.0
}
static func string2time(s:String)->float:
	var t = 0.0
	var ts = s.split(":")
	for i in range(1,ts.size()+1):
		t += time_trans_map[clampi(i,1,3)] * (ts[ts.size()-i] as String).to_float()
	return t

static func from_string(src:String)->LyricResource:
	var lyricr : LyricResource = LyricResource.new()
	var lyrics = src.split("[",false)
	for i in lyrics:
		var cons = i.split("]",false)
		var timestring = cons[0]
		var lyricstring = cons[1]
		var time = string2time(timestring)
		lyricr.lyric_time_table[time]=lyricstring
		lyricr.origin_time_table[timestring]=lyricstring
	lyricr.get_lyrics()
	return lyricr

static func indenty()->LyricResource:
	var lyric : LyricResource = LyricResource.new()
	lyric.get_lyrics()
	return lyric
