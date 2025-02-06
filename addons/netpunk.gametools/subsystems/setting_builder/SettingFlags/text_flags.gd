extends HBoxContainer

func export_settings() -> Array:
	var settings = {
		'type': 'TEXT',
		'selected': %Text.text,
		}
	
	return [null, settings]
