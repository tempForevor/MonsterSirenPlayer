extends Window

func _init() -> void:
	ScenesVariables.Player = self


func _on_close_requested() -> void:
	self.hide()
