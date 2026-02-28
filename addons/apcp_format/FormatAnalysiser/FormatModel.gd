extends RefCounted

class_name FormatModel

class VarPos:
	var positions : Array[int] = []
	func _init(arg_pos:Array[int]) -> void:
		positions = arg_pos.duplicate_deep()

var model : Array[String] = []
var varpos : Dictionary[String,VarPos] = {}

func format(args:Dictionary[String,Variant.Type])->String:
	var res = model.duplicate_deep()
	for def in varpos.keys():
		if args.has(def):
			for pos in varpos[def].positions:
				res[pos] = args[def]
		else:
			printerr("Missing Format Args : ",def)
	var str = ""
	for i in res:
		str += i
	return str;

static func analysis(raw:String)->FormatModel:
	pass
