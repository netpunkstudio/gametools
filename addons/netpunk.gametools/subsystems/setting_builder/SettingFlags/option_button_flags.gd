extends VBoxContainer

const OPTION_BUTTON_ENTRY = preload("res://addons/netpunk.gametools/subsystems/setting_builder/SettingFlags/option_button_entry.tscn")

func _on_add_option_pressed() -> void:
	var new_entry = OPTION_BUTTON_ENTRY.instantiate()
	%Options.add_child(new_entry)

func export_settings() -> Array:
	var settings = {'type': 'Checkbox'}
	
	return [null, settings]
