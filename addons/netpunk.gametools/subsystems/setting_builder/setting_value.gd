@tool
extends HBoxContainer

@export var setting_name: String:
	set(value):
		setting_name = value
		call_deferred("update_name")

@export var user_editable: bool = true:
	set(value):
		user_editable = value
		call_deferred("update_editable")

enum widget_list {CHECKBOX, CHECK_BUTTON, COLOR_PICKER, OPTION_BUTTON, 
	SLIDER, SPIN_BOX}

@export var setting_type: widget_list

const CHECKBOX_FLAGS = preload("res://addons/netpunk.gametools/subsystems/setting_builder/SettingFlags/checkbox_flags.tscn")
const COLOR_PICKER_FLAGS = preload("res://addons/netpunk.gametools/subsystems/setting_builder/SettingFlags/color_picker_flags.tscn")
const NUMBER_BAR_FLAGS = preload("res://addons/netpunk.gametools/subsystems/setting_builder/SettingFlags/number_bar_flags.tscn")
const OPTION_BUTTON_FLAGS = preload("res://addons/netpunk.gametools/subsystems/setting_builder/SettingFlags/option_button_flags.tscn")

func _ready() -> void:
	update_name()
	update_editable()
	build_settings()
	for type in widget_list.keys():
		%SettingType.add_item(type.capitalize())
	%SettingType.selected = -1
	clear_selected_settings()
	%MenuButton.get_popup().connect("id_pressed", _on_menu_item_pressed)

func update_editable() -> void:
	%SettingName.visible = not user_editable
	
	%EditableSettingName.visible = user_editable
	%EditableSettingName.editable = user_editable
	
	%MenuButton.get_popup().set_item_disabled(0, not user_editable)

func update_name() -> void:
	%SettingName.text = setting_name
	%EditableSettingName.text = setting_name


func _on_option_button_item_selected(index: int) -> void:
	setting_type = widget_list.get(%SettingType.get_item_text(index).to_upper().replace(' ', '_'))
	build_settings()

func build_settings() -> void:
	match widget_list.keys()[setting_type].capitalize():
		"Checkbox":
			clear_selected_settings()
			var new_checkbox_flags = CHECKBOX_FLAGS.instantiate()
			%SelectedSettings.add_child(new_checkbox_flags)
		"Check Button":
			clear_selected_settings()
			var new_checkbox_flags = CHECKBOX_FLAGS.instantiate()
			%SelectedSettings.add_child(new_checkbox_flags)
		"Color Picker":
			clear_selected_settings()
			var new_color = COLOR_PICKER_FLAGS.instantiate()
			%SelectedSettings.add_child(new_color)
		"Option Button":
			clear_selected_settings()
			var new_option = OPTION_BUTTON_FLAGS.instantiate()
			%SelectedSettings.add_child(new_option)
		"Slider":
			clear_selected_settings()
			var new_number = NUMBER_BAR_FLAGS.instantiate()
			%SelectedSettings.add_child(new_number)
		"Spin Box":
			clear_selected_settings()
			var new_number = NUMBER_BAR_FLAGS.instantiate()
			%SelectedSettings.add_child(new_number)

func clear_selected_settings() -> void:
	for child in %SelectedSettings.get_children():
		child.queue_free()

func _on_menu_item_pressed(id: int) -> void:
	var selection = %MenuButton.get_popup().get_item_text(id)
	match selection:
		"Delete Setting":
			queue_free()

func export_settings() -> Array:
	var child_dict = {}
	for child in %SelectedSettings.get_children():
		var child_data = child.export_settings()
		if child_data[0] not in child_dict.keys():
			child_dict[child_data[0]] = child_data[child_data[1]]
		else: 
			print_debug("Settings name collision")
	return [setting_name, child_dict]
