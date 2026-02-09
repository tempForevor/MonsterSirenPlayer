extends Node

func get_file_tree(path:String,translationer:Callable,prefix:="")->Dictionary:
	var dic = {}
	var dir := DirAccess.open(path+"/"+prefix)
	if not dir:
		printerr("尝试访问路径时出错。")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			# 发现目录
			dic = DictUtil.recursive_merge(dic,get_file_tree(path,translationer,prefix+"/"+file_name))
		else:
			# 发现文件
			dic[prefix+"/"+file_name] = translationer.call(path+prefix+"/"+file_name)
		file_name = dir.get_next()
		
	return dic
