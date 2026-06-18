extends RefCounted

class_name CacheInfo

var cache_name : String = "UNEXPECTED_NAME"
var resource  = null
var error = true

var cache_arguments : Array = []

var expected_type : String = "Resource"


func _init(v_cache_name:String,v_expected_type:String="Resource",v_cache_arguments:=[]) -> void:
	cache_name = v_cache_name
	expected_type = v_expected_type
	cache_arguments = v_cache_arguments

func to_id_str() -> String:
	return cache_name + "@" + expected_type

func duplicate(with_resource:bool=false,deep:bool=false):
	var new_one := CacheInfo.new(cache_name,expected_type,cache_arguments)
	if with_resource:
		if deep:
			if resource is Resource:
				return new_one.provide(resource.duplicate())
			if resource is PackedByteArray:
				return new_one.provide(resource.duplicate())
		return new_one.provide(resource)
	return new_one

func provide(v_res) -> CacheInfo:
	resource = v_res
	return self

func set_error(v_error:bool=false) -> CacheInfo:
	error = v_error
	return self

func has_resource() -> bool:
	return not error
