@tool
extends EditorPlugin

var format_autoload : Dictionary[String,String] = {
	"Formater" : "res://addons/apcp_format/FormatAnalysiser/FormatAnalysiser.gd",
	"FormatConfig" : "res://addons/apcp_format/FormatAnalysiser/FormatConfig.gd"
}

func _enable_plugin() -> void:
	for i in format_autoload.keys():
		add_autoload_singleton(i,format_autoload[i])


func _disable_plugin() -> void:
	for i in format_autoload.keys():
		remove_autoload_singleton(i)


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
