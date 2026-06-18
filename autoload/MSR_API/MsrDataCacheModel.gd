extends CacheDataModel

class_name MsrDataCacheModel

func get_extension(info:CacheInfo) -> String:
	return "." + (info.cache_arguments[0] as String).get_extension()

func trans_from_provider(info:CacheInfo) -> CacheInfo:
	var res = await MsrApi.call_api(info.cache_arguments[0],{},false,false)
	if res == null:
		return info.duplicate().set_error(true)
	if (res as PackedByteArray).is_empty():
		return info.duplicate().set_error(true)
	return info.duplicate().provide((res as PackedByteArray)).set_error(false)
