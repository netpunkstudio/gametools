extends Control

## Emitted when the player presses New Game.
signal new_game_requested

## Emitted when the player presses Continue, carrying the last-used slot index.
signal continue_requested(slot_index: int)

## Emitted when the player presses Load Game (show your slot-picker UI here).
signal load_game_requested

## Emitted when the player presses Quit.
## Connect to get_tree().quit() or intercept for a confirmation dialog.
signal quit_requested


func _ready() -> void:
	%Background.texture = _resolve_background()
	%ContinueButton.visible = SaveManager.get_last_used_slot() >= 0


func _on_new_game_pressed() -> void:
	new_game_requested.emit()


func _on_continue_pressed() -> void:
	continue_requested.emit(SaveManager.get_last_used_slot())


func _on_load_game_pressed() -> void:
	load_game_requested.emit()


func _on_quit_pressed() -> void:
	quit_requested.emit()


func _resolve_background() -> Texture2D:
	var meta_key: String = ProjectSettings.get_setting(
		"gametools/loading/background_meta_key", "chapter")
	var keys: PackedStringArray = ProjectSettings.get_setting(
		"gametools/loading/background_keys", PackedStringArray())
	var paths: PackedStringArray = ProjectSettings.get_setting(
		"gametools/loading/background_paths", PackedStringArray())

	var meta := SaveManager.get_last_slot_meta()
	if not meta.is_empty() and meta.has(meta_key):
		var val := str(meta[meta_key])
		var idx := keys.find(val)
		if idx != -1 and idx < paths.size():
			var path := paths[idx]
			if not path.is_empty() and ResourceLoader.exists(path):
				return load(path) as Texture2D

	var default_path: String = ProjectSettings.get_setting(
		"gametools/loading/default_background", "")
	if not default_path.is_empty() and ResourceLoader.exists(default_path):
		return load(default_path) as Texture2D

	return null
