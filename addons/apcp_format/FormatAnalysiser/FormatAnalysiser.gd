extends Node

var caches : Dictionary[StringName,FormatModel] = {
	
}

func analysis(raw:StringName,update:bool=false)->FormatModel:
	if not update:
		if caches.has(raw):
			return caches[raw]
	caches[raw]=FormatModel.analysis(raw)
	return caches[raw]

func format(raw:StringName,args:Array)->String:
	return analysis(raw).format(args)
