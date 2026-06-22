extends RefCounted

class_name CacheEnvironment

var cache_parent : String = "user://"
var cache_dir : String = "user://Cache/"

func _init(v_cache_dir:String="user://Cache/") -> void:
	cache_dir = v_cache_dir

var replaced_file_name_char : Dictionary[String,String] = {
	"<":"-[lcb]-",
	">":"-[rcb]-",
	#":":"：", # This may need to be specially judged someday
	"\"":"“",
	#"/":"-[rrl]-",
	#"\\":"-[lrl]-",
	"|":"-[mlm]-",
	"*":"-[mul]-",
	"?":"？"
}

func avaliable_file_name(raw:String)->String:
	var res = raw
	for i in replaced_file_name_char.keys():
		res = res.replace(i,replaced_file_name_char[i])
	return res

func get_item_path(item:String) -> String:
	return avaliable_file_name(cache_dir.path_join(item))

func generate_item_with_type(type:String,name:String) -> String:
	return type.path_join(name)

func generate_item(res,name:String) -> String:
	return generate_item_with_type(res.get_class(),name)

func test_path_exists(path:String,is_dir:bool=false) -> bool:
	var tpath = avaliable_file_name(path)
	var dir = DirAccess.open(cache_parent)
	if not dir.dir_exists(tpath.get_base_dir()):
		return false
	if is_dir:
		return true
	return dir.file_exists(tpath)

func test_item_existe(item:String,is_dir:bool=false) -> bool:
	return test_path_exists(get_item_path(item),is_dir)

func create_path_if_miss(path:String,is_dir:bool=false) -> Error:
	var tpath = avaliable_file_name(path)
	var dir := DirAccess.open(cache_parent)
	var error := OK
	if not dir.dir_exists(tpath.get_base_dir()):
		error = dir.make_dir_recursive(tpath.get_base_dir())
	#print("Now error : ",error)
	if is_dir:
		return error
	if dir.file_exists(tpath):
		return ERR_ALREADY_EXISTS
	var file := FileAccess.open(tpath,FileAccess.WRITE_READ)
	error = FileAccess.get_open_error()
	if file == null:
		error = ERR_FILE_UNRECOGNIZED
	return error

func create_item_if_miss(item:String,is_dir:bool=false) -> Error:
	return create_path_if_miss(get_item_path(item),is_dir)

func remove_path_if_exists(path:String) -> Error:
	var tpath = avaliable_file_name(path)
	var dir = DirAccess.open(cache_parent)
	if not dir.dir_exists(tpath.get_base_dir()):
		return ERR_FILE_NOT_FOUND
	if not dir.file_exists(tpath):
		return ERR_FILE_NOT_FOUND
	return dir.remove(tpath)

func remove_item_if_exists(item:String) -> Error:
	return remove_path_if_exists(get_item_path(item))

func save_overwrite(item:String,res:Resource) -> Error:
	remove_item_if_exists(item)
	create_item_if_miss(item.get_base_dir(),true)
	return ResourceSaver.save(res,get_item_path(item))

## If it is not existed,the method will return null.
func load_overwrite(item:String)->Resource:
	create_item_if_miss(item.get_base_dir(),true)
	if test_item_existe(item):
		return ResourceLoader.load(get_item_path(item))
	return null

func save_data(item:String,res) -> Error:
	remove_item_if_exists(item)
	var result_create = create_item_if_miss(item)
	var file = FileAccess.open(get_item_path(item),FileAccess.WRITE)
	var ok = file.store_var(res)
	return ERR_FILE_CANT_WRITE if not ok else OK

func load_data(item:String):
	create_item_if_miss(item.get_base_dir(),true)
	if test_item_existe(item):
		var file = FileAccess.open(get_item_path(item),FileAccess.READ)
		return file.get_var()
	return null

func save_bytes(item:String,res:PackedByteArray) -> Error:
	remove_item_if_exists(item)
	create_item_if_miss(item)
	var file = FileAccess.open(get_item_path(item),FileAccess.WRITE)
	var ok = file.store_buffer(res)
	return ERR_FILE_CANT_WRITE if not ok else OK

func load_bytes(item:String)->PackedByteArray:
	create_item_if_miss(item.get_base_dir(),true)
	if test_item_existe(item):
		return FileAccess.get_file_as_bytes(get_item_path(item))
	return []
