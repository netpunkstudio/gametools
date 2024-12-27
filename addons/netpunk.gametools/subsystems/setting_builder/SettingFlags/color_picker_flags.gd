extends HBoxContainer

func export_settings() -> Array:
	var settings = {
		'type': 'COLOR_PICKER',
		'color': %ColorPickerButton.color.to_html(false),
		}
	
	return [null, settings]
