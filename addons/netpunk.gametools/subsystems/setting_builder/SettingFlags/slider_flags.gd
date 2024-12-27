extends GridContainer

func export_settings() -> Array:
	var settings = {
		'type': 'SLIDER',
		'min': %Min.value,
		'max': %Max.value,
		'step': %Step.value,
		'value': %Value.value,
		}
	
	return [null, settings]
