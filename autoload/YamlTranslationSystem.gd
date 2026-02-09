extends Node

var trans_path = "res://translation.json"

func get_smooth_dictionary(dic:Dictionary,prefix:String="")->Dictionary:
	var res = {}
	for i in dic.keys():
		if dic[i] is Dictionary:
			res.merge(get_smooth_dictionary(dic[i],i+"."))
		else:
			res[prefix+i]=dic[i]
	return res

func load_translate():
	var file = FileAccess.open(trans_path,FileAccess.READ)
	var stri = file.get_as_text()
	var trd = JSON.parse_string(stri)
	for i in trd.keys():
		var trn = Translation.new()
		trn.locale = i
		var trcomments = get_smooth_dictionary(trd[i])
		for j in trcomments.keys():
			trn.add_message(j,trcomments[j])
		TranslationServer.add_translation(trn)

func _init() -> void:
	load_translate()
