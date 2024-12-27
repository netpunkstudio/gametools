@tool
extends TabBar

@export var settings_key: String

var settings_group = preload("res://addons/netpunk.gametools/subsystems/setting_builder/settings_group.tscn")

func export_settings():
	var child_dict = {}
	for child in %Groups.get_children():
		var child_data = child.export_settings()
		if child_data[0] not in child_dict.keys():
			child_dict[child_data[0]] = child_data[child_data[1]]
		else: 
			print_debug("Settings name collision")
	return [settings_key, child_dict]

func _on_add_group_pressed() -> void:
	var new_group = settings_group.instantiate()
	%Groups.add_child(new_group)
