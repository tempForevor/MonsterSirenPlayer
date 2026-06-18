extends RefCounted

class_name FormatModel

class VarPos:
	var positions : Array[int] = []
	func _init(arg_pos:Array[int]=[]) -> void:
		positions = arg_pos.duplicate_deep()

var model : Array[String] = []
var varpos : Dictionary[String,VarPos] = {}

func format(args:Dictionary[String,String])->String:
	var res = model.duplicate_deep()
	for def in varpos.keys():
		if args.has(def):
			for pos in varpos[def].positions:
				res[pos] = str(args[def])
		else:
			printerr("Missing Format Args : ",def)
	var str = ""
	for i in res:
		str += i
	return str

static func analysis(raw:String)->FormatModel:
	var model := FormatModel.new()
	var flag := 0
	var tkey := ""
	for i in range(0,raw.length()):
		if raw[i] == FormatConfig.placeholder_left:
			flag += 1
			model.model.push_back(tkey)
			tkey = ""
			continue
		if raw[i] == FormatConfig.placeholder_right:
			flag -= 1
			model.model.push_back(tkey)
			if(not model.varpos.has(tkey)):
				model.varpos[tkey] = VarPos.new([])
			model.varpos[tkey].positions.append(model.model.size()-1)
			tkey = ""
			continue
		tkey += raw[i]
	if not tkey.is_empty():
		model.model.push_back(tkey)
	return model
