extends RefCounted

class_name CacheModel

func save_cache(res:CacheInfo,env:CacheEnvironment) -> Error:
	return env.save_overwrite(env.generate_item(res.resource,res.cache_name + ".tres"),res.resource)

##  If failed,the result's [code]has_resource()[/code] will be false.
func load_cache(res:CacheInfo,env:CacheEnvironment) -> CacheInfo:
	var resource = env.load_overwrite(env.generate_item_with_type(res.expected_type,res.cache_name + ".tres"))
	if resource == null:
		return res.duplicate().set_error(true)
	return res.duplicate().provide(resource).set_error(false)

func trans_from_provider(info:CacheInfo) -> CacheInfo:
	return info
