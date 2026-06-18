extends RefCounted

class_name CacheManagerClass

var models : Dictionary[String,CacheModel] = {}
var default_model : CacheModel = CacheModel.new()

var memory_cache : Dictionary[String,CacheInfo] = {}

var env : CacheEnvironment

func _init(v_env:CacheEnvironment) -> void:
	env = v_env

func add_model(type:String,model:CacheModel):
	models[type] = model

func remove_model(type:String):
	models.erase(type)

func get_model(type:String) -> CacheModel:
	if models.has(type):
		return models[type]
	return default_model

func do_nothing_provider(info:CacheInfo):
	pass

## If failed,the method will return null.
func load_cache(info:CacheInfo,need_providing:bool=true,update:bool=false) -> CacheInfo:
	if memory_cache.has(info.to_id_str()) and (not update):
		return memory_cache[info.to_id_str()]
	var model = get_model(info.expected_type)
	var new_info = model.load_cache(info,env)
	var save_flag = false
	if not new_info.has_resource():
		if need_providing or update:
			save_flag = true
			new_info = await model.trans_from_provider(info)
	else:
		if update:
			save_flag = true
			new_info = await model.trans_from_provider(info)
	if new_info.has_resource():
		memory_cache[info.to_id_str()] = new_info
		if save_flag:
			save_cache(info)
		return memory_cache[info.to_id_str()]
	return null


func save_cache(info:CacheInfo) -> Error:
	if not memory_cache.has(info.to_id_str()):
		return ERR_DOES_NOT_EXIST
	return get_model(info.expected_type).save_cache(memory_cache[info.to_id_str()],env)
