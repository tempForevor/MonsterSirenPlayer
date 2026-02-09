# 该CacheSystem针对网络api特化,别用于正常的cache
extends Node

var cache_path = "user://MSRPlayerCache.cache"

var cover_cache : Dictionary[String,PackedByteArray] = {}

func load_cache(url:String,update:bool=false,byfile:bool=true)->PackedByteArray:
	# update控制是否强制更新获取
	var turl = UrlUtil.noprefix(url)
	turl = UrlUtil.encode(turl)
	if not update:
		# 防止url中的特殊字符(尤其是windows)
		if cover_cache.has(turl):
			return cover_cache[turl]
		# 即可以通过文件名强行访问(为网络api特化)
		if byfile:
			if cover_cache.has(turl.get_file()):
				return cover_cache[turl.get_file()]
			for i in cover_cache.keys():
				if (i as String).get_file() == turl.get_file():
					cover_cache[turl.get_file()] = cover_cache[i]
					return cover_cache[i]
	# 针对网络api特化
	cover_cache[turl] = await MsrApi.call_api(url,{},false,false)
	return cover_cache[turl]

func update_cache(url:String)->PackedByteArray:
	return await load_cache(url,true)

# 该函数从单文件加载cache
func load_all_cache():
	if FileAccess.file_exists(cache_path):
		var file = FileAccess.open(cache_path,FileAccess.READ)
		cover_cache = file.get_var(true)

# 该函数从单文件保存cache
func save_all_cache():
	if FileAccess.file_exists(cache_path):
		DirAccess.open("user://").remove(cache_path)
	var file = FileAccess.open(cache_path,FileAccess.WRITE_READ)
	if file == null:
		print(FileAccess.get_open_error())
	file.store_var(cover_cache,true)
	file.close()

var cache_dir = "user://MSRPCache//"

func load_single_cache(path:String)->PackedByteArray:
	if FileAccess.file_exists(path):
		return FileAccess.get_file_as_bytes(path)
	printerr("不存在该cache文件 : ",path)
	return PackedByteArray([])

# 该函数会从[code]cache_dir[/code]目录进行读取
func load_muilt_cache():
	var dir := DirAccess.open("user://")
	if not dir.dir_exists(cache_dir):
		dir.make_dir_recursive(cache_dir)
	dir = DirAccess.open(cache_dir)
	
	cover_cache.merge(DictUtil.expand_dict(FileSystemUtil.get_file_tree(cache_dir,load_single_cache)))
	
# 该函数会从[code]cache_dir[/code]目录进行保存
func save_muilt_cache():
	var dir := DirAccess.open("user://")
	if not dir.dir_exists(cache_dir):
		dir.make_dir_recursive(cache_dir)
	dir = DirAccess.open(cache_dir)
	
	for i in cover_cache.keys():
		if not dir.file_exists(i):
			dir.make_dir_recursive((i as String).get_base_dir())
		if dir.file_exists(i):
			dir.remove(i)
		var file = FileAccess.open(dir.get_current_dir()+"/"+i,FileAccess.WRITE_READ)
		if file == null:
			printerr(FileAccess.get_open_error())
		file.store_buffer(cover_cache[i])
		file.close()
	

func _enter_tree() -> void:
	load_muilt_cache()
	#print(cover_cache.keys())

func _exit_tree() -> void:
	save_muilt_cache()
