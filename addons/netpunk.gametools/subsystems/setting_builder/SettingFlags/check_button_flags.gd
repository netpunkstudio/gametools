extends HBoxContainer

func export_settings() -> Array:
	var settings = {
		'type': 'CHECK_BUTTON',
		'selected': %CheckBox.button_pressed,
		}
		
	return [null, settings]
