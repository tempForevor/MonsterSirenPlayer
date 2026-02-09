extends Node

func recursive_merge(obj:Dictionary,arg:Dictionary,overwrite:=true)->Dictionary:
	var res = obj.duplicate_deep()
	for i in arg.keys():
		if obj.has(i):
			if obj[i] is Dictionary and arg[i] is Dictionary:
				res[i] = recursive_merge(obj[i],arg[i])
			elif obj[i] is Dictionary or arg[i] is Dictionary:
				printerr("无法将量与字典合并")
			elif overwrite:
				res[i] = arg[i]
		else:
			res[i] = arg[i]
	return res

func expand_dict(obj:Dictionary,split:="/",prefix:="")->Dictionary:
	var res = {}
	for i in obj.keys():
		if obj[i] is Dictionary:
			var temp = expand_dict(obj[i],split,prefix+i+split)
			for j in temp.keys():
				res[j] = temp[j]
		else:
			res[prefix+i] = obj[i]
	return res

func _enter_tree() -> void:
	# Test
	print(expand_dict({
		"T1":{
			"T2":"V1",
			"T3":{
				"T4":"V2"
			}
		},
		"T5":"V3"
	}))
