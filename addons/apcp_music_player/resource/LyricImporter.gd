@tool
extends EditorImportPlugin

class_name LyricResourceImporter

func _get_importer_name():
	return "apcp.music_player.lyric_resource"

func _get_visible_name():
	return "Lyric Resource"

func _get_recognized_extensions():
	return ["lrc"]

func _get_save_extension():
	return "tres"

func _get_resource_type():
	return "LyricResource"

func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
	return []

func _import(source_file, save_path, options, platform_variants, gen_files):
	var file = FileAccess.open(source_file, FileAccess.READ)
	print("Try to load lrc file......")
	if file == null:
		return FAILED
	print("Try to parse the lrc content......")
	var res := LyricResource.parse(file.get_as_text())
	print("Parsing lrc resource: Done.")
	
	print("Saving lrc file as resource......")
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res, filename)
