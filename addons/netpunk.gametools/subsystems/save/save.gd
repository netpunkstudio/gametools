extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func load_settings(filename:String) -> Dictionary:
	var settings: Dictionary
	if FileAccess.file_exists(filename):
		var raw_settings = FileAccess.get_file_as_string(filename)
		settings = JSON.parse_string(raw_settings)
	return settings

func save_settings(filename:String, settings: Dictionary) -> void:
	var data = JSON.stringify(settings)
	var save_file = FileAccess.open(filename, FileAccess.WRITE)
	save_file.store_string(data)
	save_file.close()
