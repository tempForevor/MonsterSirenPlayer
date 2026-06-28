@tool
extends EditorPlugin


func _enable_plugin() -> void:
	add_import_plugin(LyricResourceImporter.new())
	#print(LyricLoader.load("res://test/Innocence.lrc").lyrics)


func _disable_plugin() -> void:
	remove_import_plugin(LyricResourceImporter.new())


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
