extends CacheModel

class_name CacheDataModel

var extension : String = ".tres"

func _init(v_extension : String = ".tres") -> void:
	extension = v_extension

func get_extension(info:CacheInfo) -> String:
	return extension

func save_cache(res:CacheInfo,env:CacheEnvironment) -> Error:
	return env.save_bytes(env.generate_item_with_type(res.expected_type,res.cache_name + get_extension(res)),res.resource)

##  If failed,the result's [code]has_resource()[/code] will be false.
func load_cache(res:CacheInfo,env:CacheEnvironment) -> CacheInfo:
	var resource := env.load_bytes(env.generate_item_with_type(res.expected_type,res.cache_name  + get_extension(res)))
	if resource == null or resource.is_empty():
		return res.duplicate().set_error(true)
	return res.duplicate().provide(resource).set_error(false)

func trans_from_provider(info:CacheInfo) -> CacheInfo:
	return info
