extends TabContainer

func export_settings():
	var child_dict = {}
	for child in get_children():
		var child_data = child.export_settings()
		if child_data[0] not in child_dict.keys():
			child_dict[child_data[0]] = child_data[1]
		else: 
			print_debug("Settings name collision")
	return [name, child_dict]
