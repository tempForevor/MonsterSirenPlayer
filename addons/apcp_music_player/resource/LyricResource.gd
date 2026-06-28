## Lyric, refers to the file .lrc [br][br]
## Lyric file has a specific format,which is like [br]
## :	[code] [mm:ss.ff]Content [/code][br]
## in each line.[br][br]
## ![em]Warning[/em],we supposed it to have no space lines and invalid input!
extends Resource

class_name LyricResource

static var INDENTY = LyricResource.new()

## It will be created by .create(...).provideTag()[br]
## Wrong result will provide you with NOT_MATCHED.
class TagResult:
	var tag : Tag = null
	var match : bool
	var left : String
	
	static func create(v_match:bool,v_left:String="") -> TagResult:
		var res = TagResult.new()
		res.match = v_match
		res.left = v_left
		return res
	
	func provideTag(v_tag:Tag) -> TagResult:
		tag = v_tag
		return self
	
	static var NOT_MATCHED := TagResult.create(false)
	
	static func _static_init() -> void:
		NOT_MATCHED = TagResult.create(false)

class Tag extends Resource:
	func _init() -> void:
		pass
	static func parse(str:String) -> TagResult:
		printerr("LyricResource.Tag is abstract!")
		return TagResult.new()

## [id:value]
class IdTag extends Tag:
	@export
	var id : String
	@export
	var value : String
	func _init(v_id:String,v_value:String) -> void:
		id = v_id
		value = v_value
	static func parse(str:String) -> TagResult:
		if not str.begins_with('['):
			return TagResult.create(false)
		if str[1].is_valid_int():
			return TagResult.create(false)
		# example: [al:Herta]test
		# pi = 3
		#       1,pi-1
		# id = [1,2] = al
		# pv = 9
		#          pi+1,pv-pi-1
		# value = [4,5] = Herta
		#         pv+1,-1
		# left = [10,-1] = test
		
		var pi = str.find(':')
		var id = str.substr(1,pi-1)
		var pv = str.find(']')
		var value = str.substr(pi+1,pv-pi-1)
		var tag = IdTag.new(id,value)
		var left = str.substr(pv+1,-1)
		return TagResult.create(true,left).provideTag(tag)

static func get_time_from_str(str:String) -> float:
		var pt = str.find(':')
		var pp = str.find('.')
		
		# 33:44.55
		# pt = 2
		# pp = 5
		# mm = [0,2]
		# ss = [3,2]
		# ff = [6,-1]
		
		var mm = str.substr(0,pt).to_float()
		var ss = str.substr(pt+1,pp-pt-1).to_float()
		var ff = str.substr(pp+1).to_float()
		
		var res = ff/1000.0 + ss + mm*60.0
		
		return res

## [mm:ss.fff]content[br]
## We supposed it is started from 0ms,
## So we use a float variable to store time.
class TimeTag extends Tag:
	@export
	var time : float
	@export
	var content : String
	func _init(v_time:float,v_content:String) -> void:
		time = v_time
		content = v_content
	static func parse(str:String) -> TagResult:
		if not str.begins_with('['):
			return TagResult.create(false)
		if not str[1].is_valid_int():
			return TagResult.create(false)
		
		# example : [00:23.292]How many winters in a gaze,[...
		# pc = 10
		# pe = 38
		# str_time = [0,pc]
		# content = [pc+1,pe-pc-1]
		var pc = str.find(']')
		var pe = str.find('[',1)
		
		var left = ""
		if pe == -1:
			pe = str.length()
		else:
			left = str.substr(pe)
		
		var str_time = str.substr(1,pc-1)
		var time = LyricResource.get_time_from_str(str_time)
		var content = str.substr(pc+1,pe-pc-1)
		
		var tag = TimeTag.new(time,content)
		
		return TagResult.create(true,left).provideTag(tag)

@export var lyrics : Dictionary[float,String] = {}
@export var data : Dictionary[String,String] = {}
var primitive_table : Array[Tag] = []

func reset_lyric():
	lyrics = {}
	for i in primitive_table:
		if i is TimeTag:
			lyrics[i.time] = i.content
		if i is IdTag:
			data[i.id] = i.value

static func try_get_tag(str:String) -> TagResult:
	var id_res = IdTag.parse(str)
	if id_res.match:
		return id_res
	return TimeTag.parse(str)

static func parse_line(str:String) -> Array[Tag]:
	var res : Array[Tag] = []
	var origin = TagResult.create(true,str)
	
	while !origin.left.is_empty() and origin.match:
		origin = try_get_tag(origin.left)
		if origin.match:
			res.append(origin.tag)
	
	return res

static func parse(str:String) -> LyricResource:
	var lines = str.split('\n')
	var res = LyricResource.new()
	for line in lines:
		res.primitive_table.append_array(parse_line(line))
	res.reset_lyric()
	return res

static func from_string(str:String) -> LyricResource:
	return parse(str)
 
