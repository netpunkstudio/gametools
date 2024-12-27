extends HBoxContainer

func export_settings() -> Array:
	var settings = {
		'type': 'CHECKBOX',
		'selected': %CheckBox.button_pressed,
		}
	
	return [null, settings]
