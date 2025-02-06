@tool
extends PanelContainer

@export var settings_key: String:
	set(value):
		settings_key = value
		update_title(settings_key)

@export var user_editable: bool = true:
	set(value):
		user_editable = value
		update_editable()

var setting_value = preload("res://addons/netpunk.gametools/subsystems/setting_builder/setting_value.tscn")

func _ready() -> void:
	update_title(settings_key)
	call_deferred("update_editable")
	%MenuButton.get_popup().connect("id_pressed", _on_menu_item_pressed)

func export_settings() -> Array:
	var child_dict = {}
	for child in %SettingsContents.get_children():
		var child_data = child.export_settings()
		if child_data[0] not in child_dict.keys():
			child_dict[child_data[0]] = child_data[1]
		else: 
			print_debug("Settings name collision")
			
	return [settings_key, child_dict]

func update_title(value: String) -> void:
	%Title.text = value

func update_editable() -> void:
	%AddButton.visible = user_editable
	%AddButton.disabled = not user_editable
	
	%Title.visible = not user_editable
	
	%EditableTitle.visible = user_editable
	%EditableTitle.editable = user_editable
	
	%MenuButton.get_popup().set_item_disabled(0, not user_editable)

func _on_add_button_pressed() -> void:
	var new_setting = setting_value.instantiate()
	%SettingsContents.add_child(new_setting)

func _on_menu_item_pressed(id: int) -> void:
	var selection = %MenuButton.get_popup().get_item_text(id)
	match selection:
		"Delete Group":
			queue_free()

func _on_editable_title_text_changed(new_text: String) -> void:
	settings_key = new_text
