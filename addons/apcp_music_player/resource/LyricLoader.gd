extends ResourceFormatLoader

class_name LyricLoader

static func load(source_file:String) -> LyricResource:
	var file = FileAccess.open(source_file, FileAccess.READ)
	var res := LyricResource.parse(file.get_as_text())
	return res
